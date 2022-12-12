function Node_create_9Slice(_x, _y) {
	var node = new Node_9Slice(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_9Slice(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Nine slice";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Splice", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 3] = nodeValue(3, "Filling modes", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Scale", "Repeat" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	static updateValueFrom = function(index) {
		if(index == 0) {
			var s = inputs[| 0].getValue();
			if(is_array(s)) s = s[0];
			inputs[| 1].setValue([surface_get_width(s), surface_get_height(s)]);	
		}
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		var _dim		= inputs[| 1].getValue();
		var _splice		= inputs[| 2].getValue();
		
		var sp_r = _x + (_dim[0] - _splice[0]) * _s;
		var sp_l = _x + _splice[2] * _s;
		
		var sp_t = _y + _splice[1] * _s;
		var sp_b = _y + (_dim[1] - _splice[3]) * _s;
		
		var ww = WIN_W;
		var hh = WIN_H;
		
		draw_set_color(COLORS._main_accent);
		draw_line(sp_r, -hh, sp_r, hh);
		draw_line(sp_l, -hh, sp_l, hh);
		draw_line(-ww, sp_t, ww, sp_t);
		draw_line(-ww, sp_b, ww, sp_b);
		
		if(drag_side > -1) {
			var vv;
			
			if(drag_side == 0)		vv = drag_sv - (_mx - drag_mx) / _s;
			else if(drag_side == 2)	vv = drag_sv + (_mx - drag_mx) / _s;
			else if(drag_side == 1)	vv = drag_sv + (_my - drag_my) / _s;
			else					vv = drag_sv - (_my - drag_my) / _s;
				
			_splice[drag_side] = vv;
			if(inputs[| 2].setValue(_splice))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_side = -1;
				UNDO_HOLDING = false;
			}
		}
		
		if(!inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my)) {
			if(distance_to_line_infinite(_mx, _my, sp_r, -hh, sp_r, hh) < 12) {
				draw_line_width(sp_r, -hh, sp_r, hh, 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 0;
					drag_mx   = _mx;
					drag_my   = _my;
					drag_sv   = _splice[0];
				}
			} else if(distance_to_line_infinite(_mx, _my, -ww, sp_t, ww, sp_t) < 12) {
				draw_line_width(-ww, sp_t, ww, sp_t, 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 1;
					drag_mx   = _mx;
					drag_my   = _my;
					drag_sv   = _splice[1];
				}
			} else if(distance_to_line_infinite(_mx, _my, sp_l, -hh, sp_l, hh) < 12) {
				draw_line_width(sp_l, -hh, sp_l, hh, 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 2;
					drag_mx   = _mx;
					drag_my   = _my;
					drag_sv   = _splice[2];
				}
			} else if(distance_to_line_infinite(_mx, _my, -ww, sp_b, ww, sp_b) < 12) {
				draw_line_width(-ww, sp_b, ww, sp_b, 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 3;
					drag_mx   = _mx;
					drag_my   = _my;
					drag_sv   = _splice[3];
				}
			}
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _inSurf		= _data[0];
		var _dim		= _data[1];
		var _splice		= _data[2];
		var _fill		= _data[3];
		
		if(!surface_exists(_inSurf)) return;
		surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			var ww   = _dim[0];
			var hh   = _dim[1];
			var in_w = surface_get_width(_inSurf);
			var in_h = surface_get_height(_inSurf);
			var sp_r = _splice[0];
			var sp_t = _splice[1];
			var sp_l = _splice[2];
			var sp_b = _splice[3];
			
			var cw = max(in_w - sp_l - sp_r, 1);
			var ch = max(in_h - sp_t - sp_b, 1);
			
			var sw = (ww - sp_l - sp_r) / cw;
			var sh = (hh - sp_t - sp_b) / ch;

			draw_surface_part_ext(_inSurf,           0,           0, sp_l, sp_t,         0,         0, 1, 1, c_white, 1);
			draw_surface_part_ext(_inSurf, in_w - sp_r,           0, sp_r, sp_t, ww - sp_r,         0, 1, 1, c_white, 1);
			draw_surface_part_ext(_inSurf,           0, in_h - sp_b, sp_l, sp_b,         0, hh - sp_b, 1, 1, c_white, 1);
			draw_surface_part_ext(_inSurf, in_w - sp_r, in_h - sp_b, sp_r, sp_b, ww - sp_r, hh - sp_b, 1, 1, c_white, 1);
			
			if(_fill == 0) {
				draw_surface_part_ext(_inSurf, sp_l,           0, cw, sp_t, sp_l,         0, sw, 1, c_white, 1);
				draw_surface_part_ext(_inSurf, sp_l, in_h - sp_b, cw, sp_b, sp_l, hh - sp_b, sw, 1, c_white, 1);
	
				draw_surface_part_ext(_inSurf,           0, sp_t, sp_l, ch,         0, sp_t, 1, sh, c_white, 1);
				draw_surface_part_ext(_inSurf, in_w - sp_r, sp_t, sp_r, ch, ww - sp_r, sp_t, 1, sh, c_white, 1);
    
				draw_surface_part_ext(_inSurf, sp_l, sp_t, cw, ch, sp_l, sp_t, sw, sh, c_white, 1);
			} else if(_fill == 1) {
				var _cw_max = ww - sp_r;
				var _ch_max = hh - sp_b;
				
				var _x = sp_l;
				while(_x < _cw_max) {
					draw_surface_part_ext(_inSurf, sp_l,           0, min(cw, _cw_max - _x), sp_t, _x,         0, 1, 1, c_white, 1);
					draw_surface_part_ext(_inSurf, sp_l, in_h - sp_b, min(cw, _cw_max - _x), sp_b, _x, hh - sp_b, 1, 1, c_white, 1);
					_x += cw;
				}
				
				var _y = sp_t;
				while(_y < _ch_max) {
					draw_surface_part_ext(_inSurf,           0, sp_t, sp_l, min(ch, _ch_max - _y),         0, _y, 1, 1, c_white, 1);
					draw_surface_part_ext(_inSurf, in_w - sp_r, sp_t, sp_r, min(ch, _ch_max - _y), ww - sp_r, _y, 1, 1, c_white, 1);
					_y += ch;
				}
				
				_x = sp_l;
				_y = sp_t;
				while(_x < _cw_max) {
					_y = sp_t;
					while(_y < _ch_max) {
						draw_surface_part_ext(_inSurf, sp_l, sp_t, min(cw, _cw_max - _x), min(ch, _ch_max - _y), _x, _y, 1, 1, c_white, 1);
						_y += ch;
					}
					_x += cw;
				}
			}
			
			BLEND_NORMAL
		surface_reset_target();
	}
}