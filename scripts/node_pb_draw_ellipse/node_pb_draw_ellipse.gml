function Node_PB_Draw_Ellipse(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Ellipse";
	
	array_insert_array(input_display_list, input_display_shape_index, [
		
	]);
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _w = _x1 - _x0;
		var _h = _y1 - _y0;
		
		     if(_w <= 1 || _h <= 1) draw_line(_x0, _y0, _x1, _y1);
		else if(_w <= 2 || _h <= 2) draw_rectangle(_x0 + 1, _y0 + 1, _x1, _y1, false);
		else                        draw_ellipse(_x0, _y0, _x1, _y1, false);
	}
}