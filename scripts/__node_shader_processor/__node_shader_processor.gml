function Node_Shader_Processor(_x, _y, _group = noone) : Node_Shader(_x, _y, _group) constructor {
	name = "";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp();
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _surf = _data[0];
		if(!is_surface(_surf)) return _outSurf;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		
		surface_set_shader(_outSurf, shader);
			setShader(_data);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}