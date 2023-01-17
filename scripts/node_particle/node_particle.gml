function Node_Particle(_x, _y, _group = -1) : Node_VFX_Spawner_Base(_x, _y, _group) constructor {
	name = "Particle";
	use_cache = true;
	
	inputs[| input_len + 0] = nodeValue(input_len + 0, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| input_len + 1] = nodeValue(input_len + 1, "Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| input_len + 2] = nodeValue(input_len + 2, "Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Additive" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	array_insert(input_display_list, 0, ["Output", true], input_len + 0);
	array_push(input_display_list, input_len + 1, input_len + 2);
	
	def_surface = -1;
	
	static onStep = function() {
		if(!ANIMATOR.frame_progress) return;
		
		if(recoverCache()) {
			triggerRender();
			return;
		}
		
		if(!ANIMATOR.is_playing) return;
			
		if(ANIMATOR.current_frame == 0) {
			reset();
			runVFX(ANIMATOR.current_frame);
		} else if(cached_output[ANIMATOR.current_frame - 1] != 0)
			runVFX(ANIMATOR.current_frame);
	}
	
	function render(_time = ANIMATOR.current_frame) {
		var _dim		= inputs[| input_len + 0].getValue(_time);
		var _exact 		= inputs[| input_len + 1].getValue(_time);
		var _blend 		= inputs[| input_len + 2].getValue(_time);
		
		var _outSurf	= outputs[| 0].getValue();
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal :	
					draw_clear_alpha(c_white, 0);
					gpu_set_blendmode(bm_normal);	
					break;
				case PARTICLE_BLEND_MODE.additive : 
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode(bm_add);		
					break;
			}
			
			var surf_w = surface_get_width(_outSurf);
			var surf_h = surface_get_height(_outSurf);
			
			for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++) {
				parts[i].draw(_exact, surf_w, surf_h);
			}
			
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		cacheCurrentFrame(_outSurf);
	}
}