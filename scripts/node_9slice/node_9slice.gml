function Node_9Slice(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Nine Slice";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Dimension(self));
	
	newInput(2, nodeValue_Padding("Splice", self, [ 0, 0, 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(3, nodeValue_Enum_Scroll("Filling modes", self, 0, [ "Scale", "Repeat" ]));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_interpolation();
	
	input_display_list = [
		["Surface", false], 0, 
		["Slices",  false], 1, 2, 3, 
	]
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	static onValueFromUpdate = function(index = 0) {
		if(index != 0) return;
		
		var s = getInputData(0);
		if(is_array(s)) s = s[0];
			
		if(!is_surface(s)) return;
		inputs[1].setValue( [ surface_get_width_safe(s), surface_get_height_safe(s) ] );
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _dim		= current_data[1];
		
		var _splice		= array_create(array_length(current_data[2]));
		for( var i = 0, n = array_length(current_data[2]); i < n; i++ )
			_splice[i] = round(current_data[2][i]);
			
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
			draw_set_color(c_white);
			switch(drag_side) {
				case 0 : draw_line_width(sp_r, -hh, sp_r, hh, 3); break;
				case 1 : draw_line_width(-ww, sp_t, ww, sp_t, 3); break;
				case 2 : draw_line_width(sp_l, -hh, sp_l, hh, 3); break;
				case 3 : draw_line_width(-ww, sp_b, ww, sp_b, 3); break;
			}
			
			var vv;
			
			if(drag_side == 0)		vv = drag_sv - (_mx - drag_mx) / _s;
			else if(drag_side == 2)	vv = drag_sv + (_mx - drag_mx) / _s;
			else if(drag_side == 1)	vv = drag_sv + (_my - drag_my) / _s;
			else					vv = drag_sv - (_my - drag_my) / _s;
				
			_splice[drag_side] = vv;
			if(inputs[2].setValue(_splice))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_side = -1;
				UNDO_HOLDING = false;
			}
		}
		
		if(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)) return;
		if(!hover) return;
		if(drag_side > -1) return;
		
		draw_set_color(COLORS._main_accent);
		
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
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _inSurf		= _data[0];
		var _dim		= _data[1];
		var _splice		= _data[2];
		var _fill		= _data[3];
		
		if(!surface_exists(_inSurf)) return;
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_inSurf);
			var ww   = _dim[0];
			var hh   = _dim[1];
			var in_w = surface_get_width_safe(_inSurf);
			var in_h = surface_get_height_safe(_inSurf);
			var sp_r = _splice[0];
			var sp_t = _splice[1];
			var sp_l = _splice[2];
			var sp_b = _splice[3];
			
			var cw = max(in_w - sp_l - sp_r, 1);
			var ch = max(in_h - sp_t - sp_b, 1);
			
			var sw = (ww - sp_l - sp_r) / cw;
			var sh = (hh - sp_t - sp_b) / ch;

			draw_surface_part_ext_safe(_inSurf,           0,           0, sp_l, sp_t,         0,         0, 1, 1, 0, c_white, 1);
			draw_surface_part_ext_safe(_inSurf, in_w - sp_r,           0, sp_r, sp_t, ww - sp_r,         0, 1, 1, 0, c_white, 1);
			draw_surface_part_ext_safe(_inSurf,           0, in_h - sp_b, sp_l, sp_b,         0, hh - sp_b, 1, 1, 0, c_white, 1);
			draw_surface_part_ext_safe(_inSurf, in_w - sp_r, in_h - sp_b, sp_r, sp_b, ww - sp_r, hh - sp_b, 1, 1, 0, c_white, 1);
			
			if(_fill == 0) {
				draw_surface_part_ext_safe(_inSurf, sp_l,           0, cw, sp_t, sp_l,         0, sw, 1, 0, c_white, 1);
				draw_surface_part_ext_safe(_inSurf, sp_l, in_h - sp_b, cw, sp_b, sp_l, hh - sp_b, sw, 1, 0, c_white, 1);
	
				draw_surface_part_ext_safe(_inSurf,           0, sp_t, sp_l, ch,         0, sp_t, 1, sh, 0, c_white, 1);
				draw_surface_part_ext_safe(_inSurf, in_w - sp_r, sp_t, sp_r, ch, ww - sp_r, sp_t, 1, sh, 0, c_white, 1);
    
				draw_surface_part_ext_safe(_inSurf, sp_l, sp_t, cw, ch, sp_l, sp_t, sw, sh, 0, c_white, 1);
			} else if(_fill == 1) {
				var _cw_max = ww - sp_r;
				var _ch_max = hh - sp_b;
				
				var _x = sp_l;
				while(_x < _cw_max) {
					draw_surface_part_ext_safe(_inSurf, sp_l,           0, min(cw, _cw_max - _x), sp_t, _x,         0, 1, 1, 0, c_white, 1);
					draw_surface_part_ext_safe(_inSurf, sp_l, in_h - sp_b, min(cw, _cw_max - _x), sp_b, _x, hh - sp_b, 1, 1, 0, c_white, 1);
					_x += cw;
				}
				
				var _y = sp_t;
				while(_y < _ch_max) {
					draw_surface_part_ext_safe(_inSurf,           0, sp_t, sp_l, min(ch, _ch_max - _y),         0, _y, 1, 1, 0, c_white, 1);
					draw_surface_part_ext_safe(_inSurf, in_w - sp_r, sp_t, sp_r, min(ch, _ch_max - _y), ww - sp_r, _y, 1, 1, 0, c_white, 1);
					_y += ch;
				}
				
				_x = sp_l;
				_y = sp_t;
				while(_x < _cw_max) {
					_y = sp_t;
					while(_y < _ch_max) {
						draw_surface_part_ext_safe(_inSurf, sp_l, sp_t, min(cw, _cw_max - _x), min(ch, _ch_max - _y), _x, _y, 1, 1, 0, c_white, 1);
						_y += ch;
					}
					_x += cw;
				}
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}