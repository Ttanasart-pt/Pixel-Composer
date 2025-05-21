function Node_Matrix_Multiply_Vector(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Multiply Vector";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3)))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Vector("Vector"))
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Vector", self, CONNECT_TYPE.output, VALUE_TYPE.float, []))
		.setArrayDepth(1);
		
	input_display_list = [ 0, 1 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		var _vec = _data[1];
		
		return _mat.multiplyVector(_vec);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_matrix_multiply_vector, 0, bbox);
	}
}