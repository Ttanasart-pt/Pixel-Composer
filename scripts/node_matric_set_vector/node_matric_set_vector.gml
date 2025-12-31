function Node_Matrix_Set_Vector(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Matrix Set Vector";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_set_vector);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Matrix(  "Matrix" )).setVisible(true, true).rejectArray();
	
	////- Vector
	newInput( 1, nodeValue_EButton( "Direction",  0, [ "Row", "Column", "Diagonal", "Inv. Diagonal" ] ));
	newInput( 2, nodeValue_Int(     "Position",   0  ));
	newInput( 3, nodeValue_Float(   "Vector",     [] )).setVisible(true, true).setArrayDepth(1);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput( 0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3)) ).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0,
		[ "Vector", false ], 1, 2, 3, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _mat = getInputData(0);
			
			var _dir = getInputData(1);
			var _pos = getInputData(2);
			var _val = getInputData(3);
			
			inputs[2].setVisible(_dir < 2);
			
			if(!is(_mat, Matrix)) return;
		#endregion
		
		var _m = outputs[0].getValue();
		    _m.setSize(_mat.size);
		    _m.setArray(_mat.raw);
		
		var w = _m.size[0];
		var h = _m.size[1];
		var a = _m.raw;
		
		if(!is_array(_pos)) {
			_pos = [_pos];
			_val = [_val];
		}
			
		var _amo = min(array_length(_pos), array_length(_val))
		for( var i = 0; i < _amo; i++ ) {
			var p = _pos[i];
			var v = _val[i];
			var l = array_length(v);
			
			switch(_dir) {
				case 0 : for( var i = 0, n = min(w, l);    i < n; i++ ) a[p*w + i]       = v[i]; break;
				case 1 : for( var i = 0, n = min(h, l);    i < n; i++ ) a[i*w + p]       = v[i]; break;
				case 2 : for( var i = 0, n = min(w, h, l); i < n; i++ ) a[i*w + i]       = v[i]; break;
				case 3 : for( var i = 0, n = min(w, h, l); i < n; i++ ) a[i*w + (w-i-1)] = v[i]; break;
			}
		}
		
		outputs[0].setValue(_m);
	}
	
}