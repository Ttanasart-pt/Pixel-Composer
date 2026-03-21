function Node_Matrix_Projection(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Projection Matrix";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_projection);
	setDimension(96, 48);
	
	newInput(0, nodeValue_EButton(  "Projection", 1, [ "Perspective", "Orthographic" ] ));
	
	////- =Camera
	newInput(1, nodeValue_Dimension( "View" ));
	newInput(4, nodeValue_Slider(    "Orthographic Scale",   .5, [ 0.01, 4, 0.01 ]  ));
	newInput(2, nodeValue_ISlider(   "FOV",      60, [ 10, 90, 0.1 ] ));
	newInput(3, nodeValue_Vec2(      "Clipping", [1,10]              ));
	// 5
	
	newOutput(0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(4))).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0, 
		[ "Camera", false ], 1, 4, 2, 3, 
	];
	
	////- Nodes
	
	__prev_size = [ 0, 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _prj = _data[0];
			
			var _dim = _data[1];
			var _ort = _data[4];
			var _fov = _data[2];
			var _clp = _data[3];
			
			inputs[4].setVisible(_prj == 1);
			inputs[2].setVisible(_prj == 0);
		#endregion
		
		if(_prj == 0) _outData.raw = matrix_build_projection_perspective_fov(_fov, _dim[0] / _dim[1], _clp[0], _clp[1]);
		if(_prj == 1) _outData.raw = matrix_build_projection_ortho(1 / _ort, _dim[1] / _dim[0] / _ort, _clp[0], _clp[1]);
		
		return _outData;
	}
}