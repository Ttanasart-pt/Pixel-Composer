function Node_PB_Draw_Trapezoid(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Trapezoid";
	
	newInput(pbi+0, nodeValue_Enum_Button("Axis", self, 0, [ "+Y", "-Y", "+X", "-X" ]));
	
	newInput(pbi+1, nodeValue_Slider("Side", self, 0.5));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, pbi+1
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0];
		var _y0 = _bbox[1];
		var _x1 = _bbox[2];
		var _y1 = _bbox[3];
		
		var _axis = _data[pbi+0];
		var _side = _data[pbi+1] * .5;
		
		var _ww = _bbox[2] - _bbox[0];
		var _hh = _bbox[3] - _bbox[1];
		
		var _px0 = _x0 + (_axis == 0) * _side * _ww;
		var _py0 = _y0 + (_axis == 3) * _side * _hh;
		
		var _px1 = _x1 - (_axis == 0) * _side * _ww;
		var _py1 = _y0 + (_axis == 2) * _side * _hh;
		
		var _px2 = _x0 + (_axis == 1) * _side * _ww;
		var _py2 = _y1 - (_axis == 3) * _side * _hh;
		
		var _px3 = _x1 - (_axis == 1) * _side * _ww;
		var _py3 = _y1 - (_axis == 2) * _side * _hh;
		
		draw_primitive_begin(pr_trianglelist);
			draw_vertex(_px0, _py0);
			draw_vertex(_px1, _py1);
			draw_vertex(_px2, _py2);
			
			draw_vertex(_px1, _py1);
			draw_vertex(_px2, _py2);
			draw_vertex(_px3, _py3);
		draw_primitive_end();
	}
}