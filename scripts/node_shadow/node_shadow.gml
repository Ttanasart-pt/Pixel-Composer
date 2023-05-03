function Node_Shadow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shadow";
	
	shader = sh_outline_only;
	uniform_dim  = shader_get_uniform(shader, "dimension");
	uniform_size = shader_get_uniform(shader, "borderSize");
	uniform_colr = shader_get_uniform(shader, "borderColor");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 2] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 2, 0.01]);
	
	inputs[| 3] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue("Grow", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 1]);
	
	inputs[| 5] = nodeValue("Blur", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 1]);
	
	inputs[| 6] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 7] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 8, 
		["Output",  true], 0, 6, 7, 
		["Shadow", false], 1, 2, 3, 4, 5, 
	];
	
	surface_blur_init();
	attribute_surface_depth();
		
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
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var cl      = _data[1];
		var _stre   = _data[2];
		var _shf    = _data[3];
		var _border = _data[4];
		var _size   = _data[5];
		
		var pass1   = surface_create_valid(surface_get_width(_outSurf), surface_get_height(_outSurf), attrDepth());	
		
		surface_set_target(pass1);
		DRAW_CLEAR
		BLEND_OVERRIDE;
			shader_set(shader);
				shader_set_uniform_f_array_safe(uniform_dim,  [ surface_get_width(_outSurf), surface_get_height(_outSurf) ]);
				shader_set_uniform_f(uniform_size, _border);
				shader_set_uniform_f_array_safe(uniform_colr, [1., 1., 1., 1.0]);
				
				draw_surface_safe(_data[0], _shf[0], _shf[1]);
			shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
			draw_surface_ext_safe(surface_apply_gaussian(pass1, _size, false, cl), 0, 0, 1, 1, 0, cl, _stre);
		BLEND_NORMAL;
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_target();
		surface_free(pass1);
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		
		return _outSurf;
	}
}