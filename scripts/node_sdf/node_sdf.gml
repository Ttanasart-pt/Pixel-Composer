function Node_SDF(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "SDF";
	
	uniform_sdf_dim = shader_get_uniform(sh_sdf, "dimension");
	uniform_sdf_stp = shader_get_uniform(sh_sdf, "stepSize");
	uniform_sdf_sid = shader_get_uniform(sh_sdf, "side");
	
	uniform_dst_sid = shader_get_uniform(sh_sdf_dist, "side");
	uniform_dst_dst = shader_get_uniform(sh_sdf_dist, "max_distance");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
	
	inputs[| 2] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Inside", "Outside", "Both" ]);
	
	inputs[| 3] = nodeValue("Max distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 2, 0.01 ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1,
		["Surface",	false], 0, 
		["SDF",		false], 2, 3, 
	]
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		var _side  = _data[2];
		var _dist  = _data[3];
		var sw = surface_get_width(inSurf);
		var sh = surface_get_height(inSurf);
		var n  = max(sw, sh);
		
		temp_surface[0]  = surface_verify(temp_surface[0], n, n);
		temp_surface[1]  = surface_verify(temp_surface[1], n, n);
		_outSurf = surface_verify(_outSurf, sw, sh);
		
		surface_set_target(temp_surface[0]);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
		
		shader_set(sh_sdf_tex);
			draw_surface_safe(inSurf, 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		var step = ceil(log2(n));
		var stepSize = power(2, step);
		var bg = 0;
		//step = 2;
		
		repeat(step) {
			stepSize /= 2;
			bg = !bg;
			
			surface_set_target(temp_surface[bg]);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
			
			shader_set(sh_sdf);
				shader_set_uniform_f(uniform_sdf_dim, n, n );
				shader_set_uniform_f(uniform_sdf_stp, stepSize);
				shader_set_uniform_i(uniform_sdf_sid, _side);
				draw_surface_safe(temp_surface[!bg], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
		
		shader_set(sh_sdf_dist);
			shader_set_uniform_i(uniform_dst_sid, _side);
			shader_set_uniform_f(uniform_dst_dst, _dist);
			draw_surface_safe(temp_surface[bg], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}