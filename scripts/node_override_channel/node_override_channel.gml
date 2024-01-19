function Node_Override_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Override Channel";
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Red",   self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 2] = nodeValue("Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 3] = nodeValue("Blue",  self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 4] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 5] = nodeValue("Sampling type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Brightness", "Channel value"]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 
		["Sampling",	false], 5, 
		["Surfaces",	 true], 1, 2, 3, 4, 
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _s = _data[0];
		var _r = _data[1];
		var _g = _data[2];
		var _b = _data[3];
		var _a = _data[4];
		var _m = _data[5];
		
		surface_set_shader(_outSurf, sh_override_channel);
			shader_set_surface("samplerR", _r);
			shader_set_surface("samplerG", _g);
			shader_set_surface("samplerB", _b);
			shader_set_surface("samplerA", _a);
			
			shader_set_i("useR", is_surface(_r));
			shader_set_i("useG", is_surface(_g));
			shader_set_i("useB", is_surface(_b));
			shader_set_i("useA", is_surface(_a));
			
			shader_set_i("mode", _m);
			
			draw_surface_safe(_s);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}