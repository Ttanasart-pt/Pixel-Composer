function Node_Time_Remap(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name      = "Time Remap";
	use_cache = CACHE_USE.manual;
	update_on_frame = true;
	
	shader = sh_time_remap;
	uniform_map = shader_get_sampler_index(shader, "map");
	uniform_min = shader_get_uniform(shader, "vMin");
	uniform_max = shader_get_uniform(shader, "vMax");
	
	inputs[0] = nodeValue_Surface("Surface in", self)
		.rejectArray();
	
	inputs[1] = nodeValue_Surface("Map", self)
		.rejectArray();
	
	inputs[2] = nodeValue_Int("Max life",   self, 3)
		.rejectArray();
	
	inputs[3] = nodeValue_Bool("Loop", self, false)
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Surfaces", false], 0, 1, 
		["Remap",	 false], 2, 3,
	]
	
	attribute_surface_depth();
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _inSurf  = getInputData(0);
		var _map     = getInputData(1);
		var _life    = getInputData(2);
		var _loop    = getInputData(3);
		
		var _surf  = outputs[0].getValue();
		_surf = surface_verify(_surf, surface_get_width_safe(_inSurf), surface_get_height_safe(_inSurf), attrDepth());
		outputs[0].setValue(_surf);
		
		var ste = 1 / _life;
		
		surface_set_shader(_surf, shader);
		texture_set_stage(uniform_map, surface_get_texture(_map));
		
		for(var i = 0; i <= _life; i++) {
			var _frame = CURRENT_FRAME - i;
			if(_loop)
				_frame = _frame < 0? TOTAL_FRAMES - 1 + _frame : _frame;
			else 
				_frame = clamp(_frame, 0, TOTAL_FRAMES - 1);
			
			var s = array_safe_get_fast(cached_output, _frame);
			if(!is_surface(s)) continue;
			
			shader_set_uniform_f(uniform_min, i * ste);	
			shader_set_uniform_f(uniform_max, i * ste + ste);	
			draw_surface_safe(s);
		}
		
		surface_reset_shader();
		
		cacheCurrentFrame(_inSurf);
	} #endregion
}