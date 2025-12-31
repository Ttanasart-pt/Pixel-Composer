function Node_Matrix_Get_Vector(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Matrix Get Vector";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_get_vector);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Matrix(  "Matrix" )).setVisible(true, true).rejectArray();
	
	////- Vector
	newInput( 1, nodeValue_EButton( "Direction",  0, [ "Row", "Column", "Diagonal", "Inv. Diagonal" ] ));
	newInput( 2, nodeValue_Int(     "Position",   0  ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput( 0, nodeValue_Output("Matrix", VALUE_TYPE.float, [] )).setArrayDepth(1);
		
	input_display_list = [ 0,
		[ "Vector", false ], 1, 2,
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _mat = getInputData(0);
			
			var _dir = getInputData(1);
			var _pos = getInputData(2);
			
			inputs[2].setVisible(_dir < 2);
			
			if(!is(_mat, Matrix)) return;
		#endregion
		
		var w = _mat.size[0];
		var h = _mat.size[1];
		var a = _mat.raw;
		
		var _ar = is_array(_pos);
		if(!_ar) _pos = [_pos];
			
		var _amo = array_length(_pos);
		var _v   = [];
		
		for( var i = 0; i < _amo; i++ ) {
			var p = _pos[i];
			var v = [];
			
			switch(_dir) {
				case 0 : for( var i = 0, n = min(w);   i < n; i++ ) array_push(v, a[p*w + i]);       break;
				case 1 : for( var i = 0, n = min(h);   i < n; i++ ) array_push(v, a[i*w + p]);       break;
				case 2 : for( var i = 0, n = min(w,h); i < n; i++ ) array_push(v, a[i*w + i]);       break;
				case 3 : for( var i = 0, n = min(w,h); i < n; i++ ) array_push(v, a[i*w + (w-i-1)]); break;
			}
			
			array_push(_v, v);
		}
		
		if(!_ar) _v = _v[0];
		outputs[0].setValue(_v);
	}
	
}