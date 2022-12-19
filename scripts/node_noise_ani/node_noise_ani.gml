function Node_Noise_Aniso(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Noise Anisotropic";
	
	shader = sh_ani_noise;
	uniform_noi = shader_get_uniform(shader, "noiseAmount");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_ang = shader_get_uniform(shader, "angle");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 16 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(9999999));
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 2, 1, 3, 4
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _amo = inputs[| 1].getValue();
		var _sed = inputs[| 2].getValue();
		var _pos = inputs[| 3].getValue();
		var _ang = inputs[| 4].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_noi, _amo);
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_sed, _sed);
			shader_set_uniform_f(uniform_ang, degtorad(_ang));
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	doUpdate();
}