function Node_Shader_Generator(_x, _y, _group = noone) : Node_Shader(_x, _y, _group) constructor {
	name = "";
	
	newInput(0, nodeValue_Dimension(self));
		addShaderProp(SHADER_UNIFORM.float, "dimension");
	
	attribute_surface_depth();
	
	static generateShader = function(_outSurf, _data) {
		var _dim = _data[0];
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, shader);
			setShader(_data);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		if(input_mask_index) _outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		return generateShader(_outSurf, _data);
	}
}