function Node_Vector_Cross_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Cross Product 3D";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec3("Point 1", [ 0, 0, 0 ]))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec3("Point 2", [ 0, 0, 0 ]))
		.setVisible(true, true);
		
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.float, [ 0, 0, 0 ] ))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static processData = function(_output, _data, _array_index = 0) {  
		var vec1 = _data[0];
		var vec2 = _data[1];
		
		var _x = vec1[1] * vec2[2] - vec1[2] * vec2[1];
	    var _y = vec1[2] * vec2[0] - vec1[0] * vec2[2];
	    var _z = vec1[0] * vec2[1] - vec1[1] * vec2[0];
	    return [ _x, _y, _z ];
	}
}