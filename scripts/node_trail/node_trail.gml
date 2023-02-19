function Node_Trail(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Trail";
	use_cache   = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Max life",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 5);
	inputs[| 2] = nodeValue("Alpha fade", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 3] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES );
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surface",			 true], 0, 
		["Trail settings",	false], 1, 3, 2
	];
	
	temp_surf = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static update = function() {
		if(!inputs[| 0].value_from) return;
		if(array_length(cached_output) != ANIMATOR.frames_total + 1) return;
		
		var _surf  = inputs[| 0].getValue();
		var _life  = inputs[| 1].getValue();
		var _alpha = inputs[| 2].getValue();
		var _blend = inputs[| 3].getValue();
		
		if(!is_surface(_surf)) return;
		cacheCurrentFrame(_surf);
		
		for(var i = 0; i < 2; i++) {
			temp_surf[i] = surface_verify(temp_surf[i], surface_get_width(_surf), surface_get_height(_surf));
			
			surface_set_target(temp_surf[i]);
			draw_clear_alpha(0, 0);
			surface_reset_target();
		}
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, surface_get_width(_surf), surface_get_height(_surf));
		outputs[| 0].setValue(_outSurf);
		
		var curf = ANIMATOR.current_frame;
		var aa = 1;
		var frame_amo = min(_life, curf);
		var st_frame  = curf - frame_amo;
		var bg		  = 0;
		
		for(var i = 0; i <= frame_amo; i++) {
			var frame_idx = st_frame + i;
			var prog = (frame_idx - (curf - _life)) / _life;
			var aa = eval_curve_x(_alpha, prog);
			aa = power(aa, 2);
			
			bg = !bg;
			
			surface_set_target(temp_surf[bg]);
			draw_surface_blend(temp_surf[!bg], getCacheFrame(frame_idx), _blend, aa, false);
			surface_reset_target();
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
			draw_surface_safe(temp_surf[bg], 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
	}
}