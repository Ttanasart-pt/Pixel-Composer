function Node_Vector_Cross_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Cross Product 3D";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Point 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Point 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
		
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var vec1 = _data[0];
		var vec2 = _data[1];
		
		var _x = vec1[1] * vec2[2] - vec1[2] * vec2[1];
	    var _y = vec1[2] * vec2[0] - vec1[0] * vec2[2];
	    var _z = vec1[0] * vec2[1] - vec1[1] * vec2[0];
	    return [ _x, _y, _z ];
	}
}