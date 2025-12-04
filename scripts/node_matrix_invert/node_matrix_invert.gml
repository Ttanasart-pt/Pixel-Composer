function Node_Matrix_Invert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Invert";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_invert);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3)))
		.setVisible(true, true);
		
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3)))
		.setDisplay(VALUE_DISPLAY.matrix);
		
	square_label = new Inspector_Label("");
	input_display_list = [ 0, square_label ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		square_label.text = _mat.isSquare()? "" : "Non-square matrix is non-invertible";
		
		return _mat.invert();
	}
	
}