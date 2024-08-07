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
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	inputs[| 1] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue_Surface("Texture sample", self);
		
	inputs[| 5] = nodeValue_Enum_Scroll("Oversample mode", self,  2, [ "Empty", "Clamp", "Repeat" ]);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 2, 3,
		["Texture",	false], 4
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _sed = _data[1];
		var _pos = _data[2];
		var _sca = _data[3];
		var _sam = _data[4];
		var _samTyp = struct_try_get(attributes, "oversample");
		
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
		
		return _outSurf;
	}
}