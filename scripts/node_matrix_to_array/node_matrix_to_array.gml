function Node_Matrix_To_Array(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix to Array";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", self, new Matrix(3)))
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Array", self, CONNECT_TYPE.output, VALUE_TYPE.float, []))
	    .setArrayDepth(1);
	
	input_display_list = [ 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		var _res = array_clone(_mat.raw);
		return _res;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_matrix_to_array, 0, bbox);
	}
}