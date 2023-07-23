function Node_PB_Draw_Rectangle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Rectangle";
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			
			draw_set_color(_fcol);
			draw_rectangle(0, 0, _pbox.w - 1, _pbox.h - 1, false);
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();
		
		PB_DRAW_CREATE_MASK
		
		return _nbox;
	}
}