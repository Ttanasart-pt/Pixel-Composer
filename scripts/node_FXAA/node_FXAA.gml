function Node_FXAA(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FXAA";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
	
	newInput(2, nodeValue_Float("Distance", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	active_index = 1;
	
	input_display_list = [ 
		1, 0,
		["Effect", false], 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Mask", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		
		var _dim = surface_get_dimension(_data[0]);
		_outData[0] = surface_verify(_outData[0], _dim[0], _dim[1]);
		_outData[1] = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		surface_set_target_ext(0, _outData[0]);
		surface_set_target_ext(1, _outData[1]);
		shader_set(sh_FXAA);
		DRAW_CLEAR
		BLEND_OVERRIDE
		gpu_set_tex_filter(true);
			shader_set_2("dimension", _dim);
			shader_set_f("cornerDis", _data[2]);
			shader_set_f("mixAmo",    _data[3]);
			
			draw_surface_safe(_data[0]);
		gpu_set_tex_filter(false);
		BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		return _outData;
	}
}