function Node_Stagger(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stagger";
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Int("Delay Step", self, 1));
	
	newInput(2, nodeValue_Int("Delay Amount", self, 1));
	
	newInput(3, nodeValue("Stagger Curve", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01));
	
	newInput(4, nodeValue_Enum_Button("Overflow", self,  0, [ "Hide", "Clamp" ]));
	
	outputs[0] = nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 
		["Stagger",  false], 3, 1, 2, 4, 
	];
	
	surf_indexes = [];
	
	static processData_prebatch  = function() {
		surf_indexes = array_verify(surf_indexes, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			surf_indexes[i] = array_verify(surf_indexes[i], TOTAL_FRAMES);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _step = _data[1];
		var _amnt = _data[2];
		var _curv = _data[3];
		var _ovfl = _data[4];
		
		var _time = CURRENT_FRAME;
		if(_time == -1) return _output;
		
		var _aind = _array_index;
		var _stps = floor(process_amount / _step);
		var _frtm = _time - eval_curve_x(_curv, floor(_aind / _step) / _stps) * _amnt * _stps;
		    _frtm = round(_frtm);
			
		if(_ovfl == 1)
			_frtm = clamp(_frtm, 0, TOTAL_FRAMES - 1);
			
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