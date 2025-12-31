function Node_Matrix_Det(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Det";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_det);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3))).setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Determinant", VALUE_TYPE.float, 0));
	
	////- Nodes
	
	square_label       = new Inspector_Label("");
	input_display_list = [ 0, square_label ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		square_label.text = _mat.isSquare()? "" : "Cannot find determinant for non-square matrix.";
		
		return _mat.det();
	}
	
}