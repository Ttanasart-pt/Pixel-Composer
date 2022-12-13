function Node_Noise(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Noise";
	
	shader = sh_noise;
	uniform_sed = shader_get_uniform(shader, "seed");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(99999));
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _sed = inputs[| 1].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f(uniform_sed, _sed);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	doUpdate();
}