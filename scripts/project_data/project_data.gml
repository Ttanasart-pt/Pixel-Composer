#region global
	globalvar PROJECTS, PROJECT;
	PROJECT = noone;
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
		
		nodes	    = ds_list_create();
		nodeArray   = [];
		nodeMap	    = ds_map_create();
		nodeNameMap = ds_map_create();
		nodeTopo    = ds_list_create();
		
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
			attributes = {
				strict            : false,
				surface_dimension : [ 32, 32 ],
				palette           : array_clone(PREFERENCES.attr_palette),
				palette_fix       : false,
			}
			
			attributeEditor = [
				[ "Default Surface", "surface_dimension", new vectorBox(2, function(ind, val) { attributes.surface_dimension[ind] = val; RENDER_ALL return true; }), 
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
				if(pal != noone) attributes.palette = pal; 
				PREFERENCES.attr_palette = array_clone(pal);
				
				palettes = paletteToArray(attributes.palette); 
			
			} setPalette();
		#endregion
		
		timelines = new timelineItemGroup();
		
		notes = [];
		
		static cleanup = function() { #region
			if(!ds_map_empty(nodeMap))
				array_map(ds_map_keys_to_array(nodeMap), function(_key, _ind) { 
					var _node = nodeMap[? _key];
					_node.active = false; 
					_node.cleanUp(); 
				});
			
			ds_list_destroy(nodes);
			ds_map_destroy(nodeMap);
			ds_map_destroy(nodeNameMap);
			
			gc_collect();
		} #endregion
			
		static toString = function() { return $"ProjectObject [{path}]"; }
	}
	
	function __initProject() {
		PROJECT  = new Project();
		PROJECTS = [ PROJECT ];
	}
#endregion