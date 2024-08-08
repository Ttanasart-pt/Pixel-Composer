function Node_Normal(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Float("Height", self, 1);
	
	inputs[2] = nodeValue_Float("Smooth", self, 0, "Include diagonal pixel in normal calculation, which leads to smoother output.")
		.setDisplay(VALUE_DISPLAY.slider, { range : [ 0, 4, 0.1] });
	
	inputs[3] = nodeValue_Bool("Active", self, true);
		active_index = 3;
		
	input_display_list = [ 3,
		["Surfaces", false], 0,
		["Normal",	 false], 1, 2, 
	]
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _hei = _data[1];
		var _smt = _data[2];
		
		surface_set_shader(_outSurf, sh_normal);
			gpu_set_texfilter(true);
		
			shader_set_f("dimension", surface_get_dimension(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f("height", _hei);
			shader_set_f("smooth", _smt);
			
			draw_surface_safe(_data[0]);
			
			gpu_set_texfilter(false);
		surface_reset_shader();
		
		return _outSurf;
	}
}