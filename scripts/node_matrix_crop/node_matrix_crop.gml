function Node_Matrix_Crop(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Crop";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_crop);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Matrix(  "Matrix" )).setVisible(true, true);
	
	////- =Crop
	newInput( 1, nodeValue_IVec2(   "Size",     [3,3] ));
	newInput( 2, nodeValue_IVec2(   "Offset",   [0,0] ));
	newInput( 3, nodeValue_EScroll( "Overflow",  0, [ "Zero", "Repeat", "Clamp" ] ));
	// 4
	
	newOutput(0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3))).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0,
		[ "Crop", false ], 1, 2, 3, 
	];
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _mat = _data[0];
			var _siz = _data[1];
			var _off = _data[2];
			var _ovr = _data[3];
		#endregion
		
		var _msiz = _mat.size;
		_outData.setSize(_siz);
		
		for( var i = 0; i < _siz[0]; i++ ) 
		for( var j = 0; j < _siz[1]; j++ ) {
			var gx = _off[0] + i;
			var gy = _off[1] + j;
			
			if(gx < 0 || gy < 0 || gx >= _msiz[0] || gy >= _msiz[1]) {
				switch(_ovr) {
					case 0 : _outData.set(i, j, 0); continue;
					
					case 1 : gx = ((gx % _msiz[0]) + _msiz[0]) % _msiz[0];
						     gy = ((gy % _msiz[1]) + _msiz[1]) % _msiz[1]; break;
					
					case 2 : gx = clamp(gx, 0, _msiz[0] - 1);
						     gy = clamp(gy, 0, _msiz[1] - 1); break;
						
				}
			}
			
			_outData.set(i, j, _mat.get(gx, gy));
		}
		
		return _outData;
	}
	
}