function Node_Matrix_Transform_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "3D Transform Matrix";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_transform_3d);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Bool( "Affine", true ));
	
	////- =Transform
	newInput( 1, nodeValue_Vec3(       "Position", [0,0,0]   ));
	newInput( 2, nodeValue_Quaternion( "Rotation" ));
	newInput( 3, nodeValue_Vec3(       "Scale",    [1,1,1]   ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3))).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0, 
		[ "Transform", false ], 1, 2, 3, 
	];
	
	////- Nodes
	
	__prev_size = [ 0, 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _aff = _data[0];
			
			var _pos = _data[1];
			var _rot = _data[2];
			var _sca = _data[3];
			
			inputs[1].setVisible(_aff);
		#endregion
		
		var _eul  = quarternionToEuler(_rot[0], _rot[1], _rot[2], _rot[3]);
		var _outp = is(_outData, Matrix)? _outData : new Matrix();
		_outp.setSize(4);
		_outp.raw = _aff? matrix_build(_pos[0], _pos[1], _pos[2], _eul[0], _eul[1], _eul[2], _sca[0], _sca[1], _sca[2]) : 
		                  matrix_build(0, 0, 0,                   _eul[0], _eul[1], _eul[2], _sca[0], _sca[1], _sca[2]);
		
		if(!_aff) _outp.raw[15] = 0;
		
		return _outp;
	}
}