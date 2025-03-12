function Node_create_ASE_File_Read(_x, _y, _group = noone) { 
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_pxc("Aseprite file (*.aseprite, *.ase)|*.aseprite;*.ase", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_ASE_File_Read(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
} 

function Node_create_ASE_File_Read_path(_x, _y, path) { 
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_ASE_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;	
} 

function Node_ASE_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE File In";
	w    = 128;
	update_on_frame = false;
	
	newInput(0, nodeValue_Path("Path", self, ""))
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "Aseprite file|*.ase;*.aseprite" });
		
	newInput(1, nodeValue_Trigger("Generate layers", self, false ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() /*=>*/ {return refreshLayers()} });
	
	newInput(2, nodeValue_Text("Current tag", self, ""));
	
	newInput(3, nodeValue_Bool("Use cel dimension", self, false));
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Content", self, VALUE_TYPE.object, self))
		.setIcon(THEME.junc_aseprite, c_white);
	
	newOutput(2, nodeValue_Output("Path", self, VALUE_TYPE.path, ""))
		.setVisible(false);
	
	newOutput(3, nodeValue_Output("Palette", self, VALUE_TYPE.color, []))
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(false);
	
	newOutput(4, nodeValue_Output("Layers", self, VALUE_TYPE.text, []))
		.setVisible(false);
	
	newOutput(5, nodeValue_Output("Tags", self, VALUE_TYPE.text, []))
		.setVisible(false);
	
	newOutput(6, nodeValue_Output("Raw data", self, VALUE_TYPE.struct, {}))
		.setVisible(false);
	
	newOutput(7, nodeValue_Output("Frame Amount", self, VALUE_TYPE.integer, 1))
		.setVisible(false);
	
	hold_visibility = true;
	layer_renderer  = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var _vis = attributes.layer_visible;
		var _amo = array_length(layers);
		var hh   = ui(24);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			var _yy = _y + ui(8) + i * hh;
			var _bx = _x + ui(24);
			var _layer = layers[i];
			
			if(_layer.type == 0) {
				var vis = array_safe_get_fast(_vis, i, true);
				if(point_in_circle(_m[0], _m[1], _bx, _yy + hh / 2, ui(12))) {
					draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _yy + hh / 2, 1, c_white);
					
					if(mouse_press(mb_left, _focus))
						hold_visibility = !_vis[i];
						
					if(mouse_click(mb_left, _focus) && _vis[i] != hold_visibility) {
						_vis[@ i] = hold_visibility;
						update();
					}
				} else 
					draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _yy + hh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * vis);
					
			} else if(_layer.type == 1)
				draw_sprite_ui_uniform(THEME.folder_16, 0, _bx, _yy + hh / 2, 1, COLORS._main_icon);
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_bx + ui(16), _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); 
	
	tag_renderer    = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var current_tag = getInputData(2);
		var amo = array_length(tags);
		var abx = ui(24);
		
		var by = _y;
		var hh = ui(32);
		var _h = hh * amo + ui(8);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, by, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for( var i = 0, n = array_length(tags); i < n; i++ ) {
			var _yy = by + ui(4) + i * hh;
			var tag = tags[i];
			
			var _tagName = tag[$ "Name"];
			var cc = tag[$ "Color"];
			var st = tag[$ "Frame start"];
			var ed = tag[$ "Frame end"];
			var rn = ed - st + 1;
			
			var progFr = safe_mod(CURRENT_FRAME - _tag_delay, rn) + 1;
			var prog   = progFr / rn;
			var txt    = "";
			
			var _tgy = _yy + ui(2);
			var _tgh = hh  - ui(4);
			
			var _x1 = _x + ui(8);
			var _tw = _w - ui(16);
			
			if(tag[$ "Name"] == current_tag) {
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _x1, _tgy, _tw, _tgh, cc, 0.5);
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _x1, _tgy, _tw * prog, _tgh, cc, 0.85);
				draw_sprite_stretched_add(THEME.ui_panel, 1, _x1, _tgy, _tw * prog, _tgh, c_white, 0.1);
				
				txt = $"{progFr}/{rn}";
				
			} else {
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _x1, _tgy, ui(10), _tgh, cc, 0.85);
				draw_sprite_stretched_add(THEME.ui_panel, 1, _x1, _tgy, ui(10), _tgh, c_white, 0.1);
				
				txt = $"{rn}";
			}
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x1, _yy, _x + _w - ui(8), _yy + hh)) {
				draw_sprite_stretched_add(THEME.ui_panel, 0, _x1, _tgy, _tw, _tgh, c_white, 0.1);
				
				if(mouse_press(mb_left, _focus))
					inputs[2].setValue(current_tag == _tagName? "" : _tagName);
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_set_alpha(1);
			draw_text_add(_x + ui(28), _yy + hh / 2, tag[$ "Name"]);
			
			draw_set_halign(fa_right);
			draw_set_alpha(0.4);
			draw_text_add(_x + _w - ui(20), _yy + hh / 2, txt);
			
			draw_set_alpha(1);
		}
		
		tag_renderer.h = _h;
		return _h;
	}); 
	
	temp_surface = [ 0, 0, 0 ];
	blend_temp_surface = noone;
	
	input_display_list = [ 0, 
		["Layers",	false], 1, 3, layer_renderer, 
		["Tags",	false], 2, tag_renderer,
	];
	
	attributes.layer_visible = [];
	attributes.interpolate   = 1;
	attributes.oversample    = 1;
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() /*=>*/ {return attributes.file_checker}, new checkBox(function() /*=>*/ { attributes.file_checker = !attributes.file_checker; }) ]);
	
	content      = noone;
	layers       = [];
	tags         = [];
	_tag_delay   = 0;
	path_current = "";
	first_update = false;
	
	on_drop_file = function(path) { inputs[0].setValue(path); doUpdate(); return true; } 
	
	setTrigger(1, __txt("Refresh"), [THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { updatePaths(path_get(getInputData(0))); triggerRender(); });
	
	function refreshLayers() { 
		var _nh = 64;
		var nx = x + w + 32;
		var nh = (array_length(layers) - 1) / 2 * _nh;
		var ny = y - nh;
		
		var use_cel = getInputData(3);
		
		var lvs = [];
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			var _layer = layers[i];
			if(_layer.type != 0) continue;
			
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
			
			if(_node == noone)
				_node = nodeBuild("Node_ASE_layer", nx, ny + i * _nh).skipDefault();
			
			_node.inputs[0].setFrom(outputs[1]);
			_node.inputs[1].setValue(use_cel);
			_node.inputs[2].setValue(_name);
			_node.setDisplayName(_name);
			
			lvs[i] = _node;
		}
	} 
	
	function updatePaths(path = path_current) { 
		if(path == -1) return false;
		if(!file_exists_empty(path)) {
			noti_warning("File not exist.", noone, self);
			return false;
		}
		
		path_current = path;
		
		var ext   = string_lower(filename_ext(path));
		var _name = filename_name_only(path);
		
		if(ext != ".ase" && ext != ".aseprite") return false;
		
		content = read_ase(path);
		if(content == noone) return false;
		
		layers     = [];
		var vis    = attributes.layer_visible;
		var frames = content[$ "Frames"];
		if(array_empty(frames)) return false;
		
		for( var i = 0, n = array_length(frames); i < n; i++ ) {
			var frame  = frames[i];
			var chunks = frame[$ "Chunks"];
			
			for( var j = 0; j < array_length(chunks); j++ ) {
				var chunk = chunks[j];
				
				switch(chunk[$ "Type"]) {
					case 0x2019: //palette
						var pals = chunk[$ "Palette"];
						var pamo = array_length(pals)
						var plt  = array_create(pamo);
						var par  = array_create(pamo);
						
						for( var k = 0; k < pamo; k++ ) {
							var _clr = pals[k];
							var _r   = _clr[$ "Red"]   ?? 0;
							var _g   = _clr[$ "Green"] ?? 0;
							var _b   = _clr[$ "Blue"]  ?? 0;
							var _a   = _clr[$ "Alpha"] ?? 0;
							
							plt[k] = [ _r, _g, _b, _a ];
							par[k] = make_color_rgba(_r, _g, _b, _a);
						}
						
						content[$ "Palette"] = plt;
						outputs[3].setValue(par);
						break;
						
					case 0x2004: //layer
						var name = chunk[$ "Name"];
						var type = chunk[$ "Layer type"];
						
						array_push(layers, new ase_layer(name, type));
						array_push(vis, true);
						break;
						
					case 0x2005: //cel
						var _layer = chunk[$ "Layer index"];
						var cel	= new ase_cel(layers[_layer], chunk, content);
						layers[_layer].setFrameCel(i, cel);
						break;
				}
			}
		}
		
		tags = [];
		var chunks = frames[0][$ "Chunks"];
		
		for( var j = 0; j < array_length(chunks); j++ ) {
			var chunk = chunks[j];
			if(chunk[$ "Type"] != 0x2018) continue;
			tags = chunk[$ "Tags"];
		}
		
		update_on_frame = false;
		
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			if(!struct_has(layers[i], "cels")) continue;
			
			var cel = layers[i].cels;
			if(array_length(cel)) update_on_frame = true;
		}
		
		logNode($"Loaded file: {path}", false);
		return true;
	} 
	
	static step = function() { 
		if(!attributes.file_checker) return;
		if(!file_exists_empty(path_current)) return;
		
		if(file_get_modify_s(path_current) > edit_time) {
			edit_time = max(edit_time, file_get_modify_s(path_current));
			run_in_s(PREFERENCES.file_watcher_delay, function() /*=>*/ { updatePaths(); triggerRender(); });
		}
	} 
	
	static update = function(frame = CURRENT_FRAME) { 
		var path        = path_get(getInputData(0));
		var current_tag = getInputData(2);
		
		outputs[2].setValue(path);
		outputs[6].setValue(content);
		
		if(path_current != path) updatePaths(path);
		if(content == noone) return;
		
		var tag = noone;
		var tagNames = array_create(array_length(tags));
		for( var i = 0, n = array_length(tags); i < n; i++ ) {
			tagNames[i] = tags[i][$ "Name"];
			if(tags[i][$ "Name"] == current_tag) {
				tag = tags[i];
				break;
			}
		}
		
		outputs[5].setValue(tagNames);
		outputs[7].setValue(content[$ "Frame amount"]);
		
		_tag_delay = 0;
		for( var i = 0; i < array_length(inputs[2].animator.values); i++ ) {
			var kf = inputs[2].animator.values[i];
			if(kf.time > CURRENT_FRAME) break;
			_tag_delay = kf.time;
		}
		
		var vis = attributes.layer_visible;
		var ww  = content[$ "Width"];
		var hh  = content[$ "Height"];
		
		var surf = outputs[0].getValue();
		    surf = surface_verify(surf, ww, hh);
		outputs[0].setValue(surf);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
			surface_clear(temp_surface[i]);
		}
		
		var _bg = 0;
		var _layerNames = array_create(array_length(layers));
		blend_temp_surface = temp_surface[2];
		
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			_layerNames[i] = layers[i].name;
			
			layers[i].tag = tag;
			var cel = layers[i].getCel(CURRENT_FRAME - _tag_delay);
			if(!cel) continue;
			if(!array_safe_get_fast(vis, i, true)) continue;
		
			var _inSurf = cel.getSurface();
			if(!is_surface(_inSurf)) continue;
			
			var xx = cel.data[$ "X"];
			var yy = cel.data[$ "Y"];
			
			surface_set_shader(temp_surface[_bg], sh_sample, true, BLEND.over);
				draw_surface_blend_ext(temp_surface[!_bg], _inSurf, xx, yy);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		outputs[4].setValue(_layerNames);
		surface_set_shader(surf);
			DRAW_CLEAR
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
	} 
	
	static attributeSerialize = function() { 
		var att = {};
		att.layer_visible = attributes.layer_visible;
		
		return att;
	} 
	
	static attributeDeserialize = function(attr) { 
		struct_append(attributes, attr); 
		
		if(struct_has(attr, "layer_visible"))
			attributes.layer_visible = attr.layer_visible;
	} 
	
	static dropPath = function(path) { 
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path); 
		check_directory_redirector(path);
	}
}