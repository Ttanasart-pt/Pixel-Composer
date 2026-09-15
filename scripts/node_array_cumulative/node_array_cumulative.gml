function Node_Array_Cumulative(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Cumulative";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue("Array In", self, CONNECT_TYPE.input, VALUE_TYPE.float, [])).setVisible(true, true);
	
	////- =Cumulation
	newInput( 1, nodeValue_Float( "Start", 0 ));
	newInput( 2, nodeValue_Bool(  "Include Current", true ));
	// 3
	
	newOutput(0, nodeValue_Output("Cumulative Array", VALUE_TYPE.float, []));
	
	input_display_list = [ 0, 
		[ "Cumulation", false ],  1,  2, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var arr = getInputData( 0);
			
			var sta = getInputData( 1);
			var inc = getInputData( 2);
			
			if(!is_array(arr)) return;
		#endregion
		
		var _len = array_length(arr);
		var _cum = array_verify(outputs[0].getValue(), _len);
		var _val = sta;
		
		for( var i = 0; i < _len; i++ ) {
			if(!inc) _cum[i] = _val;
			
			var _aval = arr[i];
			if(is_numeric(_aval))
				_val += _aval;
				
			if(inc) _cum[i] = _val;
		}
		
		outputs[0].setValue(_cum);
	}
}