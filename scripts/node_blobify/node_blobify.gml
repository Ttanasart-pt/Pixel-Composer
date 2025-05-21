function Node_Blobify(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blobify";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Bool("Active", true));
	
	newInput(2, nodeValue_Int("Radius", 3))
		.setValidator(VV_min(0));
	
	newInput(3, nodeValue_Float("Threshold", 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	active_index = 1;
	
	input_display_list = [ 1, 
		["Surface", false], 0, 
		["Blobify", false], 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) { #region	
		var _rad = _data[2];
		var _thr = _data[3];
		
		surface_set_shader(_outSurf, sh_blobify);
			shader_set_f("dimension", surface_get_dimension(_data[0]));
			shader_set_f("radius",    _rad);
			shader_set_f("threshold", _thr);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}