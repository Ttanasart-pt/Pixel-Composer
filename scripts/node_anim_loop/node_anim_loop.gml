function Node_Anim_Loop(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Frame Loop";
	
	is_simulation = true;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Int("Loop Start", self, 1));
	
	newInput(2, nodeValue_Int("Loop Range", self, 4));
	
	newInput(3, nodeValue_Bool("Infinite", self, true));
	
	newInput(4, nodeValue_Int("Loop Amount", self, 1));
	
	newInput(5, nodeValue_Enum_Scroll("Pre Loop", self, 0, [ "Passthrough", "Empty" ]));
	
	newInput(6, nodeValue_Enum_Scroll("Post Loop", self, 1, [ "Passthrough", "Empty" ]));
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Loop",     false], 1, 2, 3, 4, 
		["Overflow", false], 5, 6, 
	];
	
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
	
	static processData = function(_output, _data, _array_index = 0) {  
		var _surf       = _data[0];
		var _loop_start = _data[1];
		var _loop_range = _data[2];
		var _loop_infin = _data[3];
		var _loop_amoun = _data[4];
		
		var _loop_pre = _data[5];
		var _loop_pos = _data[6];
		
		inputs[4].setVisible(!_loop_infin);
		
		var _time   = CURRENT_FRAME;
		var _loop_a = _loop_infin? infinity : _loop_amoun;
		loop_amount = _loop_a;
		
		loop_start = _loop_start - 1;
        loop_range = _loop_range - 1;
        
        var _sw = surface_get_width_safe(_surf);
    	var _sh = surface_get_height_safe(_surf);
	    	
        curr_frame = _time;
		if(_time < loop_start) {
			_output = surface_verify(_output, _sw, _sh);
			
		    if(_loop_pre == 0) {
		    	surface_set_shader(_output, sh_sample, true, BLEND.over);
				    draw_surface_safe(_surf);
				surface_reset_target();
		    } if(_loop_pre == 1) surface_clear(_output);
		    
		    return _output;
		}
		
		var _loop_time = (_time - loop_start) % _loop_range;
		var _loop_perd = floor((_time - loop_start) / _loop_range);
		
		if(_loop_perd > _loop_a) {
			_output = surface_verify(_output, _sw, _sh);
			
		    if(_loop_pos == 0) {
		    	surface_set_shader(_output, sh_sample, true, BLEND.over);
				    draw_surface_safe(_surf);
				surface_reset_target();
		    } if(_loop_pos == 1) surface_clear(_output);
		    return _output;
		}
		
		var _surfA = surf_indexes[_array_index];
		
		if(_time < loop_start + _loop_range) {
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
		    draw_sprite_stretched_ext(THEME.ui_selection, 0, _x0, ui(13), _ww, ui(15), COLORS._main_value_positive, .5);
		BLEND_NORMAL
		
		draw_set_color(COLORS._main_value_positive);
		var _x = _shf + (curr_frame + 1) * _s;
		draw_line_width(_x, 0, _x, _h, 1);
	}
	
}