function Node_Blobify(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blobify";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 2] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	active_index = 1;
	
	input_display_list = [ 1, 
		["Surface", false], 0, 
		["Blobify", false], 2, 3, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
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