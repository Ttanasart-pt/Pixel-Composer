function Node_Brush_Linear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Brush";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
	
	inputs[| 2] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 10)
		.setValidator(VV_min(1));
	
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) })
	
	inputs[| 4] = nodeValue("Length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10);
	
	inputs[| 5] = nodeValue("Attenuation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.99)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Circulation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.8)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1,
		["Surface", false], 0, 
		["Effect",  false], 2, 4, 5, 6, 
	];
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_brush_linear);
			shader_set_f("dimension",             surface_get_dimension(_data[0]));
			shader_set_f("seed",                  _data[3]);
			shader_set_i("convStepNums",          _data[2]);
			shader_set_f("itrStepPixLen",         _data[4]);
			shader_set_f("distanceAttenuation",   _data[5]);
			shader_set_f("vectorCirculationRate", _data[6]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}