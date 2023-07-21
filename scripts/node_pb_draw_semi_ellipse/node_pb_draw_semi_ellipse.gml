function Node_PB_Draw_Semi_Ellipse(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Semi Ellipse";
	
	inputs[| 3] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, array_create(4, THEME.obj_hemicircle) );
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
		["Shape",	false], 3, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		var _side = _data[3];
		
		if(_output_index == 1)	return _pbox;
		if(_pbox == noone)		return noone;
		
		_outSurf = surface_verify(_outSurf, _pbox.layer_w, _pbox.layer_h);
		
		var s = surface_create_valid(_pbox.w, _pbox.h);
		
		switch(_side) {
			case 0 : if(_pbox.mirror_h) _side = 2; break;
			case 1 : if(_pbox.mirror_v) _side = 3; break;
			case 2 : if(_pbox.mirror_h) _side = 0; break;
			case 3 : if(_pbox.mirror_v) _side = 1; break;
		}
		
		surface_set_target(s);
			DRAW_CLEAR
			
			var x1 = _pbox.w;
			var y1 = _pbox.h;
			
			draw_set_circle_precision(64);
			draw_set_color(_fcol);
			switch(_side) {
				case 0 : draw_ellipse(-1, -1, x1 + _pbox.w - 1, y1 - 1, false);	break;
				case 1 : draw_ellipse(-1, -1, x1 - 1, y1 + _pbox.h - 1, false);	break;
				case 2 : draw_ellipse(-_pbox.w, -1, x1 - 1, y1 - 1, false);		break;
				case 3 : draw_ellipse(-1, -_pbox.h, x1 - 1, y1 - 1, false);		break;
			}
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_surface(s, ceil(_pbox.x), ceil(_pbox.y));
			surface_free(s);
			
			if(_mask && is_surface(_pbox.mask)) {
				BLEND_MULTIPLY
					draw_surface(_pbox.mask, ceil(_pbox.x), ceil(_pbox.y));
				BLEND_NORMAL
			}
		surface_reset_target();
		
		return _outSurf;
	}
}