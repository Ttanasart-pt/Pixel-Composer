function Node_IsoSurf(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "IsoSurf";
	
	inputs[| 0] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 1] = nodeValue("Surfaces", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(true, true)
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Angle Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Angle Split", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0 * 90, 1 * 90, 2 * 90, 3 * 90 ])
		.setArrayDynamic()
		.setArrayDepth(1);
	
	outputs[| 0] = nodeValue("IsoSurf", self, JUNCTION_CONNECT.output, VALUE_TYPE.dynaSurface, noone);
	
	knob_hover    = noone;
	knob_dragging = noone;
	drag_sv  = 0;
	drag_sa  = 0;
	
	angle_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var hh     = ui(240);
		var _surfs = getInputData(1);
		var _angle = getInputData(3);
		
		var _kx = _x + _w / 2;
		var _ky = _y + hh / 2;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, hh, COLORS.node_composite_bg_blend, 1);
		draw_sprite(THEME.rotator_bg, 0, _kx, _ky);
		
		var _khover = noone;
		
		for( var i = 0, n = array_length(_angle); i < n; i++ ) {
			var _ang = _angle[i];
			
			var _knx = _kx + lengthdir_x(ui(28), _ang);
			var _kny = _ky + lengthdir_y(ui(28), _ang);
			var _ind = (knob_dragging == noone && i == knob_hover) || knob_dragging == i;
			var _cc  = knob_dragging == i? COLORS._main_accent : c_white;
			draw_sprite_ext(THEME.rotator_knob, _ind, _knx, _kny, 1, 1, 0, _cc, 1);
			if(point_in_circle(_m[0], _m[1], _knx, _kny, ui(10)))
				_khover = i;
			
			var _knx = _kx + lengthdir_x(ui(44), _ang);
			var _kny = _ky + lengthdir_y(ui(44), _ang);
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_knx, _kny, _ang);
			
			var _knx = _kx + lengthdir_x(ui(84), _ang);
			var _kny = _ky + lengthdir_y(ui(84), _ang);
			
			var _surf = array_safe_get(_surfs, i, noone);
			if(is_surface(_surf)) {
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				var _ss = min(32 / _sw, 32 / _sh);
				draw_surface_ext(_surf, _knx - _sw * _ss / 2, _kny - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
			}
			
			draw_set_color(COLORS._main_text_sub);
			draw_rectangle(_knx - 16, _kny - 16, _knx + 16, _kny + 16, true);
		}
		
		knob_hover = _khover;
		
		if(knob_dragging == noone) {
			if(knob_hover >= 0 && mouse_press(mb_left, _focus)) {
				knob_dragging = knob_hover;
				drag_sv = _angle[knob_hover];
				drag_sa = _angle[knob_hover];
			}
		} else {
			var delta    = angle_difference(point_direction(_kx, _ky, _m[0], _m[1]), drag_sa);
			var real_val = round(delta + drag_sv);
			var val      = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
			_angle[knob_dragging] = val;
			
			if(inputs[| 3].setValue(_angle)) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left))
				knob_dragging = noone;
		}
		
		return hh;
	}); #endregion
	
	input_display_list = [
		["Iso",		  false], 0, 2, angle_renderer, 
		["Surfaces",  false], 1, 
	];
	
	static onValueUpdate = function(index) {
		if(index == 0) {
			var _amo = getInputData(0);
			var _ang = array_create(_amo);
			
			for( var i = 0, n = _amo; i < n; i++ ) 
				_ang[i] = 360 * (i / _amo);
			inputs[| 3].setValue(_ang);
		}
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _amo   = _data[0];
		var _surf  = _data[1];
		var _ashft = _data[2];
		var _angle = _data[3];
		var _iso   = new dynaSurf_iso();
		
		for( var i = 0; i < _amo; i++ ) 
			_iso.surfaces[i] = array_safe_get(_surf, i, noone);
		_iso.angles      = _angle;
		_iso.angle_shift = _ashft;
		
		return _iso;
	}
}