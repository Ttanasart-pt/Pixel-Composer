function Node_Noise_Hex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Hexagonal Noise";
	
	shader = sh_noise_grid_hex;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_ang = shader_get_uniform(shader, "angle");
	
	uniform_sam    = shader_get_uniform(shader, "useSampler");
	uniform_samTyp = shader_get_uniform(shader, "sampleMode");
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	newInput(5, nodeValue_Surface( "Mask" ));
	
	////- =Noise
	newInput(1, nodeValueSeed());
	newInput(2, nodeValue_Vec2( "Position", [0,0] )).setHotkey("G");
	newInput(3, nodeValue_Vec2( "Scale",    [8,8] )).setHotkey("S");
	
	////- =Texture
	newInput(4, nodeValue_Surface( "Texture Sample" ));
	// input 6
	
	input_display_list = [
		["Output",	false], 0, 5, 
		["Noise",	false], 1, 2, 3,
		["Texture",	false], 4
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getSingleValue(2);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
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