function Node_Delay(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Delay";
	
	is_simulation = true;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Int("Frames", self, 1));
	
	newInput(2, nodeValue_Bool("Loop", self, false));
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Delay",  false], 1, 2, 
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
		var _loop = _data[2];
		
		var _time = CURRENT_FRAME;
		var _frtm = _time - _frme;
		if(_loop) _frtm = (_frtm + TOTAL_FRAMES) % TOTAL_FRAMES;
		else      _frtm = clamp(_frtm, 0, TOTAL_FRAMES - 1);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		surf_indexes[_array_index][_time] = surface_verify(surf_indexes[_array_index][_time], _sw, _sh);
		
		surface_set_target(surf_indexes[_array_index][_time]);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(_surf);
			BLEND_NORMAL
		surface_reset_target();
		
		_output = surface_verify(_output, _sw, _sh);
		surface_set_target(_output);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			if(0 <= _frtm && _frtm < TOTAL_FRAMES) {
				draw_surface_safe(surf_indexes[_array_index][_frtm]);
				
				surface_free(surf_indexes[_array_index][_frtm]);
				surf_indexes[_array_index][_frtm] = 0;
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _output;
	}
}