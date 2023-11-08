function Node_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Trail";
	use_cache   = CACHE_USE.manual;
	clearCacheOnChange = false;
	
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
		["Surfaces",		 true], 0, 
		["Trail settings",	false], 1, 2,
		["Tracking",		false], 3, 4, 5, 
		["Modification",	false], 6, 
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() {
		var _colr  = getInputData(4);
		
		inputs[| 5].setVisible(!_colr);
	}
	
	static update = function() {
		if(!inputs[| 0].value_from) return;
		
		var _surf  = getInputData(0);
		var _life  = getInputData(1);
		var _loop  = getInputData(2);
		if(!is_real(_loop)) _loop = false;
		
		var _rang  = getInputData(3);
		var _colr  = getInputData(4);
		var _blend = getInputData(5);
		var _alpha = getInputData(6);
		var cDep   = attrDepth();
		if(!is_surface(_surf)) return;
		cacheCurrentFrame(_surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], surface_get_width_safe(_surf), surface_get_height_safe(_surf), cDep);
			surface_set_target(temp_surface[i]);
			DRAW_CLEAR
			surface_reset_target();
		}
			
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, surface_get_width_safe(_surf), surface_get_height_safe(_surf), cDep);
		outputs[| 0].setValue(_outSurf);
			
		var _outUV = outputs[| 1].getValue();
		_outUV = surface_verify(_outUV, surface_get_width_safe(_surf), surface_get_height_safe(_surf), cDep);
		outputs[| 1].setValue(_outUV);
		
		var curf = CURRENT_FRAME;
		var frame_amo = _loop? _life : min(_life, curf);
		var st_frame  = curf - frame_amo;
		
		BLEND_NORMAL
		for(var i = 0; i <= frame_amo; i++) {
			var frame_idx = st_frame + i;
			var prog  = (frame_idx - (curf - _life)) / _life;
			
			var a0 = eval_curve_x(_alpha, 1 -       i / (frame_amo + 1));
			var a1 = eval_curve_x(_alpha, 1 - (i + 1) / (frame_amo + 1));
			
			if(_loop && frame_idx < 0) frame_idx = TOTAL_FRAMES + frame_idx;
			
			var prev = _loop? safe_mod(frame_idx - 1 + TOTAL_FRAMES, TOTAL_FRAMES) : frame_idx - 1;
			var _prevFrame = getCacheFrame(prev);
			var _currFrame = getCacheFrame(frame_idx);
			
			if(!is_surface(_currFrame)) continue;
			
			if(!is_surface(_prevFrame)) {
				surface_set_target(temp_surface[0]);
				draw_surface_ext_safe(_currFrame, 0, 0, 1, 1, 0, c_white, a0);
				surface_reset_target();
				
				surface_set_target(temp_surface[2]);
				draw_surface_ext_safe(_currFrame, 0, 0, 1, 1, 0, c_white, a1);
				surface_reset_target();
				continue;
			}
			
			shader_set(sh_trail_filler_pass1);
			shader_set_dim("dimension",  _surf);
			shader_set_f("range",		 _rang? _rang : surface_get_width_safe(_surf) / 2);
			shader_set_i("matchColor",	 _colr);
			shader_set_i("blendColor",	 _blend);
			shader_set_f("segmentStart", (frame_amo - i) / frame_amo);
			shader_set_f("segmentSize",  1 / frame_amo);
			shader_set_surface("prevFrame", _prevFrame);
			shader_set_f("alphaPrev",	 a0);
			shader_set_f("alphaCurr",	 a1);
			
				shader_set_i("mode", 1);
				surface_set_target(temp_surface[0]);
				draw_surface_safe(_currFrame);
				surface_reset_target();
			
				shader_set_i("mode", 0);
				surface_set_target(temp_surface[2]);
				draw_surface_safe(_currFrame);
				surface_reset_target();
			
			shader_reset();
		}
		BLEND_NORMAL
		
		surface_set_target(temp_surface[1]);
			shader_set(sh_trail_filler_pass2);
			shader_set_dim("dimension", _surf);
			draw_surface_safe(temp_surface[0], 0, 0);
			shader_reset();
		surface_reset_target();
		
		surface_set_shader(_outUV);
			draw_surface_safe(temp_surface[1], 0, 0);
		surface_reset_shader();
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[2], 0, 0);
		surface_reset_shader();
	}
	
}