function Node_Vector_Dot(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Dot Product";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Point 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Point 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 );
	
	static process_data = function(_output, _data, _output_index, _array_index = 0) {  
		var _pnt1 = _data[0];
		var _pnt2 = _data[1];
		
		if(array_length(_pnt1) == 2) {
			inputs[| 0].editWidget.size = 2;
			inputs[| 1].editWidget.size = 2;
			
			return dot_product(array_safe_get(_pnt1, 0), array_safe_get(_pnt1, 1), 
							   array_safe_get(_pnt2, 0), array_safe_get(_pnt2, 1));
							   
		} else if(array_length(_pnt1) == 3) {
			inputs[| 0].editWidget.size = 3;
			inputs[| 1].editWidget.size = 3;
			
			return dot_product_3d(array_safe_get(_pnt1, 0), array_safe_get(_pnt1, 1), array_safe_get(_pnt1, 2), 
							      array_safe_get(_pnt2, 0), array_safe_get(_pnt2, 1), array_safe_get(_pnt2, 2), );
		}
		
		return 0;
	}
}