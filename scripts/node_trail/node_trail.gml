function Node_Trail(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name		= "Trail";
	use_cache   = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Max life",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	inputs[| 2] = nodeValue("Step",       self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	inputs[| 3] = nodeValue("Alpha decrease",	self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 4] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES );
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Trail settings",	false], 0, 1, 2, 4, 3
	];
	
	temp_surf = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(!inputs[| 0].value_from) 
			return _outSurf;
		if(array_length(cached_output) != ANIMATOR.frames_total + 1)
			return _outSurf
		
		for(var i = 0; i < 2; i++) {
			temp_surf[i] = surface_verify(temp_surf[i], surface_get_width(_outSurf), surface_get_height(_outSurf));
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		var _life  = _data[1];
		var _step  = _data[2];
		var _alpha = _data[3];
		var _blend = _data[4];
		
		var aa = 1;
		var res_index = 0;
		var frame_amo = min(_life, floor(ANIMATOR.current_frame / _step));
		var st_frame  = ANIMATOR.current_frame - frame_amo * _step;
		
		for(var i = 0; i <= _life; i++) {
			var frame_idx = clamp(st_frame + i * _step, 0, ANIMATOR.frames_total - 1);
			var bg = i % 2;
			var fg = !bg;
			var aa = 1 - _alpha * (_life - i);
			
			surface_set_target(temp_surf[bg]);
				if(i == _life)
					draw_surface_safe(_data[0], 0, 0);
				else if(is_surface(cached_output[frame_idx]))
					draw_surface_blend(temp_surf[fg], cached_output[frame_idx], _blend, aa);
			surface_reset_target();
			
			res_index = bg;
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
			draw_surface_safe(temp_surf[res_index], 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
		
		cacheCurrentFrame(_data[0]);
		
		return _outSurf;
	}
}