function Node_Displace(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Displace";
	
	shader = sh_displace;
	displace_map_sample  = shader_get_sampler_index(shader, "map");
	uniform_dim          = shader_get_uniform(shader, "dimension");
	uniform_map_dim      = shader_get_uniform(shader, "map_dimension");
	uniform_position     = shader_get_uniform(shader, "displace");
	uniform_strength     = shader_get_uniform(shader, "strength");
	uniform_mid          = shader_get_uniform(shader, "middle");
	uniform_rg           = shader_get_uniform(shader, "use_rg");
	uniform_it           = shader_get_uniform(shader, "iterate");
	uniform_sam          = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Displace map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 0] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue(3, "Strength",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	inputs[| 4] = nodeValue(4, "Mid value",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 5] = nodeValue(5, "Color data",  self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Ignore", "Vector", "Angle" ]);
	
	inputs[| 6] = nodeValue(6, "Iterate",  self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue(7, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	input_display_list = [ 
		["Surface",		true],	0, 7, 
		["Displace",	false], 1, 3, 4, 
		["Color",		false], 5, 2, 
		["Algorithm",	true],	6
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		switch(_data[5]) {
			case 0 :
				inputs[| 2].setVisible(true);
				break;
			case 1 :
			case 2 :
				inputs[| 2].setVisible(false);
				break;
		}
		var ww = surface_get_width(_data[0]);
		var hh = surface_get_height(_data[0]);
		var mw = surface_get_width(_data[1]);
		var mh = surface_get_height(_data[1]);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVER
		
			shader_set(shader);
			texture_set_stage(displace_map_sample, surface_get_texture(_data[1]));
			shader_set_uniform_f_array(uniform_dim, [ww, hh]);
			shader_set_uniform_f_array(uniform_map_dim, [mw, mh]);
			shader_set_uniform_f_array(uniform_position, _data[2]);
			shader_set_uniform_f(uniform_strength, _data[3]);
			shader_set_uniform_f(uniform_mid, _data[4]);
			shader_set_uniform_i(uniform_rg, _data[5]);
			shader_set_uniform_i(uniform_it, _data[6]);
			shader_set_uniform_i(uniform_sam, _data[7]);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}