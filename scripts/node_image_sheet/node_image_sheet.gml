function Node_create_Image_Sheet(_x, _y) {
	var node = new Node_Image_Sheet(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Image_Sheet(_x, _y) : Node(_x, _y) constructor {
	name  = "Splice sprite";
	always_output = true;
	
	surf_array = [];
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.setAcceptArray(false);
	
	inputs[| 1]  = nodeValue(1, "Sprite size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 32 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2]  = nodeValue(2, "Sprite amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	inputs[| 3]  = nodeValue(3, "Sprite per row", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 4]  = nodeValue(4, "Offset", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5]  = nodeValue(5, "Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6]  = nodeValue(6, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 7]  = nodeValue(7, "Output", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Animation", "Array"]);
	
	inputs[| 8]  = nodeValue(8, "Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 9]  = nodeValue(9, "Orientation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical"]);
	
	inputs[| 10] = nodeValue(10, "Auto fill", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { 
			var _sur = inputs[| 0].getValue();
			if(!is_surface(_sur) || _sur == DEF_SURFACE) return;
			var ww = surface_get_width(_sur);
			var hh = surface_get_height(_sur);
		
			var _size = inputs[| 1].getValue();
			var _offs = inputs[| 4].getValue();
			var _spac = inputs[| 5].getValue();
			var _orie = inputs[| 9].getValue();
		
			var sh_w = _size[0] + _spac[0];
			var sh_h = _size[1] + _spac[1];
		
			var fill_w = floor((ww - _offs[0]) / sh_w);
			var fill_h = floor((hh - _offs[1]) / sh_h);
		
			var amo = fill_w * fill_h, row;
			if(_orie == 0) {
				row = fill_w;
			} else {
				row = fill_h;
			}
		
			inputs[| 2].setValue(amo);
			inputs[| 3].setValue(row);
		
			doUpdate(); 
		}, "Generate"] );
	
	input_display_list = [
		["Sprite", false],	0, 1, 6, 
		["Sheet",  false],	2, 3, 9, 10, 4, 5, 
		["Output", false],	7, 8
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	tools = [
		[ "Draw boundary",		s_splice_draw ]
	];
	
	bound_drag = 0;
	bound_sx = 0;
	bound_sy = 0;
	bound_mx = 0;
	bound_my = 0;
	
	cell_sx = 0;
	cell_sy = 0;
	cell_cx = 0;
	cell_cy = 0;
	cell_mx = 0;
	cell_my = 0;
	
	function getSpritePosition(index) {
		var _dim = inputs[| 1].getValue();
		var _col = inputs[| 3].getValue();
		var _off = inputs[| 4].getValue();
		var _spa = inputs[| 5].getValue();
		var _ori = inputs[| 9].getValue();
		
		var _irow = floor(index / _col);
		var _icol = safe_mod(index, _col);
		
		var _x, _y;
		
		var _x = _off[0] + _icol * (_dim[0] + _spa[0]);
		var _y = _off[1] + _irow * (_dim[1] + _spa[1]);
		
		if(_ori == 0)
			return [_x, _y];
		else
			return [_y, _x];
	}
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		if(inputs[| 0].value_from == noone) return;
		var _inSurf  = inputs[| 0].getValue();
		
		var _dim = inputs[| 1].getValue();
		var _amo = inputs[| 2].getValue();
		var _off = inputs[| 4].getValue();
		
		var _out = inputs[| 7].getValue();
		var _pad = inputs[| 6].getValue();
		var _spd = inputs[| 8].getValue();
		
		var ii;
		if(_out == 0)
			ii = safe_mod(ANIMATOR.current_frame * _spd, _amo);
		else
			ii = preview_index;
		var _spr_pos = getSpritePosition(ii);
			
		var _orig_x = _x - (_spr_pos[0] - _pad[2]) * _s;
		var _orig_y = _y - (_spr_pos[1] - _pad[1]) * _s;
			
		draw_surface_ext_safe(_inSurf, _orig_x, _orig_y, _s, _s, 0 ,c_white, 0.25);
		
		for(var i = 0; i < _amo; i++) {
			var _f = getSpritePosition(i);
			var _fx0 = _orig_x + (_f[0] - _pad[2]) * _s;
			var _fy0 = _orig_y + (_f[1] - _pad[1]) * _s;
			var _fx1 = _fx0 + _dim[0] * _s;
			var _fy1 = _fy0 + _dim[1] * _s;
			
			draw_set_color(c_ui_orange);
			draw_rectangle(_fx0, _fy0, _fx1, _fy1, true);
			
			draw_set_text(f_p1, fa_left, fa_top);
			draw_text(_fx0 + 2, _fy0 + 2, string(i));
		}
		
		var _tool = PANEL_PREVIEW.tool_index;
		var _ex = (_mx - _x) / _s;
		var _ey = (_my - _y) / _s;
		
		if(_tool == 0) {
			if(bound_drag) {
				if(keyboard_check(vk_shift)) {
					cell_cx = max(2, round(cell_sx + (_ex - cell_mx)));
					cell_cy = max(2, round(cell_sy + (_ey - cell_my)));
				} else {
					bound_mx = _ex;
					bound_my = _ey;	
					
					cell_mx = _ex;
					cell_my = _ey;
				}
				
				var fr_x0 = _x + bound_sx * _s;
				var fr_y0 = _y + bound_sy * _s;
				var fr_x1 = _x + bound_mx * _s;
				var fr_y1 = _y + bound_my * _s;
				
				var col = floor((bound_mx - bound_sx) / cell_cx);
				var row = floor((bound_my - bound_sy) / cell_cy);
					
				draw_set_color(c_ui_orange_light);
				for( var i = 0; i < row; i++ ) {
					for( var j = 0; j < col; j++ ) {
						var cl_x0 = fr_x0 + j * (cell_cx * _s);
						var cl_y0 = fr_y0 + i * (cell_cy * _s);
						var cl_x1 = cl_x0 + (cell_cx * _s);
						var cl_y1 = cl_y0 + (cell_cy * _s);
						
						draw_rectangle(cl_x0, cl_y0, cl_x1 - 1, cl_y1 - 1, 1);
					}
				}
				
				draw_set_color(c_ui_orange);
				draw_line_width(fr_x0, 0, fr_x0, room_height, 1);
				draw_line_width(0, fr_y0, room_width, fr_y0, 1);
				draw_line_width(fr_x1, 0, fr_x1, room_height, 1);
				draw_line_width(0, fr_y1, room_width, fr_y1, 1);
					
				if(mouse_check_button_released(mb_left)) {
					bound_drag = 0;
					
					if(row && col) {
						inputs[| 1].setValue([ cell_cx, cell_cy ]);
						inputs[| 2].setValue(row * col);
						inputs[| 3].setValue(col);
						inputs[| 4].setValue([ bound_sx + _off[0], bound_sy + _off[1]]);
					}
				}
			} else {
				if(_active) {
					if(mouse_check_button_pressed(mb_left)) {
						bound_drag = 1;
						bound_sx = _ex;
						bound_sy = _ey;
						
						cell_cx = _dim[0];
						cell_cy = _dim[1];
						cell_sx = _dim[0];
						cell_sy = _dim[1];
					}
				}
			}
		}
	}
	
	static update = function() {
		if(inputs[| 0].value_from == noone) return;
		var _inSurf  = inputs[| 0].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		
		var _dim	= inputs[| 1].getValue();
		var _amo	= inputs[| 2].getValue();
		var _pad	= inputs[| 6].getValue();
		
		var ww   = _dim[0] + _pad[0] + _pad[2];
		var hh   = _dim[1] + _pad[1] + _pad[3];
		
		var _out = inputs[| 7].getValue();
		
		if(_out == 0) {
			update_on_frame = true;
			inputs[| 8].show_in_inspector	= true;
			var _spd = inputs[| 8].getValue();
			
			if(is_surface(_outSurf)) 
				surface_size_to(_outSurf, ww, hh);
			else {
				_outSurf = surface_create(ww, hh);
				outputs[| 0].setValue(_outSurf);
			}
			
			var ii = safe_mod(ANIMATOR.current_frame * _spd, _amo);
			var _spr_pos = getSpritePosition(ii);
			
			surface_set_target(_outSurf);
				draw_clear_alpha(c_black, 0);
				BLEND_ADD
				draw_surface_part(_inSurf, _spr_pos[0], _spr_pos[1], _dim[0], _dim[1], _pad[2], _pad[1]);
				BLEND_NORMAL
			surface_reset_target();
		} else if(_out == 1) {
			update_on_frame = false;
			inputs[| 8].show_in_inspector	= false;
			
			surf_array = array_create(_amo);
			for(var i = 0; i < _amo; i++) {
				surf_array[i] = surface_create(ww, hh);
				var _spr_pos = getSpritePosition(i);
				
				surface_set_target(surf_array[i]);
					draw_clear_alpha(c_black, 0);
					BLEND_ADD
					draw_surface_part(_inSurf, _spr_pos[0], _spr_pos[1], _dim[0], _dim[1], _pad[2], _pad[1]);
					BLEND_NORMAL
				surface_reset_target();
			}
			outputs[| 0].setValue(surf_array);
		}
		
	}
	doUpdate();
}