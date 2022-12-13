function Node_Twirl(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Twirl";
	
	uniform_dim = shader_get_uniform(sh_twirl, "dimension");
	uniform_cen = shader_get_uniform(sh_twirl, "center");
	uniform_str = shader_get_uniform(sh_twirl, "strength");
	uniform_rad = shader_get_uniform(sh_twirl, "radius");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [-20, 20, 0.1]);
	
	inputs[| 3] = nodeValue(3, "Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		var pos = inputs[| 1].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
		inputs[| 3].drawOverlay(active, px, py, _s, _mx, _my, 0, 1, THEME.anchor_scale_hori);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		var center = _data[1];
		var stren = _data[2];
		var rad   = _data[3];
		
		shader_set(sh_twirl);
			shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_data[0]), surface_get_height(_data[0]) ]);
			shader_set_uniform_f_array(uniform_cen, center);
			shader_set_uniform_f(uniform_str, stren);
			shader_set_uniform_f(uniform_rad, rad);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}