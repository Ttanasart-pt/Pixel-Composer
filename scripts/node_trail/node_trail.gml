function Node_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Trail";
	use_cache   = true;
	
	shader1 = sh_trail_filler_pass1;
	uni_dimension	= shader_get_uniform(shader1, "dimension");
	uni_mode		= shader_get_uniform(shader1, "mode");
	uni_range		= shader_get_uniform(shader1, "range");
	uni_colr		= shader_get_uniform(shader1, "matchColor");
	uni_blend		= shader_get_uniform(shader1, "blendColor");
	uni_seg_st		= shader_get_uniform(shader1, "segmentStart");
	uni_seg_sz		= shader_get_uniform(shader1, "segmentSize");	
	uni_sam_prev	= shader_get_sampler_index(shader1, "prevFrame");
	
	shader2 = sh_trail_filler_pass2;
	uni2_dimension	= shader_get_uniform(shader2, "dimension");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Max life", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 5);
	
	inputs[| 2] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 3] = nodeValue("Max distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -1, "Maximum distance to search for movement, set to -1 to search the entire image.");
	
	inputs[| 4] = nodeValue("Match color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Make trail track pixels of the same color, instead of the closet pixels.");
	
	inputs[| 5] = nodeValue("Blend color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Blend color between two pixel smoothly.");
	
	inputs[| 6] = nodeValue("Alpha over life", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Trail UV", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output", 			 true], 0, 
		["Trail settings",	false], 1, 2,
		["Tracking",		false], 3, 4, 5, 
		["Modification",	false], 6, 
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() {
		var _colr  = inputs[| 4].getValue();
		
		inputs[| 5].setVisible(!_colr);
	}
	
	static update = function() {
		if(!inputs[| 0].value_from) return;
		
		var _surf  = inputs[| 0].getValue();
		var _life  = inputs[| 1].getValue();
		var _loop  = inputs[| 2].getValue();
		if(!is_real(_loop)) _loop = false;
		
		var _rang  = inputs[| 3].getValue();
		var _colr  = inputs[| 4].getValue();
		var _blend = inputs[| 5].getValue();
		var _alpha = inputs[| 6].getValue();
		var cDep   = attrDepth();
		if(!is_surface(_surf)) return;
		cacheCurrentFrame(_surf);
		
		for( var i = 0; i < array_length(temp_surface); i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], surface_get_width(_surf), surface_get_height(_surf), cDep);
			surface_set_target(temp_surface[i]);
			DRAW_CLEAR
			surface_reset_target();
		}
			
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, surface_get_width(_surf), surface_get_height(_surf), cDep);
		outputs[| 0].setValue(_outSurf);
			
		var _outUV = outputs[| 1].getValue();
		_outUV = surface_verify(_outUV, surface_get_width(_surf), surface_get_height(_surf), cDep);
		outputs[| 1].setValue(_outUV);
		
		var curf = ANIMATOR.current_frame;
		var frame_amo = _loop? _life : min(_life, curf);
		var st_frame  = curf - frame_amo;
		
		for(var i = 0; i <= frame_amo; i++) {
			var frame_idx = st_frame + i;
			var prog = (frame_idx - (curf - _life)) / _life;
			
			if(_loop && frame_idx < 0) frame_idx = ANIMATOR.frames_total + frame_idx;
			
			var prev = _loop? safe_mod(frame_idx - 1 + ANIMATOR.frames_total, ANIMATOR.frames_total) : frame_idx - 1;
			var _prevFrame = getCacheFrame(prev);
			var _currFrame = getCacheFrame(frame_idx);
			
			if(!is_surface(_currFrame)) continue;
			
			if(!is_surface(_prevFrame)) {
				surface_set_target(temp_surface[0]);
				draw_surface_safe(_currFrame, 0, 0);
				surface_reset_target();
				
				surface_set_target(temp_surface[2]);
				draw_surface_safe(_currFrame, 0, 0);
				surface_reset_target();
				continue;
			}
			
			shader_set(shader1);
			shader_set_uniform_f(uni_dimension, surface_get_width(_surf), surface_get_height(_surf));
			shader_set_uniform_f(uni_range, _rang? _rang : surface_get_width(_surf) / 2);
			shader_set_uniform_i(uni_colr, _colr);
			shader_set_uniform_i(uni_blend, _blend);
			shader_set_uniform_f(uni_seg_st, (frame_amo - i) / frame_amo);
			shader_set_uniform_f(uni_seg_sz, 1 / frame_amo);
			texture_set_stage(uni_sam_prev, surface_get_texture(_prevFrame));
			
				shader_set_uniform_i(uni_mode, 1);
				surface_set_target(temp_surface[0]);
				draw_surface_safe(_currFrame, 0, 0);
				surface_reset_target();
			
				shader_set_uniform_i(uni_mode, 0);
				surface_set_target(temp_surface[2]);
				draw_surface_safe(_currFrame, 0, 0);
				surface_reset_target();
			
			shader_reset();
		}
		
		surface_set_target(temp_surface[1]);
		shader_set(shader2);
		shader_set_uniform_f(uni2_dimension, surface_get_width(_surf), surface_get_height(_surf));
		draw_surface_safe(temp_surface[0], 0, 0);
		shader_reset();
		surface_reset_target();
		
		surface_set_target(_outUV);
		DRAW_CLEAR
		BLEND_ALPHA;
			draw_surface_safe(temp_surface[1], 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_ALPHA;
			draw_surface_safe(temp_surface[2], 0, 0);
		BLEND_NORMAL;
		surface_reset_target();
	}
	
}