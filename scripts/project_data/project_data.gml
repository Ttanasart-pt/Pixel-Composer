#region global
	globalvar PROJECTS, PROJECT;
	PROJECT = noone;
#endregion

#region layer
	function Layer() constructor {
		name  = "New Layer";
		nodes = [];
	}
#endregion

#region project
	function Project() constructor {
		active	= true; /// @is {bool}
		
		meta      = __getdefaultMetaData();	
		path	  = ""; /// @is {string}
		thumbnail = "";													
		version   = SAVE_VERSION; /// @is {number}
		seed      = irandom_range(100000, 999999); /// @is {number}
		
		modified  = false; /// @is {bool}
		readonly  = false; /// @is {bool}
		safeMode  = false;
		
		allNodes    = [];
		nodes	    = [];
		nodeTopo    = [];
		nodeMap	    = ds_map_create();
		nodeNameMap = ds_map_create();
		
		composer    = noone;
		
		animator	   = new AnimationManager();
		globalNode	   = new Node_Global();
		nodeController = new __Node_Controller(self);
		
		previewGrid = { #region
			show	: false,
			snap	: false,
			size	: [ 16, 16 ],
			opacity : 0.5,
			color   : COLORS.panel_preview_grid,
			
			pixel   : false,
		} #endregion
		
		graphGrid = { #region
			show	: true,
			show_origin : false,
			snap	: true,
			size	: 16,
			opacity : 0.05,
			color   : c_white,
			highlight : 12,
		} #endregion
		
		addons = {};
		
		onion_skin = { #region
			enabled: false,
			range: [ -1, 1 ],
			step: 1,
			color: [ c_red, c_blue ],
			alpha: 0.5,
			on_top: true,
		}; #endregion
		
		#region =================== ATTRIBUTES ===================
			attributes = variable_clone(PROJECT_ATTRIBUTES);
			
			attributeEditor = [
				[ "Default Surface", "surface_dimension", new vectorBox(2, 
					function(ind, val) { 
						attributes.surface_dimension[ind] = val; 
						PROJECT_ATTRIBUTES.surface_dimension = array_clone(attributes.surface_dimension);
						RENDER_ALL 
						return true; 
					}), 
					function(junc) {
						if(!is_struct(junc)) return;
						if(!is_instanceof(junc, NodeValue)) return;
						
						var attr = attributes.surface_dimension;
						var _val = junc.getValue();
						var _res = [ attr[0], attr[1] ];
						
						switch(junc.type) {
							case VALUE_TYPE.float : 
							case VALUE_TYPE.integer : 
								if(is_real(_val)) 
									_res = [ _val, _val ];
								else if(is_array(_val) && array_length(_val) >= 2) {
									_res[0] = is_real(_val[0])? _val[0] : 1;
									_res[1] = is_real(_val[1])? _val[1] : 1;
								}
								break;
								
							case VALUE_TYPE.surface : 
								if(is_array(_val)) _val = array_safe_get_fast(_val, 0);
								if(is_surface(_val)) 
									_res = surface_get_dimension(_val);
								break;
						}
						
						attr[0]  = _res[0];
						attr[1]  = _res[1];
					} ],
					
				[ "Palette", "palette", new buttonPalette(function(pal) { setPalette(pal); RENDER_ALL return true; }), 
					function(junc) {
						if(!is_struct(junc)) return;
						if(!is_instanceof(junc, NodeValue)) return;
						if(junc.type != VALUE_TYPE.color) return;
						if(junc.display_type != VALUE_DISPLAY.palette) return;
						
						setPalette(junc.getValue());
					} 
				],
				
				//[ "Strict",	"strict", new checkBox(function() { attributes.strict = !attributes.strict; RENDER_ALL return true; }), function() {} ],
			];
			
			static setPalette = function(pal = noone) { 
				if(pal != noone) {
					for (var i = 0, n = array_length(pal); i < n; i++) 
						pal[i] = cola(pal[i], _color_get_alpha(pal[i]));
					
					attributes.palette = pal; 
					PROJECT_ATTRIBUTES.palette = array_clone(pal);
				}
				
				palettes = paletteToArray(attributes.palette); 
			
			} setPalette();
		#endregion
		
		timelines = new timelineItemGroup();
		
		notes = [];
		
		static cleanup = function() { #region
			array_foreach(allNodes, function(_node) { 
				_node.active = false; 
				_node.cleanUp(); 
			});
			
			ds_map_destroy(nodeMap);
			ds_map_destroy(nodeNameMap);
			
			gc_collect();
		} #endregion
			
		static toString = function() { return $"ProjectObject [{path}]"; }
	
		static serialize = function() {
			var _map = {};
			_map.version = SAVE_VERSION;
			
			var _anim_map = {};
			_anim_map.frames_total = animator.frames_total;
			_anim_map.framerate    = animator.framerate;
			_anim_map.frame_range  = animator.frame_range;
			_map.animator		   = _anim_map;
			
			_map.metadata    = meta.serialize();
			_map.global_node = globalNode.serialize();
			_map.onion_skin  = onion_skin;
			
			_map.previewGrid = previewGrid;
			_map.graphGrid   = graphGrid;
			_map.attributes  = attributes;
			
			_map.timelines   = timelines.serialize();
			_map.notes       = array_map(notes, function(note) { return note.serialize(); } );
			
			_map.composer    = composer == noone? -4 : composer.serialize();
			
			__node_list = [];
			array_foreach(allNodes, function(node) { if(node.active) array_push(__node_list, node.serialize()); })
			_map.nodes = __node_list;
			
			
			var prev = PANEL_PREVIEW.getNodePreviewSurface();
			if(!is_surface(prev)) _map.preview = "";
			else				  _map.preview = surface_encode(surface_size_lim(prev, 128, 128));
			
			var _addon = {};
			with(_addon_custom) {
				var _ser = lua_call(thread, "serialize");
				_addon[$ name] = PREFERENCES.save_file_minify? json_stringify_minify(_ser) : json_stringify(_ser);
			}
			_map.addon = _addon;
			
			return _map;
		}
		
		static deserialize = function(_map) {
			if(struct_has(_map, "animator")) {
				var _anim_map = _map.animator;
				animator.frames_total	= struct_try_get(_anim_map, "frames_total",   30);
				animator.framerate		= struct_try_get(_anim_map, "framerate",      30);
				animator.frame_range	= struct_try_get(_anim_map, "frame_range", noone);
			}
			
			if(struct_has(_map, "onion_skin"))	struct_override(onion_skin,  _map.onion_skin);
			if(struct_has(_map, "previewGrid")) struct_override(previewGrid, _map.previewGrid);
			if(struct_has(_map, "graphGrid"))	struct_override(graphGrid,	 _map.graphGrid);
			if(struct_has(_map, "attributes"))	struct_override(attributes,  _map.attributes);
			if(struct_has(_map, "metadata"))	meta.deserialize(_map.metadata);
			
			setPalette();
			
			if(struct_has(_map, "notes")) {
				notes = array_create(array_length(_map.notes));
				for( var i = 0, n = array_length(_map.notes); i < n; i++ )
					notes[i] = new Note.deserialize(_map.notes[i]);
			}
			
			globalNode = new Node_Global();
			     if(struct_has(_map, "global"))      globalNode.deserialize(_map.global);
			else if(struct_has(_map, "global_node")) globalNode.deserialize(_map.global_node);
			
			if(struct_has(_map, "composer") && _map.composer != -4)
				composer.deserialize(_map.composer);
			
			addons = {};
			if(struct_has(_map, "addon")) {
				var _addon = _map.addon;
				addons = _addon;
				struct_foreach(_addon, function(_name, _value) { addonLoad(_name, false); });
			}
		}
	}
	
	function __initProject() {
		PROJECT  = new Project();
		PROJECTS = [ PROJECT ];
	}
#endregion