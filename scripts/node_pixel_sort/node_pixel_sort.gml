function Node_Pixel_Sort(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Sort";
	
	shader = sh_pixel_sort;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_itr = shader_get_uniform(shader, "iteration");
	uniform_tre = shader_get_uniform(shader, "threshold");
	uniform_dir = shader_get_uniform(shader, "direction");
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 2] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation, { step: 90 });
	
	inputs[| 4] = nodeValue_Surface("Mask", self);
	
	inputs[| 5] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 6;
	
	inputs[| 7] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(4); // inputs 8, 9
	
	input_display_list = [ 6, 7, 
		["Surfaces",	 true], 0, 4, 5, 8, 9, 
		["Pixel sort",	false], 1, 2, 3, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _in = _data[0];
		
		var _it = _data[1];
		var _tr = _data[2];
		var _dr = floor(_data[3] / 90) % 4;
		if(_dr < 0)  _dr = 4 + _dr;
		if(_it <= 0) {
			surface_set_target(_outSurf);
				BLEND_OVERRIDE;
				draw_surface_safe(_in);
				BLEND_NORMAL;
			surface_reset_target();
		
			return _outSurf;
		}
		
		var sw = surface_get_width_safe(_outSurf);
		var sh = surface_get_height_safe(_outSurf);
		
		var pp = [ surface_create_valid(sw, sh), surface_create_valid(sw, sh) ];
		var sBase, sDraw;
		
		surface_set_target(pp[1]);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			draw_surface_safe(_in);
			BLEND_NORMAL;
		surface_reset_target();
		
		shader_set(shader);
		shader_set_uniform_f(uniform_dim, surface_get_width_safe(_in), surface_get_height_safe(_in));
		shader_set_uniform_f(uniform_tre, _tr);
		shader_set_uniform_i(uniform_dir, _dr);
		
		for( var i = 0; i < _it; i++ ) {
			var it = i % 2;
			sBase = pp[it];
			sDraw = pp[!it];
			
			surface_set_target(sBase);
			DRAW_CLEAR
			BLEND_OVERRIDE;
				shader_set_uniform_f(uniform_itr, i);
				draw_surface_safe(sDraw);
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_target(_outSurf);
			BLEND_OVERRIDE;
			draw_surface_safe(sBase);
			BLEND_NORMAL;
		surface_reset_target();
		
		surface_free(pp[0]);
		surface_free(pp[1]); 
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	} #endregion
}