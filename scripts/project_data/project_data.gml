#region global
	globalvar PROJECTS;
	globalvar PROJECT; PROJECT = noone;
	
	function Layer() constructor {
		name  = "New Layer";
		nodes = [];
	}
#endregion


function Project() constructor {
	active	= true;
	
	seed        = irandom_range(100000, 999999);
	meta        = __getdefaultMetaData();	
	path	    = "";
	thumbnail   = "";													
	version     = SAVE_VERSION;
	is_nightly  = NIGHTLY;
	freeze      = false;
	
	modified    = false;
	readonly    = false;
	safeMode    = false;
	online      = false;
	
	allNodes    = [];
	nodes	    = [];
	nodeTopo    = [];
	nodeTree    = new NodeTreeItem();
	nodeMap	    = ds_map_create();
	nodeNameMap = ds_map_create();
	nodeTopoID  = "";
	
	pathInputs  = [];
	
	composer        = noone;
	animator	    = new AnimationManager();
	globalNode	    = new Node_Global();
	globalNode.project = self;
	
	load_layout     = false;
	previewNode     = "";
	inspectingNode  = "";
	
	previewGrid     = variable_clone(PREFERENCES.project_previewGrid);
	previewSetting  = variable_clone(PREFERENCES.project_previewSetting);
	
	graphGrid       = variable_clone(PREFERENCES.project_graphGrid);
	graphDisplay    = variable_clone(PREFERENCES.project_graphDisplay);
	graphConnection = variable_clone(PREFERENCES.project_graphConnection);
	
	onion_skin = {
		enabled : false,
		range   : [ -1, 1 ],
		step    : 1,
		color   : [ cola(c_red), cola(c_blue) ],
		alpha   : 0.5,
		on_top  : true,
	};
	
	addons = {};
	data   = {};
	
	tunnels_in     = ds_map_create();
	tunnels_in_map = ds_map_create();
	tunnels_out    = ds_map_create();
	
	#region ===================== GLOBAL LAYER ====================
		globalLayer_surface   = noone;
		globalLayer_nodes     = [];
		globalLayer_node_disp = [];
		globalLayer_output    = [];
		
		temp_surface       = array_create(3,noone);
		blend_temp_surface = noone;
		outputNode         = noone;
		
		static getAttribute = function() /*=>*/ {return 0};
		
		static globalLayer_compose = function() /*=>*/ {
			var _dim = attributes.surface_dimension;
			
			globalLayer_surface = surface_verify(globalLayer_surface, _dim[0], _dim[1]);
			for( var i = 0, n = array_length(temp_surface); i < n; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			
			blend_temp_surface = temp_surface[2];
			
			var _drawData = [];
			
			for( var i = 0, n = array_length(globalLayer_nodes); i < n; i++ ) {
				var _node = globalLayer_nodes[i];
				if(!_node.active)       continue;
				if(!_node.renderActive) continue;
				
				var _depth = _node.inputs[1].getValue();
				
				var _surf = _node.layer_surf;
				var _pos  = _node.layer_pos;
				var _anc  = _node.layer_anc;
				var _rot  = _node.layer_rot;
				var _sca  = _node.layer_sca;
				
				array_push(_drawData, {
					depth :   _depth,
					surface : _surf,
					
					pos : _pos,
					anc : _anc,
					rot : _rot,
					sca : _sca,
					
					node : _node,
				});
			}
			
			array_sort(_drawData, function(a,b) /*=>*/ {return b.depth - a.depth});
			globalLayer_node_disp = [];
			
			var _len = array_length(_drawData);
			for( var i = 0; i < _len; i++ ) globalLayer_node_disp[i] = _drawData[_len - i - 1].node;
			
			var _bg = 0;
			
			for( var i = 0, n = array_length(_drawData); i < n; i++ ) {
				var _data = _drawData[i];
				
				var _s   = _data.surface;
				var _pos = _data.pos;
				var _anc = _data.anc;
				var _rot = _data.rot;
				var _sca = _data.sca;
				
				if(!is_surface(_s)) continue;
				var _ww = surface_get_width_safe(_s);
				var _hh = surface_get_height_safe(_s);
				var _sw = _ww * _sca[0];
				var _sh = _hh * _sca[1];
				
				var _ax = _anc[0] * _sw;
				var _ay = _anc[1] * _sh;
				
				var _cx = _pos[0];
				var _cy = _pos[1];
				
				var _d0 = point_rotate(_cx - _ax, _cy - _ay, _cx, _cy, _rot);
				
				surface_set_shader(temp_surface[_bg], sh_sample, true, BLEND.over);
					try { draw_surface_blend_ext(temp_surface[!_bg], _s, _d0[0], _d0[1], _sca[0], _sca[1], _rot); }
					catch(e) { noti_warning(e); }
				surface_reset_shader();
				
				_bg = !_bg;
			}
			
			surface_set_shader(globalLayer_surface);
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
		};
		
		static getOutputSurface = function() {
			if(outputNode == noone)       return globalLayer_surface;
			if(!outputNode.active)        return globalLayer_surface;
			if(!outputNode.renderActive)  return globalLayer_surface;
			
			return outputNode.outputSurface;
		}
	#endregion
	
	#region ===================== BINDERS ====================
		bind_gamemaker = noone;
		bind_godot     = noone;
		
		gamemaker_editWidget = new gamemakerPathBox(self);
	#endregion
	
	#region =================== ATTRIBUTES ===================
		attributes = variable_clone(PROJECT_ATTRIBUTES);
		attributes.bind_gamemaker_path = "";
		attributes.bind_godot_path     = "";
		attributes.env_variables       = {
			"json_asset_dir": "-",
		};
			
		attributes.auto_organize       = false;
		
		attributeEditor = [
			[ "Default Surface", "surface_dimension", new vectorBox(2, 
				function(val, index) { 
					attributes.surface_dimension[index] = val; 
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
				} 
			],
			
			[ "Palette", "palette", new buttonPalette(function(pal) /*=>*/ { setPalette(pal); RENDER_ALL return true; }), 
				function(junc) {
					if(!is(junc, NodeValue)) return;
					if(junc.type != VALUE_TYPE.color || junc.display_type != VALUE_DISPLAY.palette) return;
					
					setPalette(junc.getValue());
				} 
			],
			
			[ "Export Directory", "export_dir", textBox_Text(function(str) /*=>*/ { attributes.export_dir = str; return true; })
				.setSideButton(
					button(function() /*=>*/ { 
						var _fpath = get_open_directory_compat(attributes.export_dir); key_release();
						if(_fpath != "") attributes.export_dir = _fpath;
					}).setIcon(THEME.button_path_icon, 0, COLORS._main_icon)
				) ],
			
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
	
	////- Step

	static step = function() {
		slideShowPreStep();
		
		animator.step();
		globalNode.step();
		
		try {
			array_foreach(allNodes, function(n) /*=>*/ { 
				if(!n.active) return; 
				
				n.triggerCheck(); 
				n.doStep(); 
			});
		} catch(e) {
			noti_warning("Node Step error: " + exception_print(e));
		}
	}
	
	static stepBegin = function() { 
		array_foreach(allNodes, function(n) /*=>*/ { 
			if(!n.active) return; 
			n.stepBegin(); 
		});
	}
	
	static postStep = function() { slideShowPostStep(); }
	
	////- Render
	
	static preRender = function() {
		globalNode.update();
	}
	
	static postRender = function() {
		globalLayer_compose();
		if(attributes.auto_organize) node_auto_organize(nodes);
	}

	////- Slideshow

	useSlideShow      = false;
	slideShow         = {};
	slideShow_keys    = [];
	slideShow_index   = 0;
	slideShow_amount  = 0;
	slideShow_current = noone;
	
	static slideShowPreStep = function() { slideShow = {}; }
	
	static slideShowPostStep = function() {
		slideShow_keys = variable_struct_get_names(slideShow);
		array_sort(slideShow_keys, true);
		
		slideShow_amount  = array_length(slideShow_keys);
		useSlideShow      = slideShow_amount > 0;
		slideShow_current = struct_try_get(slideShow, array_safe_get(slideShow_keys, slideShow_index, 0), noone);
	}
	
	static slideShowSet = function(index) { 
		slideShow_index   = index;
		slideShow_current = struct_try_get(slideShow, array_safe_get(slideShow_keys, slideShow_index, 0), noone);
		return slideShow_current;
	}
	
	////- Action

	static cleanup = function() {
		array_foreach(allNodes, function(_n) /*=>*/ { 
			_n.active = false; 
			_n.cleanUp(); 
			delete _n;
		});
		
		ds_map_destroy(nodeMap);
		ds_map_destroy(nodeNameMap);
		
		run_in_s(1, function() /*=>*/ { gc_collect(); gc_enable(true); });
		
		ds_stack_clear(UNDO_STACK);
	}
		
	static toString = function() { return $"ProjectObject [{path}]"; }
	
	static getVar = function(key) { 
		if(has(attributes.env_variables, key))
			return attributes.env_variables[$ key];
			
		attributes.env_variables[$ key] = "";
		return "";
	}
	
	////- Serialize

	static serialize = function(_addon = true) {
		var _map = {};
		_map.version    = SAVE_VERSION;
		_map.versions   = VERSION_STRING;
		_map.is_nightly = NIGHTLY;
		_map.freeze     = freeze;
		
		var _anim_map = {};
		_anim_map.frames_total = animator.frames_total;
		_anim_map.framerate    = animator.framerate;
		_anim_map.frame_range  = animator.frame_range;
		_anim_map.playback     = animator.playback;
		_map.animator		   = _anim_map;
		
		_map.metadata    = meta.serialize();
		_map.global_node = globalNode.serialize();
		_map.onion_skin  = onion_skin;
		
		var _prev_node = PANEL_PREVIEW? PANEL_PREVIEW.getNodePreview() : noone;
		_map.previewNode = _prev_node? _prev_node.node_id : noone;
		
		var _insp_node = PANEL_INSPECTOR? PANEL_INSPECTOR.getInspecting() : noone;
		_map.inspectingNode = _insp_node? _insp_node.node_id : noone;
		
		_map.previewGrid     = variable_clone(previewGrid);
		_map.graphGrid       = variable_clone(graphGrid);
		_map.graphConnection = variable_clone(graphConnection);
		_map.attributes      = variable_clone(attributes);
		_map.data            = variable_clone(data);
		
		_map.timelines   = timelines.serialize();
		_map.notes       = array_map(notes, function(note) { return note.serialize(); } );
		
		_map.composer    = composer;
		_map.load_layout = load_layout;
		if(load_layout) _map.layout = panelSerialize(true);
		
		_map.graph_display_parameter = graphDisplay;
		
		__node_list = [];
		array_foreach(allNodes, function(node) { if(node.active) array_push(__node_list, node.serialize()); })
		_map.nodes = __node_list;
		
		var prev = PANEL_PREVIEW.getNodePreviewSurface();
		if(!is_surface(prev)) _map.preview = "";
		else				  _map.preview = surface_encode(surface_size_lim(prev, 128, 128));
		
		if(_addon) {
			__addon = {};
			with(_addon_custom) {
				try {
					var _ser = lua_call(thread, "serialize");
					other.__addon[$ name] = PREFERENCES.save_file_minify? json_stringify_minify(_ser) : json_stringify(_ser);
				} catch(e) { noti_warning($"Serialize error: {exception_print(e)}") }
			}
			_map.addon = __addon;
		}
		
		return _map;
	}
	
	static deserialize = function(_map) {
		if(!is_struct(_map)) return;
		
		if(struct_has(_map, "animator")) {
			var _anim_map = _map.animator;
			animator.frames_total	= struct_try_get(_anim_map, "frames_total",   30);
			animator.framerate		= struct_try_get(_anim_map, "framerate",      30);
			animator.frame_range	= struct_try_get(_anim_map, "frame_range", noone);
			animator.playback   	= struct_try_get(_anim_map, "playback",    ANIMATOR_END.loop);
		}
		
		if(struct_has(_map, "onion_skin"))	    struct_override(onion_skin,      _map.onion_skin);
		if(struct_has(_map, "previewGrid"))     struct_override(previewGrid,     _map.previewGrid);
		if(struct_has(_map, "graphGrid"))	    struct_override(graphGrid,	     _map.graphGrid);
		if(struct_has(_map, "graphConnection"))	struct_override(graphConnection, _map.graphConnection);
		if(struct_has(_map, "attributes"))	    struct_override(attributes,      _map.attributes);
		if(struct_has(_map, "metadata"))	meta.deserialize(_map.metadata);
		if(struct_has(_map, "composer"))	composer = _map.composer;
		if(struct_has(_map, "freeze"))	    freeze   = _map.freeze;
		if(struct_has(_map, "data"))	    data     = variable_clone(_map.data);
		
		if(struct_has(_map, "graph_display_parameter"))	struct_override(graphDisplay,  _map.graph_display_parameter);
		
		is_nightly	= _map[$ "is_nightly"]  ?? is_nightly;
		load_layout	= _map[$ "load_layout"] ?? load_layout;
		
		setPalette();
		
		if(struct_has(_map, "notes")) {
			notes = array_create(array_length(_map.notes));
			for( var i = 0, n = array_length(_map.notes); i < n; i++ )
				notes[i] = new Note.deserialize(_map.notes[i]);
		}
		
		globalNode = new Node_Global();
		globalNode.project = self;
		
		     if(struct_has(_map, "global"))      globalNode.deserialize(_map.global);
		else if(struct_has(_map, "global_node")) globalNode.deserialize(_map.global_node);
		
		if(struct_has(_map, "addon")) {
			addons = _map.addon;
			struct_foreach(addons, function(_name, _value) /*=>*/ { addonLoad(_name, false); });
		}
		
		bind_gamemaker = Binder_Gamemaker(attributes.bind_gamemaker_path);
		if(bind_gamemaker == noone) attributes.bind_gamemaker_path = "";
		
		globalNode.update();
	}
	
	static postDeserialize = function(_map) {
		
		previewNode  	= struct_try_get(_map, "previewNode", noone);
		if(PANEL_PREVIEW && previewNode != "") {
			var _node = nodeMap[? previewNode];
			if(_node) PANEL_PREVIEW.setNodePreview(_node);
		}
		
		inspectingNode	= struct_try_get(_map, "inspectingNode", noone);
		if(PANEL_INSPECTOR && inspectingNode != "") {
			var _node = nodeMap[? inspectingNode];
			if(_node) PANEL_INSPECTOR.setInspecting(_node);
		}
		
	}
}

function __initProject() {
	PROJECT  = new Project();
	PROJECTS = [ PROJECT ];
}
