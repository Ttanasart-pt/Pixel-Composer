function Node_Edge_Detect(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Edge Detect";
	
	shader = sh_edge_detect;
	uniform_dim    = shader_get_uniform(shader, "dimension");
	uniform_filter = shader_get_uniform(shader, "filter");
	uniform_sam    = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue("Surface in",	 self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Algorithm",		 self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Sobel", "Prewitt", "Laplacian", "Neighbor max diff"] );
	
	inputs[| 2] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 5, 
		["Output",		 true],	0, 3, 4, 
		["Edge detect",	false],	1, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var ft = _data[1];
		var ov = ds_map_try_get(attributes, "oversample");
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_i(uniform_filter, ft);
			shader_set_uniform_i(uniform_sam, ov);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		
		return _outSurf;
	}
}