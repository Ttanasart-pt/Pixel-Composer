enum ARRAY_PROCESS {
	loop,
	hold
}

function Node_Processor(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	array_process  = ARRAY_PROCESS.loop;
	current_data   = [];
	process_amount = 0;
	inputs_data    = [];
	
	icon    = THEME.node_processor;
	
	static process_data = function(_outSurf, _data, _output_index) { return _outSurf; }
	
	static getDimension = function(index = 0, arr = 0) {
		if(array_length(inputs_data) == 0) return [1, 1];
		
		var _inSurf = process_amount == 0? inputs_data[index] : inputs_data[index][arr];
		if(is_surface(_inSurf)) {
			var ww = surface_get_width(_inSurf);
			var hh = surface_get_height(_inSurf);
			return [ww, hh];
		}
		
		if(is_array(_inSurf) && array_length(_inSurf) == 2)
			return _inSurf;
		return [1, 1];
	}
	
	static preProcess = function(outIndex) {
		var _out = outputs[| outIndex].getValue();
		
		if(process_amount == 0) { //render single data
			if(is_array(_out)) { //free surface if needed
				if(outputs[| outIndex].type == VALUE_TYPE.surface)
				for(var i = 1; i < array_length(_out); i++) {
					if(is_surface(_out[i])) surface_free(_out[i]);
				}
				
				_out = _out[0];
			}
			
			if(inputs[| 0].type == VALUE_TYPE.surface && is_surface(inputs_data[0])) { //match surface size
				var _ww = surface_get_width(inputs_data[0]);
				var _hh = surface_get_height(inputs_data[0]);
				_out = surface_verify(_out, _ww, _hh);
			}
			
			current_data = inputs_data;
			return process_data(_out, inputs_data, outIndex);
		}
		
		if(!is_array(_out))
			_out = array_create(process_amount);
		else if(array_length(_out) != process_amount) 
			array_resize(_out, process_amount);
		
		var _data    = array_create(ds_list_size(inputs));
		
		for(var l = 0; l < process_amount; l++) {
			for(var i = 0; i < ds_list_size(inputs); i++) { //input prepare
				var _in = inputs_data[i];
				
				if(!inputs[| i].isArray(_in)) {
					_data[i] = inputs_data[i];	
					continue;
				}
				
				if(array_length(_in) == 0) {
					_data[i] = 0;
					continue;
				}
				var _index = 0;
				switch(array_process) {
					case ARRAY_PROCESS.loop : _index = safe_mod(l, array_length(_in)); break;
					case ARRAY_PROCESS.hold : _index = min(l, array_length(_in) - 1);  break;
				}
				_data[i] = _in[_index];
			}
			
			if(inputs[| 0].type == VALUE_TYPE.surface && is_surface(_data[0])) { //match surface size
				var _ww = surface_get_width(_data[0]);
				var _hh = surface_get_height(_data[0]);
				_out[l] = surface_verify(_out[l], _ww, _hh);
			}
			
			_out[l] = process_data(_out[l], _data, outIndex);
			if(l == preview_index) current_data = _data;
		}
		
		return _out;
	}
	
	static update = function() {
		process_amount = 0;
		inputs_data = array_create(ds_list_size(inputs));
		
		for(var i = 0; i < ds_list_size(inputs); i++) { //pre-collect current input data
			inputs_data[i] = inputs[| i].getValue();
			
			if(!is_array(inputs_data[i])) continue;
			if(array_length(inputs_data[i]) == 0) continue;
			if(!inputs[| i].isArray(inputs_data[i])) continue;
			
			if(typeArray(inputs[| i].display_type)) {
				process_amount = max(process_amount, array_length(inputs_data[i][0]));
			} else 
				process_amount = max(process_amount, array_length(inputs_data[i]));
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++)
			outputs[| i].setValue(preProcess(i));
	}
}