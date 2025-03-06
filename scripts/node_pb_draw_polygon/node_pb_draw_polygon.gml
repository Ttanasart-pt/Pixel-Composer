function Node_PB_Draw_Polygon(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Polygon";
	
	newInput(pbi+0, nodeValue_i("Sides", self, 3));
	
	newInput(pbi+1, nodeValue_r("Angle", self, 0));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, pbi+1, 
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _side = _data[pbi+0];
		var _angl = _data[pbi+1];
		
		var _cx = (_x0 + _x1) / 2;
		var _cy = (_y0 + _y1) / 2;
		
		var _hw = (_x1 - _x0) / 2;
		var _hh = (_y1 - _y0) / 2;
		
		var _st = 360 / _side;
		
		draw_primitive_begin(pr_trianglelist);
		
		for( var i = 0; i < _side; i++ ) {
		    var _a0 = _angl + i * _st;
		    var _ox = _cx + lengthdir_x(_hw, _a0);
		    var _oy = _cy + lengthdir_y(_hh, _a0);
		    
		    var _a1 = _a0 + _st;
		    var _nx = _cx + lengthdir_x(_hw, _a1);
		    var _ny = _cy + lengthdir_y(_hh, _a1);
		    
		    draw_vertex(_cx, _cy);
		    draw_vertex(_ox, _oy);
		    draw_vertex(_nx, _ny);
		}
		
		draw_primitive_end();
	}
}