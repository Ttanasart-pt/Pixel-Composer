enum ARRAY_PROCESS {
	loop,
	hold
}

function Node_Processor(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	array_process	= ARRAY_PROCESS.loop;
	current_data	= [];
	inputs_data		= [];
	
	process_amount	= 0;
	dimension_index = 0;
	
	icon    = THEME.node_processor;
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) { return _outSurf; }
	
	static getSingleValue = function(_index, _arr = 0) {
		var _n  = inputs[| _index];
		var _in = _n.getValue();
		
		if(_n.isArray()) 
			return _in[_arr % array_length(_in)];
		return _in;
	}
	
	static getDimension = function(arr = 0) {
		if(dimension_index == -1) return [1, 1];
		
		var _in = getSingleValue(dimension_index, arr);
		
		if(inputs[| dimension_index].type == VALUE_TYPE.surface && is_surface(_in)) {
			var ww = surface_get_width(_in);
			var hh = surface_get_height(_in);
			return [ww, hh];
		}
		
		if(is_array(_in) && array_length(_in) == 2)
			return _in;
			
		return [1, 1];
	}
	
	static preProcess = function(outIndex) {
		var _out = outputs[| outIndex].getValue();
		
		if(process_amount == 0) { //render single data
			if(outputs[| outIndex].type == VALUE_TYPE.d3object) //passing 3D vertex call
				return _out;
			
			if(is_array(_out)) { //free surface if needed
				if(outputs[| outIndex].type == VALUE_TYPE.surface)
				for(var i = 1; i < array_length(_out); i++) {
					if(is_surface(_out[i])) surface_free(_out[i]);
				}
				
				_out = array_safe_get(_out, 0);
			}
			
			if(outputs[| outIndex].type == VALUE_TYPE.surface && dimension_index > -1) {
				var surf = inputs_data[dimension_index];
				var _sw = 1, _sh = 1;
				if(inputs[| dimension_index].type == VALUE_TYPE.surface && is_surface(surf)) {
					_sw = surface_get_width(surf);
					_sh = surface_get_height(surf);
				} else if(is_array(surf)) {
					_sw = surf[0];
					_sh = surf[1];
				}
				_out = surface_verify(_out, _sw, _sh);
			}
			
			current_data = inputs_data;
			return process_data(_out, inputs_data, outIndex, 0);
		}
		
		if(outputs[| outIndex].type == VALUE_TYPE.d3object) { //passing 3D vertex call
			if(is_array(_out)) _out = _out[0];
			return array_create(process_amount, _out);
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
			
			if(outputs[| outIndex].type == VALUE_TYPE.surface && dimension_index > -1) {
				var surf = _data[dimension_index];
				var _sw = 1, _sh = 1;
				if(inputs[| dimension_index].type == VALUE_TYPE.surface && is_surface(surf)) {
					_sw = surface_get_width(surf);
					_sh = surface_get_height(surf);
				} else if(is_array(surf)) {
					_sw = surf[0];
					_sh = surf[1];
				}
				_out[l] = surface_verify(_out[l], _sw, _sh);
			}
			
			if(l == preview_index) 
				current_data = _data;
			
			_out[l] = process_data(_out[l], _data, outIndex, l);
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