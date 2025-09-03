enum ARRAY_PROCESS {
	loop,
	hold,
	expand,
	expand_inv,
}

#macro PROCESSOR_OVERLAY_CHECK if(array_length(current_data) != array_length(inputs)) return 0;

function Node_Processor(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	attributes.array_process = ARRAY_PROCESS.loop;
	current_data	= [];
	inputs_is_array = [];
	inputs_index    = [];
	
	process_amount	= 0;
	process_length  = [];
	process_running = [];
	
	manage_atlas = true;
	atlas_index  = 0;
	
	icon = THEME.node_processor_icon;
	
	array_push(attributeEditors, "Array processor");
	array_push(attributeEditors, [ "Array process type", function() /*=>*/ {return attributes.array_process}, 
		new scrollBox([ "Loop", "Hold", "Expand", "Expand inverse" ], function(v) /*=>*/ {return setAttribute("array_process", v, true)}, false) ]);
	
	////- Getters
	
	static getInputData = function(index, def = 0) { INLINE return array_safe_get_fast(inputs_data, index, def); }
	
	static getSingleValue = function(_index, _arr = preview_index, output = false) { 
		if(output) {
			var _val = outputs[_index].getValue();
			return process_amount <= 1? _val : array_safe_get_fast(_val, _arr);
		}
		
		var _n = array_safe_get(inputs, _index);
		if(!is(_n, NodeValue)) return 0;
		
		var _val = getInputData(_index);
		if(process_amount <= 1 || !is_array(_val) || process_length[_index] <= 1) return _val;
		
		var _aIndex = _arr;
		
		switch(attributes.array_process) {
			case ARRAY_PROCESS.loop :		_aIndex = safe_mod(_arr, process_length[_index]);	break;
			case ARRAY_PROCESS.hold :		_aIndex = min(_arr, process_length[_index] - 1	); 	break;
			case ARRAY_PROCESS.expand :		_aIndex = floor(_arr / process_running[_index]) % process_length[_index]; break;
			case ARRAY_PROCESS.expand_inv : _aIndex = floor(_arr / process_running[array_length(inputs) - 1 - _index]) % process_length[_index]; break;
		}
		
		return array_safe_get_fast(_val, _aIndex);
	} 
	
	static getDimension = function(arr = 0) { 
		if(dimension_index == -1) return [ 1, 1 ];
		
		var _ip = array_safe_get(inputs, dimension_index, noone);
		if(_ip == noone) return [ 1, 1 ];
		
		var _in = getSingleValue(dimension_index, arr);
		
		if(_ip.type == VALUE_TYPE.surface && is_surface(_in)) {
			var ww = surface_get_width_safe(_in);
			var hh = surface_get_height_safe(_in);
			return [ww, hh];
		}
		
		if(is_array(_in) && array_length(_in) == 2)
			return _in;
			
		return [1, 1];
	} 
	
	////- Process
	
	static preGetInputs  = undefined;
	static getInputs     = function(frame = CURRENT_FRAME) {
		if(preGetInputs != undefined) preGetInputs();
		
		var _len = array_length(inputs);
		__frame  = frame;
		
		process_amount	= 1;
		inputs_data		= array_verify(inputs_data,		_len);
		inputs_is_array	= array_verify(inputs_is_array, _len);
		inputs_index    = array_verify(inputs_index,	_len);
		process_length  = array_verify(process_length,	_len);
		process_running = array_verify(process_running,	_len);
		
		array_foreach(inputs, function(_in, i) /*=>*/ {
			var raw = _in.getValue(__frame);
			var amo = _in.arrayLength(raw);
			var val = raw;
			
			_in.bypass_junc.setValue(val);
				 if(amo == 0) val = noone;		//empty array
			else if(amo == 1) val = raw[0];		//spread single array
			inputs_is_array[i] = amo > 1;
			
			amo = max(1, amo);
			
			input_value_map[$ _in.internalName] = val;
			inputs_data[i] = val;				//setInputData(i, val);
			
			switch(attributes.array_process) {
				case ARRAY_PROCESS.loop : 
				case ARRAY_PROCESS.hold :   
					process_amount = max(process_amount, amo);	
					break;
					
				case ARRAY_PROCESS.expand : 
				case ARRAY_PROCESS.expand_inv : 
					process_amount *= amo;
					break;
			}
			
			process_length[i]  = amo;
			process_running[i] = process_amount;
		});
		
		var amoMax = process_amount;
		for( var i = 0; i < _len; i++ ) {
			amoMax /= process_length[i];
			process_running[i] = amoMax;
			inputs_index[i]    = array_verify(inputs_index[i], process_amount);
		}
		
		for(var l = 0; l < process_amount; l++) // input preparation
		for(var i = 0; i < _len; i++) { 
			inputs_index[i][l] = -1;
			if(!inputs_is_array[i]) continue;
			
			var _index = 0;
			switch(attributes.array_process) {
				case ARRAY_PROCESS.loop :		_index = safe_mod(l, process_length[i]); break;
				case ARRAY_PROCESS.hold :		_index = min(l, process_length[i] - 1);  break;
				case ARRAY_PROCESS.expand :		_index = floor(l / process_running[i]) % process_length[i]; break;
				case ARRAY_PROCESS.expand_inv : _index = floor(l / process_running[array_length(inputs) - 1 - i]) % process_length[i]; break;
			}
			
			inputs_index[i][l] = _index;
		}
	}
	
	static processData   = function(_outSurf, _data, _array_index = 0, _frame = CURRENT_FRAME) { return _outSurf; }
	
	static processOutput = function(frame = CURRENT_FRAME) { 
		var _is  = array_length(inputs);
		var _os  = array_length(outputs);
		
		var _out = array_create_ext(_os, function(i) /*=>*/ {return outputs[i].getValue()});
		var data;
		
		var _surfOut = outputs[0];
		var _skip    = active_index != -1 && !inputs_data[active_index];
		
		if(_skip) {
			var _skp = inputs_data[0];
			if(inputs[0].type == VALUE_TYPE.surface)
				_skp = process_amount == 1? surface_clone(inputs_data[0], _out[0]) : surface_array_clone(inputs_data[0]);
			_surfOut.setValue(_skp);
			return;
		}
		
		if(process_amount == 1) {
			current_data = inputs_data;
			
			if(dimension_index > -1) {
				var _dim = getDimension();
				for(var i = 0; i < _os; i++) {
					if(outputs[i].type != VALUE_TYPE.surface) continue;
					
					_out[i] = surface_verify(_out[i], _dim[0], _dim[1], attrDepth());
				}
			}
			
			if(_os == 1) {
				data = processData(_out[0], inputs_data, 0, frame);
				if(data == noone) return;
				
				outputs[0].setValue(data);
				
			} else {
				data = processData(_out, inputs_data, 0, frame);
				if(data == noone) return;
				
				for(var i = 0; i < min(_os, array_length(data)); i++) outputs[i].setValue(data[i]);
			}
			
			return;
		}
			
		var _inputs  = array_create(_is);
		var _outputs = array_create(_os);
		
		for( var l = 0; l < process_amount; l++ ) {
			for(var i = 0; i < _is; i++) 
				_inputs[i] = inputs_index[i][l] == -1? inputs_data[i] : inputs_data[i][inputs_index[i][l]];
				
			if(l == 0 || l == preview_index) current_data = _inputs;
			
			var _outa = array_create(_os);
				
			if(dimension_index > -1) {
				var _dim  = getDimension(l);
				for(var i = 0; i < _os; i++) {
					_outa[i] = array_safe_get(_out[i], l);
					
					if(outputs[i].type != VALUE_TYPE.surface) continue;
					_outa[i] = surface_verify(_outa[i], _dim[0], _dim[1], attrDepth());
				}
				
			} else {
				for(var i = 0; i < _os; i++)
					_outa[i] = array_safe_get(_out[i], l);
			}
			
			if(_os == 1) {
				data = processData(_outa[0], _inputs, l, frame);
				_outputs[0][l] = data;
				
			} else {
				data = processData(_outa, _inputs, l, frame);
				for(var i = 0; i < _os; i++) _outputs[i][l] = data[i];
			}
		}
		
		for( var i = 0, n = _os; i < n; i++ )
			outputs[i].setValue(_outputs[i]);
		
	} 
	
	////- Update
	
	static processData_prebatch  = undefined;
	static processData_postbatch = undefined;
	static postProcess           = undefined;
	static postPostProcess       = undefined;
	
	static update = function(frame = CURRENT_FRAME) { 
		if(processData_prebatch  != undefined) processData_prebatch(frame);
			
		processOutput(frame);
			
		if(processData_postbatch != undefined) processData_postbatch(frame);
		if(postProcess           != undefined) postProcess(frame);
		if(postPostProcess       != undefined) postPostProcess(frame);
	}
	
	///////////////////// CACHE /////////////////////
	
	static cacheCurrentFrameIndex = function(_aindex, _surface) {
		cacheArrayCheck();
		var _frame = CURRENT_FRAME;
		if(_frame < 0) return;
		if(_frame >= array_length(cached_output)) return;
		
		var _surfs = cached_output[_frame];
		var _cache = array_safe_get_fast(_surfs, _aindex);
		
		if(is_array(_surface)) {
			surface_array_free(_cache);
			_surfs[_aindex] = surface_array_clone(_surface);
			
		} else if(surface_exists(_surface)) {
			var _sw = surface_get_width(_surface);
			var _sh = surface_get_height(_surface);
			
			_cache = surface_verify(_cache, _sw, _sh);
			surface_set_target(_cache);
				DRAW_CLEAR BLEND_OVERRIDE
				draw_surface(_surface, 0, 0);
			surface_reset_target();
			
			_surfs[_aindex] = _cache;
		}
		
		cached_output[_frame] = _surfs;
		array_safe_set(cache_result, _frame, true);
		
		return cached_output[_frame];
	}
	
	static getCacheFrameIndex = function(_aindex = 0, _frame = CURRENT_FRAME) {
		if(_frame < 0) return false;
		if(!cacheExist(_frame)) return noone;
		
		var surf = array_safe_get_fast(cached_output, _frame);
		return array_safe_get_fast(surf, _aindex, noone);
	}
}