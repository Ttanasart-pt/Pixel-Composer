function Node_Matrix_Invert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Invert";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3)))
		.setVisible(true, true);
		
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Matrix", self, CONNECT_TYPE.output, VALUE_TYPE.float, new Matrix(3)))
		.setDisplay(VALUE_DISPLAY.matrix);
		
	square_label = new Inspector_Label("");
	input_display_list = [ 0, square_label ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		square_label.text = _mat.isSquare()? "" : "Non-square matrix is non-invertible";
		
		return _mat.invert();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_matrix_invert, 0, bbox);
	}
}