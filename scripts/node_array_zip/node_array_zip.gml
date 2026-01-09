function Node_Array_Zip(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Zip";
	setDimension(96, 48);
	setDrawIcon(s_node_array_zip);
	
	newInput(0, nodeValue_Bool("Spread Content", false));
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.integer, 0));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 )).setVisible(true, true);
							
		return inputs[index];
	} setDynamicInput(1);
	
	////- Nodes
	
	static update = function(frame = CURRENT_FRAME) {
		var _spr = getInputData(0);
		var  amo = getInputAmount();
		
		#region type
			var _outType = undefined;
			
			for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
				var _inType = inputs[i].value_from == noone? VALUE_TYPE.any : inputs[i].value_from.type;
				inputs[i].setType(_inType);
				
				if(_outType == undefined)    _outType = _inType;
				else if(_outType != _inType) _outType = VALUE_TYPE.any;
			}
			
			outputs[0].setType(_outType ?? VALUE_TYPE.any);
		#endregion
		
		if(amo == 0) return;
		
		var len = infinity;
		var val = [];
		
		for( var i = 0; i < amo; i++ ) {
			val[i] = getInputData(input_fix_len + i);
			
			if(!is_array(val[i])) {
				val[i] = [ val[i] ];
				continue;
			}
			
			len = min(len, array_length(val[i]));
		}
		
		if(len == 0) return;
		var _out = array_create(len);
		
		if(_spr) {
			for( var i = 0; i < len; i++ ) {
				_out[i] = [];
				
				for( var j = 0; j < amo; j++ )
					array_append(_out[i], array_safe_get_fast(val[j], i, 0));
			}
			
		} else {
			for( var i = 0; i < len; i++ ) {
				for( var j = 0; j < amo; j++ )
					_out[i][j] = array_safe_get_fast(val[j], i, 0);
			}
		}
		
		outputs[0].setValue(_out);
	}
}