function Node_Shader_Generator(_x, _y, _group = noone) : Node_Shader(_x, _y, _group) constructor {
	name = "";
	
	inputs[| 0] = nodeValue_Dimension(self);
		addShaderProp(SHADER_UNIFORM.float, "u_resolution");
	
	attribute_surface_depth();
	
	static generateShader = function(_outSurf, _data) { #region
		var _dim = _data[0];
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, shader);
			setShader(_data);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		return generateShader(_outSurf, _data);
	} #endregion
}