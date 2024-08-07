function Node_Override_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Override Channel";
	
	inputs[| 0] = nodeValue_Surface("Surface", self);
	
	inputs[| 1] = nodeValue_Surface("Red",   self);
	inputs[| 2] = nodeValue_Surface("Green", self);
	inputs[| 3] = nodeValue_Surface("Blue",  self);
	inputs[| 4] = nodeValue_Surface("Alpha", self);
	
	inputs[| 5] = nodeValue_Enum_Scroll("Sampling type", self,  0, ["Brightness", "Channel value"]);
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
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