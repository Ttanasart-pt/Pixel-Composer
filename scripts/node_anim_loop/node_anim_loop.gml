function Node_Anim_Loop(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Frame Loop";
	update_on_frame = true;
	is_simulation   = true;
	
	newInput( 0, nodeValue_Surface( "Surface" ));
	
	////- =Loop
	newInput( 7, nodeValue_EScroll(  "Loop Type",   0, [ "Loop", "Pingpong" ] ));
	newInput( 1, nodeValue_Int(      "Loop Start",  1    )).setPieMenu();
	newInput( 2, nodeValue_Int(      "Loop Range",  4    )).setPieMenu();
	newInput( 3, nodeValue_Bool(     "Infinite",    true )).setPieMenu();
	newInput( 4, nodeValue_Int(      "Loop Amount", 1    )).setPieMenu();
	
	////- =Overflow
	newInput( 5, nodeValue_EScroll( "Pre Loop",  0, [ "Passthrough", "Empty" ]));
	newInput( 6, nodeValue_EScroll( "Post Loop", 1, [ "Passthrough", "Empty" ]));
	// 8
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Loop",     false ],  7,  1,  2,  3,  4, 
		[ "Overflow", false ],  5,  6, 
	];
	
	////- Node
	
	surf_indexes = [];
	curr_frame   = 0;
	loop_start   = 0;
	loop_range   = 0;
	loop_amount  = infinity;
	
	static processData_prebatch  = function() {
		surf_indexes = array_verify(surf_indexes, process_amount);
		for( var i = 0; i < process_amount; i++ ) 
			surf_indexes[i] = array_verify(surf_indexes[i], TOTAL_FRAMES);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		#region data
			var _surf   = _data[ 0];
			
			var _ltype  = _data[ 7];
			var _lstart = _data[ 1];
			var _lrange = _data[ 2];
			var _linfin = _data[ 3];
			var _lamoun = _data[ 4];
			
			var _lpre   = _data[ 5];
			var _lpos   = _data[ 6];
			
			inputs[4].setVisible(!_linfin);
			inputs[6].setVisible(!_linfin);
		#endregion
		
		var _time   = CURRENT_FRAME;
		var _loop_a = _linfin? infinity : _lamoun;
		loop_amount = _loop_a;
		
		if(_lrange == 0) _lrange = TOTAL_FRAMES - _lstart;
		
		loop_start = _lstart - 1;
        loop_range = _lrange - 1;
        
        var _sw = surface_get_width_safe(_surf);
    	var _sh = surface_get_height_safe(_surf);
	    	
        curr_frame = _time;
		if(_time < loop_start) { // Pre loop
			_output = surface_verify(_output, _sw, _sh);
			
		    if(_lpre == 0) {
		    	surface_set_shader(_output, sh_sample, true, BLEND.over);
				    draw_surface_safe(_surf);
				surface_reset_target();
		    } if(_lpre == 1) surface_clear(_output);
		    return _output;
		}
		
		var _loop_perd = floor((_time - loop_start) / _lrange);
		if(_loop_perd > _loop_a) { // Post loop
			_output = surface_verify(_output, _sw, _sh);
			
		    if(_lpos == 0) {
		    	surface_set_shader(_output, sh_sample, true, BLEND.over);
				    draw_surface_safe(_surf);
				surface_reset_target();
		    } if(_lpos == 1) surface_clear(_output);
		    return _output;
		}
		
		var _loop_time = _time - loop_start;
		switch(_ltype) {
			case 0 : _loop_time = _loop_time % _lrange; break;
			case 1 : _loop_time = _loop_time % (_lrange * 2 - 2); 
			         _loop_time = _loop_time >= _lrange? _lrange * 2 - 2 - _loop_time : _loop_time; break; 
		}
		
		var _surfA = surf_indexes[_array_index];
		
		if(_time < loop_start + _lrange) {
    		_surfA[_loop_time] = surface_verify(_surfA[_loop_time], _sw, _sh);
    		
    		surface_set_shader(_surfA[_loop_time], sh_sample, true, BLEND.over);
    			draw_surface_safe(_surf);
    		surface_reset_target();
		}
		
        var _sw = surface_get_width_safe(_surfA[_loop_time]);
    	var _sh = surface_get_height_safe(_surfA[_loop_time]);
	    
		_output = surface_verify(_output, _sw, _sh);
		
		surface_set_shader(_output, sh_sample, true, BLEND.over);
		    draw_surface_safe(_surfA[_loop_time]);
		surface_reset_target();
		
		curr_frame = loop_start + _loop_time;
		
		return _output;
	}
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		var _x0 = _shf + (loop_start + 1) * _s;
		var _ww = (loop_range) * _s;
		BLEND_ADD
		    drawSelector(_x0, ui(13), _ww, ui(15), COLORS._main_value_positive, .5);
		BLEND_NORMAL
		
		draw_set_color(COLORS._main_value_positive);
		var _x = _shf + (curr_frame + 1) * _s;
		draw_line_width(_x, 0, _x, _h, 1);
	}
	
}