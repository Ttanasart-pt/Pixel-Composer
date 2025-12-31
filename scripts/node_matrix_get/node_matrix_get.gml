function Node_Matrix_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Matrix Get";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_get);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Matrix( "Matrix",         )).setVisible(true, true).rejectArray();
	newInput( 1, nodeValue_IVec2(  "Position", [0,0] ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput( 0, nodeValue_Output("Output", VALUE_TYPE.float, 0 ));
		
	input_display_list = [ 0, 1 ];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _mat = getInputData(0);
			var _pos = getInputData(1);
			
			if(!is(_mat, Matrix)) return;
		#endregion
		
		var w = _mat.size[0];
		var h = _mat.size[1];
		var a = _mat.raw;
		
		var _ar = is_array(_pos[0]);
		if(!_ar) _pos = [_pos];
		
		var _amo = array_length(_pos);
		var _v   = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var p = _pos[i];
			
			if(p[0] >= 0 && p[0] < w && p[1] >= 0 && p[1] < h)
			    _v[i] = _mat.raw[p[1] * w + p[0]];
		}
		
		if(!_ar) _v = _v[0];
		outputs[0].setValue(_v);
	}
	
}