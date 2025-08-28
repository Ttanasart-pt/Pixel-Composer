function Node_create_Krita_File_Read(_x, _y, _group = noone) { 
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("Krita file (*.kra)|*.kra", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Krita_File_Read(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
} 

function Node_create_Krita_File_Read_path(_x, _y, path) { 
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Krita_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;	
} 

function Node_Krita_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Krita File In";
	w    = 128;
	update_on_frame = false;
	
	newInput(0, nodeValue_Path( "Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "Aseprite file|*.ase;*.aseprite" });
	
	/////////////////////////////////
	
	newOutput(0, nodeValue_Output( "Merged Image", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Content",      VALUE_TYPE.object,  noone )).setIcon(THEME.junc_krita, c_white);
	newOutput(2, nodeValue_Output( "Path",         VALUE_TYPE.path,    ""    )).setVisible(false);
	
	////- Nodes
	
	b_gen_layer = button(function() /*=>*/ {return refreshLayers()}).setIcon(THEME.generate_layers).iconPad().setTooltip("Generate Layers");
	
	hold_visibility = true;
	layer_renderer  = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		if(!is(content, Krita_File))  {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, 28, COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(32);
		}
		
		var _lay = content.layerDat;
		var _amo = array_length(_lay);
		var hh   = ui(24);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(_lay); i < n; i++ ) {
			var _yy = _y + ui(8) + i * hh;
			var _bx = _x + ui(8);
			var _layer = _lay[i];
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_bx, _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); 
	
	temp_surface = [ noone, noone, noone ];
	blend_temp_surface = noone;
	
	input_display_list = [ 0, 
		["Layers",	false, noone, b_gen_layer], layer_renderer, 
	];
	
	attributes.interpolate   = 1;
	attributes.oversample    = 1;
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() /*=>*/ {return attributes.file_checker}, new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")}) ]);
	
	content      = noone;
	path_current = "";
	
	on_drop_file = function(path) { inputs[0].setValue(path); doUpdate(); return true; } 
	
	setTrigger(1, __txt("Refresh"), [THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { updatePaths(path_get(getInputData(0))); triggerRender(); });
	
	function refreshLayers() {
		if(!is(content, Krita_File)) return;
		
		var _lay = content.layerDat;
		var _nh  = 64;
		var  nx  = x + w + 32;
		var  nh  = (array_length(_lay) - 1) / 2 * _nh;
		var  ny  = y - nh;
		
		var lvs = [];
		for( var i = 0, n = array_length(_lay); i < n; i++ ) {
			var _layer = _lay[i];
			var _name  = _layer.name;
			var _node  = noone;
			
			for( var j = 0; j < array_length(outputs[1].value_to); j++ ) {
				var _targNode = outputs[1].value_to[j].node;
				if(!_targNode.active) continue;
				
				if(_targNode.display_name == _name) {
					_node = _targNode; 
					break;
				}
			}
			
			if(_node == noone) _node = nodeBuild("Node_Krita_layer", nx, ny + i * _nh).skipDefault();
			
			_node.inputs[0].setFrom(outputs[1]);
			_node.inputs[1].setValue(_name);
			_node.setDisplayName(_name, false);
			
			lvs[i] = _node;
		}
	} 
	
	function updatePaths(path = path_current, _override = false) { 
		if(!active)    return false;
		if(path == -1) return false;
		if(!_override && path_current == path) return false;
		if(!file_exists_empty(path)) { noti_warning("File not exist.", noone, self); return false; }
		
		path_current = path;
		edit_time = max(edit_time, file_get_modify_s(path_current));
		
		var ext = string_lower(filename_ext(path));
		if(ext != ".kra") return false;
		
		if(is(content, Krita_File)) {
			content.destroy();
			content = noone;
		}
		
		content = read_kra(path);
		if(content == noone) return false;
		
		return true;
	} 
	
	static step = function() { 
		if(!attributes.file_checker) return;
		if(!file_exists_empty(path_current)) return;
		
		if(file_get_modify_s(path_current) > edit_time)
			run_in_s(PREFERENCES.file_watcher_delay, function() /*=>*/ { updatePaths(path_current, true); triggerRender(); });
	} 
	
	static update = function(frame = CURRENT_FRAME) { 
		var path = path_get(getInputData(0));
		
		if(path_current != path) updatePaths(path);
		if(content == noone) return;
		
		var _meta   = content.metadata;
		var _width  = real(_meta.width);
		var _height = real(_meta.height);
		
		var _prev_spr = content.preview_sprite;
		var _outSurf  = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _width, _height);
		surface_set_shader(_outSurf);
			draw_sprite(_prev_spr, 0, 0, 0);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
		outputs[1].setValue(content);
		outputs[2].setValue(path);
	} 
	
	////- Serialize
	
	static dropPath = function(path) { 
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path); 
		check_directory_redirector(path);
	}
}