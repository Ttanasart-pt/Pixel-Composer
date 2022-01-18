enum ARRAY_PROCESS {
	loop,
	hold
}

function Node_Processor(_x, _y) : Node(_x, _y) constructor {
	array_process = ARRAY_PROCESS.loop;
	current_data  = [];
	
	icon    = s_node_processor;
	
	static process_data = function(_outSurf, _data, _output_index) { return _outSurf; }
	
	static update = function() {
		var len = 0;
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].getValue();
			if(is_array(_in)) {
				if(inputs[| i].isArray())
					len = max(len, array_length(_in));
			}
		}
		
		for(var _oi = 0; _oi < ds_list_size(outputs); _oi++) {
			if(outputs[| _oi].type != VALUE_TYPE.surface) continue;
			var outSurfs = outputs[| _oi].getValue();
			
			if(len) {
				if(!is_array(outSurfs))
					outSurfs = array_create(len);
				else if(array_length(outSurfs) != len) 
					array_resize(outSurfs, len);
				
				for(var i = 0; i < len; i++) {
					var ww = 1, hh = 1;
					
					if(inputs[| 0].type == VALUE_TYPE.surface) {
						var base_s = getData(0, i);
						
						if(is_surface(base_s)) {
							var ww = surface_get_width(base_s);
							var hh = surface_get_height(base_s);
						}
					}
					
					if(!is_surface(outSurfs[i]))
						outSurfs[i] = surface_create(ww, hh);
					else 
						surface_size_to(outSurfs[i], ww, hh)
					
					var _data = getDataArray(i);
					process_data(outSurfs[i], _data, _oi);
					if(i == preview_index) current_data = _data;
				}
				
				outputs[| _oi].setValue(outSurfs);
			} else {
				var ww = 1, hh = 1;
				
				if(inputs[| 0].type == VALUE_TYPE.surface) {
					var base_texture = inputs[| 0].getValue();
					
					if(is_surface(base_texture)) {
						ww = surface_get_width(base_texture);
						hh = surface_get_height(base_texture);
					}
				}
				
				if(is_array(outSurfs)) {
					for(var i = 1; i < array_length(outSurfs); i++) {
						if(is_surface(outSurfs[i]))
							surface_free(outSurfs[i]);
					}
					outSurfs = outSurfs[0];
					outputs[| _oi].setValue(outSurfs);
				}
				
				if(!is_surface(outSurfs)) {
					outSurfs = surface_create(ww, hh);
					outputs[| _oi].setValue(outSurfs);
				} else 
					surface_size_to(outSurfs, ww, hh);
				
				var _data = getDataArray(0);
				process_data(outSurfs, _data, _oi);
				current_data = _data;
			}
		}
	}	
	
	function getDataArray(index) {
		var _data = array_create(ds_list_size(inputs));
		for(var i = 0; i < array_length(_data); i++) {
			_data[i] = getData(i, index);
		}
		return _data;
	}
	
	function getData(data, index) {
		var _data = 0;
		
		var val = inputs[| data].getValue();
			
		if(inputs[| data].isArray()) {
			if(array_length(val) == 0) return 0;
			_data = val[safe_mod(index, array_length(val))];
		} else 
			_data = val;
		
		return _data;
	}
}