function Node_Trail(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Trail";
	use_cache   = true;
	
	shader = sh_trail_filler;
	uni_dimension	= shader_get_uniform(shader, "dimension");
	uni_range		= shader_get_uniform(shader, "range");
	uni_sam_prev	= shader_get_sampler_index(shader, "prevFrame");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Max life",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 5);
	
	inputs[| 2] = nodeValue("Loop",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surface",			 true], 0, 
		["Trail settings",	false], 1, 2,
	];
	
	output_surf = surface_create(1, 1);
	
	static update = function() {
		if(!inputs[| 0].value_from) return;
		if(array_length(cached_output) != ANIMATOR.frames_total + 1) return;
		
		var _surf  = inputs[| 0].getValue();
		var _life  = inputs[| 1].getValue();
		var _loop  = inputs[| 2].getValue();
		
		if(!is_surface(_surf)) return;
		cacheCurrentFrame(_surf);
		
		output_surf = surface_verify(output_surf, surface_get_width(_surf), surface_get_height(_surf));
		surface_set_target(output_surf);
		draw_clear_alpha(0, 0);
		surface_reset_target();
			
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, surface_get_width(_surf), surface_get_height(_surf));
		outputs[| 0].setValue(_outSurf);
		
		var curf = ANIMATOR.current_frame;
		var frame_amo = _loop? _life : min(_life, curf);
		var st_frame  = curf - frame_amo;
		
		print("=====");
		for(var i = 0; i <= frame_amo; i++) {
			var frame_idx = st_frame + i;
			var prog = (frame_idx - (curf - _life)) / _life;
			
			if(_loop && frame_idx < 0) frame_idx = ANIMATOR.frames_total + frame_idx;
			
			var prev = _loop? safe_mod(frame_idx - 1 + ANIMATOR.frames_total, ANIMATOR.frames_total) : frame_idx - 1;
			if(!is_surface(getCacheFrame(frame_idx))) continue;
			
			if(!is_surface(getCacheFrame(prev))) {
				surface_set_target(output_surf);
				draw_surface(getCacheFrame(frame_idx), 0, 0);
				surface_reset_target();
				continue;
			}
			
			surface_set_target(output_surf);
			shader_set(sh_trail_filler);
			shader_set_uniform_f(uni_dimension, surface_get_width(_surf), surface_get_height(_surf));
			shader_set_uniform_f(uni_range, surface_get_width(_surf) / 2);
			texture_set_stage(uni_sam_prev, surface_get_texture(getCacheFrame(prev)));
			
			draw_surface(getCacheFrame(frame_idx), 0, 0);
			shader_reset();
			surface_reset_target();
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
			draw_surface_safe(output_surf, 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
	}
}