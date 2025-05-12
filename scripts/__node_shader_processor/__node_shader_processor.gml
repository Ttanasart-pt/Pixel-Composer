function Node_Shader_Processor(_x, _y, _group = noone) : Node_Shader(_x, _y, _group) constructor {
	name = "";
	
	newInput(0, nodeValue_Surface("Surface In", self));
		addShaderProp();
	
	attribute_surface_depth();
	
	static processShader = function(_outSurf, _data) { #region
		var _surf = _data[0];
		if(!is_surface(_surf)) return _outSurf;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		
		surface_set_shader(_outSurf, shader);
			shader_set_f("dimension", _sw, _sh);
			setShader(_data);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
	
	static processData = function(_outSurf, _data, _array_index) { #region
		return processShader(_outSurf, _data);
	} #endregion
}