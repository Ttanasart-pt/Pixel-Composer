function Node_Matrix_Set(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Set";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3)))
		.setVisible(true, true);
	
	newInput(1, nodeValue_IVec2("Position", [ 0, 0 ]))
	
	newInput(2, nodeValue_Float("Value", 0))	;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue("Matrix", self, CONNECT_TYPE.output, VALUE_TYPE.float, new Matrix(3)))
		.setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0, 1, 2 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		var _pos = _data[1];
		var _val = _data[2];
		
		var _m = _mat.clone();
		var _i = _pos[1] * _mat.size[0] + _pos[0];
		if(_pos[0] >= 0 && _pos[0] < _mat.size[0] && _pos[1] >= 0 && _pos[1] < _mat.size[1])
		    _m.raw[_i] = _val;
		
		return _m;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_matrix_set, 0, bbox);
	}
}