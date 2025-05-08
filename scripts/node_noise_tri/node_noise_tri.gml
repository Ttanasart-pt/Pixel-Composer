function Node_Noise_Tri(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Triangle Noise";
	
	shader = sh_noise_grid_tri;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_ang = shader_get_uniform(shader, "angle");
	
	uniform_sam    = shader_get_uniform(shader, "useSampler");
	uniform_samTyp = shader_get_uniform(shader, "sampleMode");
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValueSeed(self));
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0, 0] ));
	
	newInput(3, nodeValue_Vec2("Scale", self, [ 4, 4 ] ));
	
	newInput(4, nodeValue_Surface("Texture sample", self));
	
	newInput(5, nodeValue_Surface("Mask", self));
	
	input_display_list = [
		["Output",	false], 0, 5, 
		["Noise",	false], 1, 2, 3,
		["Texture",	false], 4, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _sed = _data[1];
		var _pos = _data[2];
		var _sca = _data[3];
		var _sam = _data[4];
		var _samTyp = getAttribute("oversample");
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, [_dim[0], _dim[1]]);
			shader_set_uniform_f(uniform_sed, _sed);
			shader_set_uniform_f_array_safe(uniform_pos, _pos);
			shader_set_uniform_f_array_safe(uniform_sca, _sca);
			shader_set_uniform_i(uniform_sam, is_surface(_sam));
			shader_set_uniform_i(uniform_samTyp, _samTyp);
			
			if(is_surface(_sam))
				draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}