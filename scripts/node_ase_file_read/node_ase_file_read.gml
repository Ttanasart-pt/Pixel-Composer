function Node_create_ASE_File_Read(_x, _y, _group = noone) { #region
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_pxc("Aseprite file (*.aseprite, *.ase)|*.aseprite;*.ase", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_ASE_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
} #endregion

function Node_create_ASE_File_Read_path(_x, _y, path) { #region
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_ASE_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
} #endregion

function Node_ASE_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE File In";
	update_on_frame = false;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "Aseprite file|*.ase;*.aseprite" });
		
	inputs[| 1]  = nodeValue("Generate layers", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() { refreshLayers(); } });
	
	inputs[| 2]  = nodeValue("Current tag", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 3]  = nodeValue("Use cel dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Content", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, self);
	
	outputs[| 2] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "");
	
	outputs[| 3] = nodeValue("Palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	hold_visibility = true;
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var amo = array_length(layers);
		var hh = 28;
		var _h = hh * amo + 16;
		var _vis = attributes.layer_visible;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			var _yy = _y + 8 + i * hh;
			var _layer = layers[i];
			
			if(i) {
				draw_set_color(COLORS.node_composite_separator);
				draw_line(_x + 16, _yy - 2, _x + _w - 16, _yy - 2);
			}
			
			var vis = array_safe_get_fast(_vis, i, true);
			var _bx = _x + 24;
			if(point_in_circle(_m[0], _m[1], _bx, _yy + hh / 2, 12)) {
				draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _yy + hh / 2, 1, c_white);
				
				if(mouse_press(mb_left, _focus))
					hold_visibility = !_vis[i];
					
				if(mouse_click(mb_left, _focus) && _vis[i] != hold_visibility) {
					_vis[@ i] = hold_visibility;
					update();
				}
			} else 
				draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _yy + hh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * vis);
				
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text(_bx + 16, _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); #endregion
	
	tag_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var current_tag = getInputData(2);
		var amo = array_length(tags);
		var abx = ui(24);
		
		var by = _y;
		var hh = 32;
		var _h = hh * amo + ui(8);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, by, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for( var i = 0, n = array_length(tags); i < n; i++ ) {
			var _yy = by + ui(4) + i * hh;
			var tag = tags[i];
			
			var cc = tag[? "Color"];
			var st = tag[? "Frame start"];
			var ed = tag[? "Frame end"];
			var rn = ed - st + 1;
			
			var progFr = safe_mod(CURRENT_FRAME - _tag_delay, rn) + 1;
			var prog   = progFr / rn;
			var txt    = "";
			
			var _tgy = _yy + ui(2);
			var _tgh = hh  - ui(4);
			
			if(tag[? "Name"] == current_tag) {
				draw_sprite_stretched_ext(THEME.timeline_node, 0, _x + 8, _tgy, _w - 16, _tgh, cc, 0.5);
				
				draw_sprite_stretched_ext(THEME.timeline_node, 0, _x + 8, _tgy, (_w - 16) * prog, _tgh, cc, 0.85);
				draw_sprite_stretched_ext(THEME.timeline_node, 1, _x + 8, _tgy, (_w - 16) * prog, _tgh, c_white, 0.25);
				
				txt = $"{progFr}/{rn}";
				
			} else {
				draw_sprite_stretched_ext(THEME.timeline_node, 0, _x + 8, _tgy, 8, _tgh, cc, 0.85);
				draw_sprite_stretched_ext(THEME.timeline_node, 1, _x + 8, _tgy, 8, _tgh, c_white, 0.25);
				
				txt = $"{rn}";
			}
				
			txt += string(rn);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x + 8, _yy, _x + _w - 8, _yy + hh)) {
				draw_sprite_stretched_ext(THEME.timeline_node, 0, _x + 8, _tgy, _w - 16, _tgh, c_white, 0.1);
				if(mouse_press(mb_left, _focus)) {
					var _currTag = getInputData(2);
					var _tagName = tag[? "Name"];
					inputs[| 2].setValue(_currTag == _tagName? "" : _tagName);
				}
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_x + 24, _yy + hh / 2, tag[? "Name"]);
			
			draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w - 20, _yy + hh / 2, txt);
		}
		
		tag_renderer.h = _h;
		return _h;
	}); #endregion

	input_display_list = [
		["File",	 true], 0,
		["Layers",	false], 1, 3, layer_renderer, 
		["Tags",	false], 2, tag_renderer,
	];
	
	attributes.layer_visible = [];
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	content      = ds_map_create();
	layers       = [];
	tags         = [];
	_tag_delay   = 0;
	path_current = "";
	
	first_update = false;
	
	on_drop_file = function(path) { #region
		inputs[| 0].setValue(path);
		doUpdate();
		return true;
	} #endregion
	
	function refreshLayers() { #region
		var _nh = 64;
		var nx = x + w + 32;
		var nh = (array_length(layers) - 1) / 2 * _nh;
		var ny = y - nh;
		
		var use_cel = getInputData(3);
		
		var lvs = [];
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			var _layer = layers[i];
			var _name  = _layer.name;
			var _node  = noone;
			
			for( var j = 0; j < array_length(outputs[| 1].value_to); j++ ) {
				var _targNode = outputs[| 1].value_to[j].node;
				if(!_targNode.active) continue;
				
				if(_targNode.display_name == _name) {
					_node = _targNode;
					break;
				}
			}
			
			if(_node == noone)
				_node = nodeBuild("Node_ASE_layer", nx, ny + i * _nh);
			
			lvs[i] = _node;
			lvs[i].inputs[| 0].setFrom(outputs[| 1]);
			lvs[i].inputs[| 1].setValue(use_cel);
			lvs[i].setDisplayName(_name);
		}
	} #endregion
	
	function updatePaths(path = path_current) { #region
		if(path == -1) return false;
		if(!file_exists_empty(path)) return false;
		
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));
		
		var ext   = string_lower(filename_ext(path));
		var _name = filename_name_only(path);
		
		if(ext != ".ase" && ext != ".aseprite") return false;
		
		read_ase(path, content);
		
		layers = [];
		var vis    = attributes.layer_visible;
		var frames = content[? "Frames"];
		
		for( var i = 0, n = array_length(frames); i < n; i++ ) {
			var frame = frames[i];
			var chunks = frame[? "Chunks"];
			
			for( var j = 0; j < array_length(chunks); j++ ) {
				var chunk = chunks[j];
				
				switch(chunk[? "Type"]) {
					case 0x2019: //palette
						var pck = chunk[? "Palette"];
						var plt = [];
						for( var k = 0; k < array_length(pck); k++ ) {
							var r = pck[k][? "Red"];
							var g = pck[k][? "Green"];
							var b = pck[k][? "Blue"];
							var a = pck[k][? "Alpha"];
							array_push(plt, [r, g, b, a]);
						}
						content[? "Palette"] = plt;
						
						var p_arr = [];
						for( var k = 0; k < array_length(plt); k++ )
							array_push(p_arr, make_color_rgb(plt[k][0], plt[k][1], plt[k][2]));
						outputs[| 3].setValue(p_arr);
						break;
					case 0x2004: //layer
						var name = chunk[? "Name"];
						array_push(layers, new ase_layer(name));
						array_push(vis, true);
						break;
					case 0x2005: //cel
						var _layer = chunk[? "Layer index"];
						var cel	= new ase_cel(layers[_layer], chunk, content);
						layers[_layer].setFrameCel(i, cel);
						break;
				}
			}
		}
		
		tags = [];
		var chunks = content[? "Frames"][0][? "Chunks"];
		
		for( var j = 0; j < array_length(chunks); j++ ) {
			var chunk = chunks[j];
			if(chunk[? "Type"] != 0x2018) continue;
			tags = chunk[? "Tags"];
		}
		
		update_on_frame = false;
		
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			if(!struct_has(layers[i], "cels")) continue;
			
			var cel = layers[i].cels;
			if(array_length(cel)) update_on_frame = true;
		}
		
		return true;
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		updatePaths(path_get(getInputData(0)));
		triggerRender();
	} #endregion
	
	static step = function() { #region
		if(!attributes.file_checker) return;
		if(path_current == "") return;
		
		if(file_get_modify_s(path_current) > edit_time) {
			updatePaths();
			triggerRender();
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path        = path_get(getInputData(0));
		var current_tag = getInputData(2);
		
		outputs[| 2].setValue(path);
		
		if(path_current != path) updatePaths(path);
		if(ds_map_empty(content)) return;
		
		var tag = noone;
		for( var i = 0, n = array_length(tags); i < n; i++ ) {
			if(tags[i][? "Name"] == current_tag) {
				tag = tags[i];
				break;
			}
		}
		
		_tag_delay = 0;
		for( var i = 0; i < ds_list_size(inputs[| 2].animator.values); i++ ) {
			var kf = inputs[| 2].animator.values[| i];
			if(kf.time > CURRENT_FRAME) break;
			_tag_delay = kf.time;
		}
		
		var vis = attributes.layer_visible;
		var ww = content[? "Width"];
		var hh = content[? "Height"];
		
		var surf = outputs[| 0].getValue();
		    surf = surface_verify(surf, ww, hh);
		outputs[| 0].setValue(surf);
		
		surface_set_target(surf);
			DRAW_CLEAR
		
			for( var i = 0, n = array_length(layers); i < n; i++ ) {
				layers[i].tag = tag;
				var cel = layers[i].getCel(CURRENT_FRAME - _tag_delay);
				if(!cel) continue;
				if(!array_safe_get_fast(vis, i, true)) continue;
			
				var _inSurf = cel.getSurface();
				if(!is_surface(_inSurf)) 
					continue;
			
				var xx = cel.data[? "X"];
				var yy = cel.data[? "Y"];
			
				draw_surface_safe(_inSurf, xx, yy);
			}
		surface_reset_target();
	} #endregion
	
	static attributeSerialize = function() { #region
		var att = {};
		att.layer_visible = attributes.layer_visible;
		
		return att;
	} #endregion
	
	static attributeDeserialize = function(attr) { #region
		struct_append(attributes, attr); 
		
		if(struct_has(attr, "layer_visible"))
			attributes.layer_visible = attr.layer_visible;
	} #endregion
}