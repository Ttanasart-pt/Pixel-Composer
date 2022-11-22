function Node_create_Time_Remap(_x, _y) {
	var node = new Node_Time_Remap(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Time_Remap(_x, _y) : Node(_x, _y) constructor {
	name	= "Time remap";
	use_cache   = true;
	
	uniform_map = shader_get_sampler_index(sh_time_remap, "map");
	uniform_min = shader_get_uniform(sh_time_remap, "vMin");
	uniform_max = shader_get_uniform(sh_time_remap, "vMax");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 2] = nodeValue(2, "Max life",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static update = function() {
		if(array_length(cached_output) != ANIMATOR.frames_total + 1)
			return;
			
		var _inSurf  = inputs[| 0].getValue();
		var _map     = inputs[| 1].getValue();
		var _life    = inputs[| 2].getValue();
		
		var _surf  = outputs[| 0].getValue();
		if(!is_surface(_surf)) {
			_surf = surface_create_valid(surface_get_width(_inSurf), surface_get_height(_inSurf));
			outputs[| 0].setValue(_surf);
		} else
			surface_size_to(_surf, surface_get_width(_inSurf), surface_get_height(_inSurf));
		
		var ste = 1 / _life;
		
		surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		shader_set(sh_time_remap);
		texture_set_stage(uniform_map, surface_get_texture(_map));
		
		for(var i = 0; i <= _life; i++) {
			var frame = clamp(ANIMATOR.current_frame - i, 0, ANIMATOR.frames_total - 1);
			
			if(is_surface(cached_output[frame])) {
				shader_set_uniform_f(uniform_min, i * ste);	
				shader_set_uniform_f(uniform_max, i * ste + ste);	
				draw_surface_safe(cached_output[frame], 0, 0);
			}
		}
		
		shader_reset();
		surface_reset_target();
		
		cacheCurrentFrame(_inSurf);
	}
}