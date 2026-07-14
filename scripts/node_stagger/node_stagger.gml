function Node_Stagger(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stagger";
	is_simulation   = true;
	update_on_frame = true;
	
	newInput( 0, nodeValue_Surface("Surface"));
	
	////- =Stagger
	newInput( 3, nodeValue_Curve(   "Stagger Curve", CURVE_DEF_01 ));
	newInput( 1, nodeValue_Float(   "Delay Step",   1 )).setPieMenu();
	newInput( 2, nodeValue_Float(   "Delay Amount", 1 )).setPieMenu();
	newInput( 4, nodeValue_EButton( "Overflow",     0, [ "Hide", "Clamp" ])).setPieMenu();
	// 5
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Stagger", false ], 3, 1, 2, 4, 
	];
	
	////- Node
	
	 surf_cache   = [];
	 target_frame = 0;
	_target_frame = 0;
	
	static processData_prebatch  = function() {
		surf_cache = array_verify(surf_cache, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			surf_cache[i] = array_verify(surf_cache[i], TOTAL_FRAMES);
	}
	
	static postProcess = function() {
		target_frame = _target_frame;
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _surf = _data[ 0];
			
			var _step = _data[ 1];
			var _amnt = _data[ 2];
			var _curv = _data[ 3];
			var _ovfl = _data[ 4];
		#endregion
		
		var _time = _frame;
		if(_time < 0) return _output;
		
		if(_frame != target_frame && !IS_FIRST_FRAME) return _output;
		_target_frame = _frame + 1;
		
		var _aind = _array_index;
		var _stps = floor(process_amount / _step);
		var _frtm = _time - eval_curve_x(_curv, floor(_aind / _step) / _stps) * _amnt * _stps;
		    _frtm = round(_frtm);
		
		switch(_ovfl) {
			case 0 : _frtm = _frtm; break;
			case 1 : _frtm = clamp(_frtm, 0, TOTAL_FRAMES - 1); break;
		}
		
		var _sw  = surface_get_width_safe(_surf);
		var _sh  = surface_get_height_safe(_surf);
		
		surf_cache[_array_index][_time] = surface_verify(surf_cache[_array_index][_time], _sw, _sh);
		var cArr = surf_cache[_array_index];
		
		surface_set_shader(cArr[_time]);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		_output = surface_verify(_output, _sw, _sh);
		surface_set_shader(_output);
			if(0 <= _frtm && _frtm < TOTAL_FRAMES) {
				draw_surface_safe(cArr[_frtm]);
				
				// surface_free(cArr[_frtm]);
				// cArr[_frtm] = 0;
			}
		surface_reset_shader();
		
		return _output;
	}
	
	////- Draw
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		draw_set_color(COLORS._main_value_positive);
		draw_set_alpha(1);
		
		var _x = _shf + target_frame * _s;
		draw_line_width(_x, 0, _x, _h, 1);
		draw_set_alpha(1);
	}
	
}