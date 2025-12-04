function Node_Matrix_To_Array(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix to Array";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_to_array);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3)))
		.setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.float, []))
	    .setArrayDepth(1);
	
	input_display_list = [ 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		var _res = array_clone(_mat.raw);
		return _res;
	}
	
}