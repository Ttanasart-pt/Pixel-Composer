function Node_create_ASE_File_Read(_x, _y, _group = noone) { #region
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename("aseprite|*.ase", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_ASE_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
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
	update_on_frame = true;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "Aseprite file|*.ase;*.aseprite" });
		
	inputs[| 1]  = nodeValue("Generate layers", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0)
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", onClick: function() { refreshLayers(); } });
	
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
			
			var vis = array_safe_get(_vis, i, true);
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
		var lb_h = line_get_height(f_p0);
		var lb_y = _y + lb_h / 2 + ui(6);
		
		var by = _y;
		var hh = 32;
		var _h = lb_h + hh * amo + 16;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, by, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		var index = inputs[| 2].isLeaf()? inputs[| 2].is_anim : 2;
		draw_sprite_ui_uniform(THEME.animate_clock, index, abx, lb_y, 1, index == 2? COLORS._main_accent : c_white, 0.8);
		if(_hover && point_in_circle(_m[0], _m[1], abx, lb_y, ui(10))) {
			draw_sprite_ui_uniform(THEME.animate_clock, index, abx, lb_y, 1, index == 2? COLORS._main_accent : c_white, 1);
			TOOLTIP = "Toggle animation";
					
			if(mouse_press(mb_left, _focus)) {
				if(inputs[| 2].value_from != noone)
					inputs[| 2].removeFrom();
				else
					inputs[| 2].setAnim(!inputs[| 2].is_anim);
			}
		}
		
		for( var i = 0, n = array_length(tags); i < n; i++ ) {
			var _yy = by + lb_h + 8 + i * hh;
			var tag = tags[i];
			
			var st = tag[? "Frame start"];
			var ed = tag[? "Frame end"];
			var rn = ed - st + 1;
			var progFr = safe_mod(CURRENT_FRAME - _tag_delay, rn) + 1;
			var prog = progFr / rn;
			var txt = "";
			
			if(tag[? "Name"] == current_tag) {
				draw_sprite_stretched_ext(THEME.node_bg_name, 1, _x + 8, _yy, _w - 16, hh, tag[? "Color"], 0.5);
				draw_sprite_stretched_ext(THEME.node_bg_name, 1, _x + 8, _yy, (_w - 16) * prog, hh, tag[? "Color"], 1.0);
				
				txt += string(progFr) + "/";
			} else 
				draw_sprite_stretched_ext(THEME.node_bg_name, 1, _x + 8, _yy, 8, hh, tag[? "Color"], 1.0);
			txt += string(rn);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x + 8, _yy, _x + _w - 8, _yy + hh)) {
				draw_sprite_stretched_ext(THEME.node_bg_name, 1, _x + 8, _yy, _w - 16, hh, c_white, 0.1);
				if(mouse_click(mb_left, _focus)) {
					var _currTag = getInputData(2);
					var _tagName = tag[? "Name"];
					inputs[| 2].setValue(_currTag == _tagName? "" : _tagName);
				}
			}
			
			draw_set_text(f_p1, fa_left, fa_center, tag[? "Name"] == current_tag? tag[? "Color"] : COLORS._main_text);
			draw_text(_x + 24, _yy + hh / 2, tag[? "Name"]);
			
			draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
			draw_text(_x + _w - 20, _yy + hh / 2, txt);
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
	
	content = ds_map_create();
	layers = [];
	tags = [];
	_tag_delay = 0;
	path_current = "";
	
	first_update = false;
	
	on_drop_file = function(path) { #region
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		return false;
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
	
	function updatePaths(path) { #region
		path_current = path;
		
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".ase" && ext != ".aseprite") return false;
			
		outputs[| 2].setValue(path);
		
		read_ase(path, content);
		
		layers = [];
		var vis = attributes.layer_visible;
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
		
		return true;
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		var path = getInputData(0);
		if(path == "") return;
		updatePaths(path);
		update();
		
		for( var j = 0; j < array_length(outputs[| 1].value_to); j++ ) {
			var _targNode = outputs[| 1].value_to[j].node;
			_targNode._name = "";
			_targNode.update();
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = getInputData(0);
		var current_tag = getInputData(2);
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
			if(!array_safe_get(vis, i, true)) continue;
			
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
		if(struct_has(attr, "layer_visible"))
			attributes.layer_visible = attr.layer_visible;
	} #endregion
}