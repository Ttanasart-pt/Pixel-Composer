function Node_Matrix_Det(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Det";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", self, new Matrix(3)))
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Determinant", self, CONNECT_TYPE.output, VALUE_TYPE.float, 0));
	
	square_label = new Inspector_Label("");
	input_display_list = [ 0, square_label ];
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) {
		var _mat = _data[0];
		square_label.text = _mat.isSquare()? "" : "Cannot find determinant for non-square matrix.";
		
		return _mat.det();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_matrix_det, 0, bbox);
	}
}