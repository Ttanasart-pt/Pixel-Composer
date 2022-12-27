function Node_Shadow(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Shadow";
	
	shader = sh_outline_only;
	uniform_dim  = shader_get_uniform(shader, "dimension");
	uniform_size = shader_get_uniform(shader, "borderSize");
	uniform_colr = shader_get_uniform(shader, "borderColor");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 2] = nodeValue(2, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 2, 0.01]);
	
	inputs[| 3] = nodeValue(3, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(0, index); });
	
	inputs[| 4] = nodeValue(4, "Grow", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 1]);
	
	inputs[| 5] = nodeValue(5, "Blur", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 1]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width(_surf) * _s;
		var hh = surface_get_height(_surf) * _s;
		
		inputs[| 3].drawOverlay(active, _x + ww / 2, _y + hh / 2, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var cl      = _data[1];
		var _stre   = _data[2];
		var _shf    = _data[3];
		var _border = _data[4];
		var _size   = _data[5];
		
		var pass1   = surface_create_valid(surface_get_width(_outSurf), surface_get_height(_outSurf));	
		
		surface_set_target(pass1);
		draw_clear_alpha(0, 0);
		BLEND_OVER
			shader_set(shader);
				shader_set_uniform_f_array(uniform_dim,  [ surface_get_width(_outSurf), surface_get_height(_outSurf) ]);
				shader_set_uniform_f(uniform_size, _border);
				shader_set_uniform_f_array(uniform_colr, [1., 1., 1., 1.0]);
				
				draw_surface_safe(_data[0], _shf[0], _shf[1]);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		pass1 = surface_apply_gaussian(pass1, _size, false, cl);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
			draw_surface_ext_safe(pass1, 0, 0, 1, 1, 0, cl, _stre);
		BLEND_NORMAL
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_target();
		
		surface_free(pass1);
		
		return _outSurf;
	}
}