function Node_PB_Draw_Semi_Ellipse(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Semi Ellipse";
	
	inputs[3] = nodeValue_Enum_Button("Side", self,  0 , array_create(4, THEME.obj_hemicircle) );
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
		["Shape",	false], 3, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		var _side = _data[3];
		
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		switch(_side) {
			case 0 : if(_pbox.mirror_h) _side = 2; break;
			case 1 : if(_pbox.mirror_v) _side = 3; break;
			case 2 : if(_pbox.mirror_h) _side = 0; break;
			case 3 : if(_pbox.mirror_v) _side = 1; break;
		}
		
		surface_set_target(_nbox.content);
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
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();
		
		PB_DRAW_CREATE_MASK
		
		return _nbox;
	}
}