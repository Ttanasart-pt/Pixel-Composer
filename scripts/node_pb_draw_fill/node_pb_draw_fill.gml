function Node_PB_Draw_Fill(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Fill";
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		
		if(_output_index == 1)	return _pbox;
		if(_pbox == noone)		return noone;
		
		_outSurf = surface_verify(_outSurf, _pbox.layer_w, _pbox.layer_h);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_set_color(_fcol);
			draw_rectangle(_pbox.x, _pbox.y, _pbox.x + _pbox.w - 1, _pbox.y + _pbox.h - 1, false);
			
			if(_mask && is_surface(_pbox.mask)) {
				BLEND_MULTIPLY
					draw_surface(_pbox.mask, _pbox.x, _pbox.y);
				BLEND_NORMAL
			}
		surface_reset_target();
		
		return _outSurf;
	}
}