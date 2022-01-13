function Node_Value_Processor(_x, _y) : Node(_x, _y) constructor {
	array_process = ARRAY_PROCESS.loop;
	
	function process_value(_outindex) {
		var _data = array_create(ds_list_size(inputs));
		for(var i = 0; i < array_length(_data); i++) 
			_data[i] = inputs[| i].getValue();
		return process_value_data(_data, _outindex);
	}
	
	function process_value_data(_data, _index) { return; }
	
	function preProcess(_outindex) {
		var len = 0;
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].getValue();
			if(is_array(_in)) {
				if(typeArray(inputs[| i].display_type)) {
					if(is_array(_in[0]))
						len = max(len, array_length(_in));
				} else 
					len = max(len, array_length(_in));
			}
		}
		
		var _out = outputs[| _outindex].getValue();
		
		if(len) {
			if(!is_array(_out))
				_out = array_create(len);
			else if(array_length(_out) != len) 
				array_resize(_out, len);
			
			var _data   = array_create(ds_list_size(inputs));
			
			for(var l = 0; l < len; l++) {
				for(var i = 0; i < ds_list_size(inputs); i++) {
					var _in = inputs[| i].getValue();
					if(inputs[| i].isArray()) {
						if(array_length(_in) == 0) {
							_data[i] = 0;
							continue;
						}
						var _index = 0;
						switch(array_process) {
							case ARRAY_PROCESS.loop :
								_index = safe_mod(l, array_length(_in));
								break;
							case ARRAY_PROCESS.hold :
								_index = min(l, array_length(_in) - 1);
								break;
						}
						_data[i] = _in[_index];
					} else {
						_data[i] = _in;	
					}
				}
				
				_out[l] = process_value_data(_data, _outindex);
			}
			return _out;
		} else {
			return process_value(_outindex);
		}
	}
	
	function update() {
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _output = preProcess(i);
			
			outputs[| i].setValue(_output);
		}
	}	
}