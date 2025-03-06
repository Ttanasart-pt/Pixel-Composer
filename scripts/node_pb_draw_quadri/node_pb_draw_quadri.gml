function Node_PB_Draw_Quadrilateral(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Quadrilateral";
	
	newInput(pbi+0, nodeValue_2("Top Left",     self, [ 0.0, 0.0 ]));
	newInput(pbi+1, nodeValue_2("Top Right",    self, [ 1.0, 0.0 ]));
	newInput(pbi+2, nodeValue_2("Bottom Left",  self, [ 0.0, 1.0 ]));
	newInput(pbi+3, nodeValue_2("Bottom Right", self, [ 1.0, 1.0 ]));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, pbi+1, pbi+2, pbi+3
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _tl = _data[pbi+0];
		var _tr = _data[pbi+1];
		var _bl = _data[pbi+2];
		var _br = _data[pbi+3];
		
		var _px0 = lerp(_x0, _x1, _tl[0]);
		var _py0 = lerp(_y0, _y1, _tl[1]);
		
		var _px1 = lerp(_x0, _x1, _tr[0]);
		var _py1 = lerp(_y0, _y1, _tr[1]);
		
		var _px2 = lerp(_x0, _x1, _bl[0]);
		var _py2 = lerp(_y0, _y1, _bl[1]);
		
		var _px3 = lerp(_x0, _x1, _br[0]);
		var _py3 = lerp(_y0, _y1, _br[1]);
		
		draw_rectangle_points(_px0, _py0, _px1, _py1, _px2, _py2, _px3, _py3);
	}
}