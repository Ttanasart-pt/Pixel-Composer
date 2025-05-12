function Node_Matrix_Transpose(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Transpose";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", self, new Matrix(3)))
		.setVisible(true, true);
		
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Matrix", self, CONNECT_TYPE.output, VALUE_TYPE.float, new Matrix(3)))
		.setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		return _mat.transpose();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_matrix_transpose, 0, bbox);
	}
}