function Node_Stagger(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stagger";
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Float("Delay Step", 1));
	
	newInput(2, nodeValue_Float("Delay Amount", 1));
	
	newInput(3, nodeValue_Curve("Stagger Curve", CURVE_DEF_01));
	
	newInput(4, nodeValue_Enum_Button("Overflow",  0, [ "Hide", "Clamp" ]));
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Stagger",  false], 3, 1, 2, 4, 
	];
	
	surf_indexes = [];
	
	static processData_prebatch  = function() {
		surf_indexes = array_verify(surf_indexes, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			surf_indexes[i] = array_verify(surf_indexes[i], TOTAL_FRAMES);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _surf = _data[0];
		var _step = _data[1];
		var _amnt = _data[2];
		var _curv = _data[3];
		var _ovfl = _data[4];
		
		var _time = CURRENT_FRAME;
		if(_time < 0) return _output;
		
		var _aind = _array_index;
		var _stps = floor(process_amount / _step);
		var _frtm = _time - eval_curve_x(_curv, floor(_aind / _step) / _stps) * _amnt * _stps;
		    _frtm = round(_frtm);
			
		if(_ovfl == 1) _frtm = clamp(_frtm, 1, TOTAL_FRAMES - 1);
			
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		surf_indexes[_array_index][_time] = surface_verify(surf_indexes[_array_index][_time], _sw, _sh);
		surface_set_shader(surf_indexes[_array_index][_time]);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		_output = surface_verify(_output, _sw, _sh);
		surface_set_shader(_output);
			if(0 <= _frtm && _frtm < TOTAL_FRAMES) {
				draw_surface_safe(surf_indexes[_array_index][_frtm]);
				
				surface_free(surf_indexes[_array_index][_frtm]);
				surf_indexes[_array_index][_frtm] = 0;
			}
		surface_reset_shader();
		
		return _output;
	}
}