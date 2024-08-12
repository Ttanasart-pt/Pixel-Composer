function Node_Vector_Dot(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Dot Product";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	inputs[0] = nodeValue_Vec2("Point 1", self, [ 0, 0 ])
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Vec2("Point 2", self, [ 0, 0 ])
		.setVisible(true, true);
		
	outputs[0] = nodeValue_Output("Result", self, VALUE_TYPE.float, 0 );
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _pnt1 = _data[0];
		var _pnt2 = _data[1];
		
		if(array_length(_pnt1) == 2) {
			inputs[0].editWidget.size = 2;
			inputs[1].editWidget.size = 2;
			
			return dot_product(array_safe_get_fast(_pnt1, 0), array_safe_get_fast(_pnt1, 1), 
							   array_safe_get_fast(_pnt2, 0), array_safe_get_fast(_pnt2, 1));
							   
		} else if(array_length(_pnt1) == 3) {
			inputs[0].editWidget.size = 3;
			inputs[1].editWidget.size = 3;
			
			return dot_product_3d(array_safe_get_fast(_pnt1, 0), array_safe_get_fast(_pnt1, 1), array_safe_get_fast(_pnt1, 2), 
							      array_safe_get_fast(_pnt2, 0), array_safe_get_fast(_pnt2, 1), array_safe_get_fast(_pnt2, 2), );
		}
		
		return 0;
	}
}