function Node_Matrix_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Matrix Set";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_set);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Matrix( "Matrix",         )).setVisible(true, true).rejectArray();
	newInput( 1, nodeValue_IVec2(  "Position", [0,0] ));
	newInput( 2, nodeValue_Float(  "Value",       0  ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput( 0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3)) ).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0, 1, 2 ];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _mat = getInputData(0);
			var _pos = getInputData(1);
			var _val = getInputData(2);
			
			if(!is(_mat, Matrix)) return;
		#endregion
		
		var _m = outputs[0].getValue();
		    _m.setSize(_mat.size);
		    _m.setArray(_mat.raw);
		
		var _mw = _mat.size[0];
		var _mh = _mat.size[1];
		
		if(!is_array(_pos[0])) {
			var p = _pos;
			var v = _val;
			
			if(p[0] >= 0 && p[0] < _mw && p[1] >= 0 && p[1] < _mh)
			    _m.raw[p[1] * _mw + p[0]] = v;
			    
		} else {
			var _amo = min(array_length(_pos), array_length(_val))
			for( var i = 0; i < _amo; i++ ) {
				var p = _pos[i];
				var v = _val[i];
				
				if(p[0] >= 0 && p[0] < _mw && p[1] >= 0 && p[1] < _mh)
				    _m.raw[p[1] * _mw + p[0]] = v;
			}
		}
		
		outputs[0].setValue(_m);
	}
	
}