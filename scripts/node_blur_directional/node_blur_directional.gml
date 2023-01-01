function Node_Blur_Directional(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Directional blur";
	
	shader = sh_blur_directional;
	uniform_str = shader_get_uniform(shader, "strength");
	uniform_dir = shader_get_uniform(shader, "direction");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, [0, 0.1, 0.001]);
	
	inputs[| 2] = nodeValue(2, "Direction",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width(_surf);
		var hh = surface_get_height(_surf);
		
		inputs[| 2].drawOverlay(active, _x + ww / 2 * _s, _y + hh / 2 * _s, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _str = _data[1];
		var _dir = _data[2];
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVER
		
			shader_set(shader);
			shader_set_uniform_f(uniform_str, _str);
			shader_set_uniform_f(uniform_dir, _dir + 90);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}