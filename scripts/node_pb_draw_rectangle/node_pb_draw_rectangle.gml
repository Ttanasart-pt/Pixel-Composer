function Node_PB_Draw_Rectangle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Rectangle";
	
	array_insert_array(input_display_list, input_display_shape_index, [
		
	]);
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0];
		var _y0 = _bbox[1];
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		draw_rectangle(_x0, _y0, _x1, _y1, false);
	}
}