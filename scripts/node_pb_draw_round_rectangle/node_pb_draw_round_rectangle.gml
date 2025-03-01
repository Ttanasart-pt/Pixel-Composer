function Node_PB_Draw_Round_Rectangle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Round Rectangle";
	
	newInput(pbi+0, nodeValue_Float("Corner Radius", self, 4));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0
	]);
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _rad = _data[pbi+0] * 2;
		
		draw_roundrect_ext(_x0, _y0, _x1, _y1, _rad, _rad, false);
	}
}