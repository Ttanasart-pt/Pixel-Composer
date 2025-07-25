function Node_FXAA(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FXAA";
	
	newActiveInput(1);
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Effect
	newInput(2, nodeValue_Slider("Distance", 0.5));
	newInput(3, nodeValue_Slider("Mix", 1));
	
	input_display_list = [ 
		1, 0,
		["Effect", false], 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Mask", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outData, _data, _array_index) {
		
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