function Node_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
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
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Displace map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 0], "Vector to displace pixel by." )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue("Strength",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 4] = nodeValue("Mid value",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0., "Brightness value to be use as a basis for 'no displacement'.")
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 5] = nodeValue("Color data",  self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"Use color data set extra information.
    - Ignore: Don't use color data.
    - Vector: Use red as X displacement, green as Y displacement.
    - Angle: Use red as angle, green as distance.")
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Ignore", "Vector", "Angle" ]);
	
	inputs[| 6] = nodeValue("Iterate",  self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, @"If not set, then strength value is multiplied directly to the displacement.
If set, then strength value control how many times the effect applies on itself.");
	
	inputs[| 7] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 8] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 10] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 10;
	
	input_display_list = [ 10, 
		["Output", 		 true],	0, 8, 9, 
		["Displace",	false], 1, 3, 4, 
		["Color",		false], 5, 2, 
		["Algorithm",	 true],	6
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
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
		
		surface_set_shader(_outSurf, shader);
		shader_set_interpolation(_data[0]);
			texture_set_stage(displace_map_sample, surface_get_texture(_data[1]));
			shader_set_uniform_f_array_safe(uniform_dim, [ww, hh]);
			shader_set_uniform_f_array_safe(uniform_map_dim, [mw, mh]);
			shader_set_uniform_f_array_safe(uniform_position, _data[2]);
			shader_set_uniform_f(uniform_strength, _data[3]);
			shader_set_uniform_f(uniform_mid, _data[4]);
			shader_set_uniform_i(uniform_rg, _data[5]);
			shader_set_uniform_i(uniform_it, _data[6]);
			shader_set_uniform_i(uniform_sam, ds_map_try_get(attributes, "oversample"));
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[8], _data[9]);
		
		return _outSurf;
	}
}