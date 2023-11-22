function Node_Crop(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Crop";
	preview_alpha = 0.5;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Crop", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Effect", false], 0, 1, 
	]
	
	attribute_surface_depth();
	
	drag_side = noone;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	static getPreviewValues = function() { return getInputData(0); }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny, params) { #region
		if(array_length(current_data) < 2) return;
		
		var _inSurf	= current_data[0];
		var _splice	= current_data[1];
		_splice = array_clone(_splice);
		for( var i = 0, n = array_length(_splice); i < n; i++ )
			_splice[i] = round(_splice[i]);
		
		var dim = [ surface_get_width_safe(_inSurf), surface_get_height_safe(_inSurf) ]
		
		var sp_r = _x + (dim[0] - _splice[0]) * _s;
		var sp_l = _x + _splice[2] * _s;
		
		var sp_t = _y + _splice[1] * _s;
		var sp_b = _y + (dim[1] - _splice[3]) * _s;
		
		var _out = outputs[| 0].getValue();
		draw_surface_ext_safe(_out, sp_l, sp_t, _s, _s);
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.50);
		draw_line(sp_r, 0, sp_r, params.h);
		draw_line(sp_l, 0, sp_l, params.h);
		draw_line(0, sp_t, params.w, sp_t);
		draw_line(0, sp_b, params.w, sp_b);
		draw_set_alpha(1);
		
		draw_line_width(sp_r, sp_t - 1, sp_r, sp_b + 1, 2);
		draw_line_width(sp_l, sp_t - 1, sp_l, sp_b + 1, 2);
		draw_line_width(sp_l - 1, sp_t, sp_r + 1, sp_t, 2);
		draw_line_width(sp_l - 1, sp_b, sp_r + 1, sp_b, 2);
		
		var _hov = noone;
		
		if(drag_side != noone) {
			var vv;
			
			if(drag_side < 4) {
				     if(drag_side == 0)	vv = value_snap(drag_sv - (_mx - drag_mx) / _s, _snx);
				else if(drag_side == 1)	vv = value_snap(drag_sv + (_my - drag_my) / _s, _sny);
				else if(drag_side == 2)	vv = value_snap(drag_sv + (_mx - drag_mx) / _s, _snx);
				else if(drag_side == 3)	vv = value_snap(drag_sv - (_my - drag_my) / _s, _sny);
				
				_splice[drag_side] = vv;
			} else if(drag_side < 8) {
				if(drag_side == 4)	{
					_splice[2] = value_snap(drag_sv[2] + (_mx - drag_mx) / _s, _snx);
					_splice[1] = value_snap(drag_sv[1] + (_my - drag_my) / _s, _sny);
				} else if(drag_side == 5)	{
					_splice[0] = value_snap(drag_sv[0] - (_mx - drag_mx) / _s, _snx);
					_splice[1] = value_snap(drag_sv[1] + (_my - drag_my) / _s, _sny);
				} else if(drag_side == 6)	{
					_splice[2] = value_snap(drag_sv[2] + (_mx - drag_mx) / _s, _snx);
					_splice[3] = value_snap(drag_sv[3] - (_my - drag_my) / _s, _sny);
				} else if(drag_side == 7)	{
					_splice[0] = value_snap(drag_sv[0] - (_mx - drag_mx) / _s, _snx);
					_splice[3] = value_snap(drag_sv[3] - (_my - drag_my) / _s, _sny);
				}
			} else if(drag_side == 8) {
				_splice[0] = value_snap(drag_sv[0] - (_mx - drag_mx) / _s, _snx);
				_splice[1] = value_snap(drag_sv[1] + (_my - drag_my) / _s, _sny);
				_splice[2] = value_snap(drag_sv[2] + (_mx - drag_mx) / _s, _snx);
				_splice[3] = value_snap(drag_sv[3] - (_my - drag_my) / _s, _sny);
			}
			
			if(inputs[| 1].setValue(_splice))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left, active)) {
				drag_side    = noone;
				UNDO_HOLDING = false;
			}
		}
		
		draw_set_color(merge_color(c_white, COLORS._main_accent, 0.5));
		
		if(drag_side == 4 || point_in_circle(_mx, _my, sp_l, sp_t, 12)) {
			draw_line_width(sp_l, 0, sp_l, params.h, 4);
			draw_line_width(0, sp_t, params.w, sp_t, 4);
			draw_sprite_colored(THEME.anchor_selector, 1, sp_l, sp_t);
			_hov = 4;
		} else if(drag_side == 5 || point_in_circle(_mx, _my, sp_r, sp_t, 12)) {
			draw_line_width(sp_r, 0, sp_r, params.h, 4);
			draw_line_width(0, sp_t, params.w, sp_t, 4);
			draw_sprite_colored(THEME.anchor_selector, 1, sp_r, sp_t);
			_hov = 5;
		} else if(drag_side == 6 || point_in_circle(_mx, _my, sp_l, sp_b, 12)) {
			draw_line_width(sp_l, 0, sp_l, params.h, 4);
			draw_line_width(0, sp_b, params.w, sp_b, 4);
			draw_sprite_colored(THEME.anchor_selector, 1, sp_l, sp_b);
			_hov = 6;
		} else if(drag_side == 7 || point_in_circle(_mx, _my, sp_r, sp_b, 12)) {
			draw_line_width(sp_r, 0, sp_r, params.h, 4);
			draw_line_width(0, sp_b, params.w, sp_b, 4);
			draw_sprite_colored(THEME.anchor_selector, 1, sp_r, sp_b);
			_hov = 7;
		} else if(drag_side == 0 || distance_to_line(_mx, _my, sp_r, 0, sp_r, params.h) < 12) {
			draw_line_width(sp_r, 0, sp_r, params.h, 4);
			_hov = 0;
		} else if(drag_side == 1 || distance_to_line(_mx, _my, 0, sp_t, params.w, sp_t) < 12) {
			draw_line_width(0, sp_t, params.w, sp_t, 4);
			_hov = 1;
		} else if(drag_side == 2 || distance_to_line(_mx, _my, sp_l, 0, sp_l, params.h) < 12) {
			draw_line_width(sp_l, 0, sp_l, params.h, 4);
			_hov = 2;
		} else if(drag_side == 3 || distance_to_line(_mx, _my, 0, sp_b, params.w, sp_b) < 12) {
			draw_line_width(0, sp_b, params.w, sp_b, 4);
			_hov = 3;
		} else if(drag_side == 8 || point_in_rectangle(_mx, _my, sp_l, sp_t, sp_r, sp_b)) {
			draw_line_width(sp_r, sp_t - 1, sp_r, sp_b + 1, 4);
			draw_line_width(sp_l, sp_t - 1, sp_l, sp_b + 1, 4);
			draw_line_width(sp_l - 1, sp_t, sp_r + 1, sp_t, 4);
			draw_line_width(sp_l - 1, sp_b, sp_r + 1, sp_b, 4);
			_hov = 8;
		}
		
		if(_hov != 4) draw_sprite_colored(THEME.anchor_selector, 0, sp_l, sp_t);
		if(_hov != 5) draw_sprite_colored(THEME.anchor_selector, 0, sp_r, sp_t);
		if(_hov != 6) draw_sprite_colored(THEME.anchor_selector, 0, sp_l, sp_b);
		if(_hov != 7) draw_sprite_colored(THEME.anchor_selector, 0, sp_r, sp_b);
		
		if(drag_side == noone && _hov != noone) {
			if(mouse_press(mb_left, active)) {
				drag_side = _hov;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _hov < 4? _splice[_hov] : _splice;
			}
		}
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _inSurf		= _data[0];
		var _crop		= _data[1];
		var _dim		= [ surface_get_width_safe(_inSurf) - _crop[0] - _crop[2], surface_get_height_safe(_inSurf) - _crop[1] - _crop[3] ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, noone);
			draw_surface_safe(_inSurf, -_crop[2], -_crop[1]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}