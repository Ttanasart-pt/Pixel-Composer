function Node_Delay(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Delay";
	
	is_simulation = true;
	
	inputs[| 0] = nodeValue_Surface("Surface", self);
	
	inputs[| 1] = nodeValue("Frames", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 
		["Delay",  false], 1,
	];
	
	surf_indexes = [];
	
	static processData_prebatch  = function() {
		surf_indexes = array_verify(surf_indexes, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			surf_indexes[i] = array_verify(surf_indexes[i], TOTAL_FRAMES);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _frme = _data[1];
		
		var _time = CURRENT_FRAME;
		var _frtm = clamp(_time - _frme, 0, TOTAL_FRAMES - 1);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		surf_indexes[_array_index][_time] = surface_verify(surf_indexes[_array_index][_time], _sw, _sh);
		
		surface_set_target(surf_indexes[_array_index][_time]);
			DRAW_CLEAR
			draw_surface_safe(_surf);
		surface_reset_target();
		
		_output = surface_verify(_output, _sw, _sh);
		surface_set_target(_output);
			DRAW_CLEAR
			
			if(0 <= _frtm && _frtm < TOTAL_FRAMES) {
				draw_surface_safe(surf_indexes[_array_index][_frtm]);
				
				surface_free(surf_indexes[_array_index][_frtm]);
				surf_indexes[_array_index][_frtm] = 0;
			}
		surface_reset_target();
		
		return _output;
	}
}