function Node_Time_Remap(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Time Remap";
	use_cache = true;
	
	shader = sh_time_remap;
	uniform_map = shader_get_sampler_index(shader, "map");
	uniform_min = shader_get_uniform(shader, "vMin");
	uniform_max = shader_get_uniform(shader, "vMax");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Max life",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Surface",	 false], 0, 1, 2, 
	]
	
	static update = function(frame = ANIMATOR.current_frame) {
		if(array_length(cached_output) != ANIMATOR.frames_total + 1)
			return;
			
		var _inSurf  = inputs[| 0].getValue();
		var _map     = inputs[| 1].getValue();
		var _life    = inputs[| 2].getValue();
		
		var _surf  = outputs[| 0].getValue();
		_surf = surface_verify(_surf, surface_get_width(_inSurf), surface_get_height(_inSurf));
		outputs[| 0].setValue(_surf);
		
		var ste = 1 / _life;
		
		surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
		texture_set_stage(uniform_map, surface_get_texture(_map));
		
		for(var i = 0; i <= _life; i++) {
			var _frame = clamp(ANIMATOR.current_frame - i, 0, ANIMATOR.frames_total - 1);
			
			if(is_surface(cached_output[_frame])) {
				shader_set_uniform_f(uniform_min, i * ste);	
				shader_set_uniform_f(uniform_max, i * ste + ste);	
				draw_surface_safe(cached_output[_frame], 0, 0);
			}
		}
		
		shader_reset();
		surface_reset_target();
		
		cacheCurrentFrame(_inSurf);
	}
}