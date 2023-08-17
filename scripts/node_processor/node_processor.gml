enum ARRAY_PROCESS {
	loop,
	hold,
	expand,
	expand_inv,
}

#macro PROCESSOR_OVERLAY_CHECK if(array_length(current_data) != ds_list_size(inputs)) return;

function Node_Processor(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	attributes.array_process = ARRAY_PROCESS.loop;
	current_data	= [];
	inputs_data		= [];
	all_inputs      = [];
	
	process_amount	= 0;
	process_length  = [];
	dimension_index = 0;	
	
	icon    = THEME.node_processor;
	
	array_push(attributeEditors, "Array processor");
	array_push(attributeEditors, [ "Array process type", function() { return attributes.array_process; }, 
		new scrollBox([ "Loop", "Hold", "Expand", "Expand inverse" ], 
		function(val) { 
			attributes.array_process = val; 
			triggerRender();
		}, false) ]);
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { return _outSurf; }
	
	static getSingleValue = function(_index, _arr = 0, output = false) {
		var _l  = output? outputs : inputs;
		var _n  = _l[| _index];
		var _in = _n.getValue();
		
		if(!_n.isArray()) return _in;
		
		switch(attributes.array_process) {
			case ARRAY_PROCESS.loop :		_index = safe_mod(_arr, array_length(_in)); break;
			case ARRAY_PROCESS.hold :		_index = min(_arr, array_length(_in) - 1);  break;
			case ARRAY_PROCESS.expand :		_index = floor(_arr / process_length[_index][1]) % process_length[_index][0]; break;
			case ARRAY_PROCESS.expand_inv : _index = floor(_arr / process_length[ds_list_size(_l) - 1 - _index][1]) % process_length[_index][0]; break;
		}
				
		return array_safe_get(_in, _index);
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
		
		if(process_amount == 0) { #region render single data
			if(outputs[| outIndex].type == VALUE_TYPE.d3object) //passing 3D vertex call
				return _out;
			
			if(is_array(_out) && outputs[| outIndex].type == VALUE_TYPE.surface) { //free surface if needed
				for(var i = 1; i < array_length(_out); i++)
					if(is_surface(_out[i])) surface_free(_out[i]);
			}
			
			if(outputs[| outIndex].type == VALUE_TYPE.surface && dimension_index > -1) { //resize surface
				var surf = inputs_data[dimension_index];
				var _sw = 1, _sh = 1;
				if(inputs[| dimension_index].type == VALUE_TYPE.surface) {
					if(is_surface(surf)) {
						_sw = surface_get_width(surf);
						_sh = surface_get_height(surf);
					} else 
						return noone;
				} else if(is_array(surf)) {
					_sw = array_safe_get(surf, 0, 1);
					_sh = array_safe_get(surf, 1, 1);
				}
				
				_out = surface_verify(_out, _sw, _sh, attrDepth());
			}
			
			current_data = inputs_data;
			
			if(active_index > -1 && !inputs_data[active_index]) { // skip
				if(inputs[| 0].type == VALUE_TYPE.surface)
					return surface_clone(inputs_data[0], _out);
				else 
					return inputs_data[0]
			}
			
			var data = processData(_out, inputs_data, outIndex, 0);						/// Process data
			return data;
		} #endregion
		
		if(outputs[| outIndex].type == VALUE_TYPE.d3object) { #region passing 3D vertex call
			if(is_array(_out)) _out = _out[0];
			return array_create(process_amount, _out);
		} #endregion
		
		#region ++++ array preparation ++++
			if(!is_array(_out))
				_out = array_create(process_amount);
			else if(array_length(_out) != process_amount) 
				array_resize(_out, process_amount);
		
			var _data  = array_create(ds_list_size(inputs));
			all_inputs = array_create(ds_list_size(inputs));
			
			for(var i = 0; i < ds_list_size(inputs); i++)
				all_inputs[i] = array_create(process_amount);
		#endregion
		
		for(var l = 0; l < process_amount; l++) {
			for(var i = 0; i < ds_list_size(inputs); i++) { #region input preparation
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
				switch(attributes.array_process) {
					case ARRAY_PROCESS.loop :		_index = safe_mod(l, array_length(_in)); break;
					case ARRAY_PROCESS.hold :		_index = min(l, array_length(_in) - 1);  break;
					case ARRAY_PROCESS.expand :		_index = floor(l / process_length[i][1]) % process_length[i][0]; break;
					case ARRAY_PROCESS.expand_inv : _index = floor(l / process_length[ds_list_size(inputs) - 1 - i][1]) % process_length[i][0]; break;
				}
				
				_data[i] = _in[_index];
				all_inputs[i][l] = _data[i];
			} #endregion
			
			if(outputs[| outIndex].type == VALUE_TYPE.surface && dimension_index > -1) { #region output surface verification
				var surf = _data[dimension_index];
				var _sw = 1, _sh = 1;
				if(inputs[| dimension_index].type == VALUE_TYPE.surface) {
					if(is_surface(surf)) {
						_sw = surface_get_width(surf);
						_sh = surface_get_height(surf);
					} else 
						return noone;
				} else if(is_array(surf)) {
					_sw = surf[0];
					_sh = surf[1];
				}
				
				_out[l] = surface_verify(_out[l], _sw, _sh, attrDepth());
			} #endregion
			
			if(l == 0 || l == preview_index) 
				current_data = _data;
			
			if(active_index > -1 && !_data[active_index]) { // skip
				if(inputs[| 0].type == VALUE_TYPE.surface)
					_out[l] = surface_clone(_data[0], _out[l]);
				else 
					_out[l] = _data[0];
			} else {
				_out[l] = processData(_out[l], _data, outIndex, l);						/// Process data
			}
		}
		
		return _out;
	}
	
	static update = function(frame = PROJECT.animator.current_frame) { #region
		process_amount	= 0;
		inputs_data		= array_create(ds_list_size(inputs));
		process_length  = array_create(ds_list_size(inputs));
		
		for(var i = 0; i < ds_list_size(inputs); i++) { //pre-collect current input data
			var val = inputs[| i].getValue();
			var amo = inputs[| i].arrayLength(val);
			
			inputs_data[i] = val;
			
			switch(attributes.array_process) {
				case ARRAY_PROCESS.loop : 
				case ARRAY_PROCESS.hold :   
					process_amount = max(process_amount, amo);	
					break;
				case ARRAY_PROCESS.expand : 
				case ARRAY_PROCESS.expand_inv : 
					if(amo && process_amount == 0)
						process_amount = 1;
					process_amount *= max(1, amo);
					break;
			}
			
			process_length[i] = [max(1, amo), process_amount];
		}
		
		var amoMax = process_amount;
		for( var i = 0, n = array_length(process_length); i < n; i++ ) {
			amoMax /= process_length[i][0];
			process_length[i][1] = amoMax;
		}
		
		var val;
		for(var i = 0; i < ds_list_size(outputs); i++) {
			if(outputs[| i].process_array) {
				val = preProcess(i);
				if(val == undefined) continue;
			} else
				val = processData(noone, noone, i);
			outputs[| i].setValue(val);
		}
	} #endregion
	
	static processSerialize = function(_map) { #region
		_map.array_process = attributes.array_process;
	} #endregion
	
	static processDeserialize = function() { #region
		attributes.array_process = struct_try_get(load_map, "array_process", ARRAY_PROCESS.loop);
	} #endregion
	
	///////////////////// CACHE /////////////////////
	
	static cacheCurrentFrameIndex = function(_frame, index) { #region
		cacheArrayCheck();
		if(PROJECT.animator.current_frame < 0) return;
		if(PROJECT.animator.current_frame >= array_length(cached_output)) return;
		
		var prev = cached_output[PROJECT.animator.current_frame];
		surface_array_free(array_safe_get(prev, index));
		cached_output[PROJECT.animator.current_frame][index] = surface_array_clone(_frame);
		
		array_safe_set(cache_result, PROJECT.animator.current_frame, true);
		
		return cached_output[PROJECT.animator.current_frame];
	} #endregion
	
	static getCacheFrameIndex = function(frame = PROJECT.animator.current_frame, index = 0) { #region
		if(frame < 0) return false;
		if(!cacheExist(frame)) return noone;
		
		var surf = array_safe_get(cached_output, frame);
		return array_safe_get(surf, index);
	} #endregion
}