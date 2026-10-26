function Node_Array_Transpose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Transpose";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Array
	newInput( 0, nodeValue_Any( "Array" )).setVisible(true, true);
	// 1
	
	newOutput( 0, nodeValue_Output("Transposed Array", VALUE_TYPE.any, []));
	
	input_display_list = [ 
		[ "Array", false ],  0,
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var arr = getInputData(0);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(arr)) {
			    noti_warning($"{name}: Input not an array", noone, self);
			    return;
			}
		#endregion
		
		var _w = array_length(arr);
		if(_w == 0) return;
		
		var _h = undefined;
		
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
		    if(!is_array(arr[i])) continue;
		    
		    var _l = array_length(arr[i]);
		    _h = _h == undefined? _l : min(_h, _l);
		}
		
		var _arr = array_create(_h);
		var  sig = array_create(_h);
		
		for( var i = 0; i < _h; i++ ) {
			var sigs = is_array(isig)? array_safe_get_fast(isig, i, VALUE_TYPE.float) : isig;
			
		    _arr[i] = array_create(_w);
		     sig[i] = array_create(_w);
		    
		    for( var j = 0; j < _w; j++ ) {
		        _arr[i][j] = arr[j][i];
		         sig[i][j] = array_safe_get_fast(sigs, j, VALUE_TYPE.float, sigs);
		         
		    }
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(_arr);
	}
}