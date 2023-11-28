function Node_Combine_RGB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RGB Combine";
	dimension_index = -1;
	
	inputs[| 0] = nodeValue("Red",   self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 1] = nodeValue("Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 2] = nodeValue("Blue",  self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 3] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Sampling type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Brightness", "Channel value"]);
	
	inputs[| 5] = nodeValue("Base value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Set value to the unconnected color channels.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Sampling",	false], 4, 5, 
		["Surfaces",	 true], 0, 1, 2, 3,
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _r    = _data[0];
		var _g    = _data[1];
		var _b    = _data[2];
		var _a    = _data[3];
		var _mode = _data[4];
		var _base = _data[5];
		
		var _baseS = _r;
		if(!is_surface(_baseS)) _baseS = _g;
		if(!is_surface(_baseS)) _baseS = _b;
		if(!is_surface(_baseS)) return _outSurf;
		
		_outSurf = surface_verify(_outSurf, surface_get_width_safe(_baseS), surface_get_height_safe(_baseS));
		
		surface_set_shader(_outSurf, sh_combine_rgb);
			shader_set_surface("samplerR", _r);
			shader_set_surface("samplerG", _g);
			shader_set_surface("samplerB", _b);
			shader_set_surface("samplerA", _a);
			
			shader_set_i("useR", is_surface(_r));
			shader_set_i("useG", is_surface(_g));
			shader_set_i("useB", is_surface(_b));
			shader_set_i("useA", is_surface(_a));
			
			shader_set_f("base", _base);
			shader_set_i("mode", _mode);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}