function Node_Edge_Detect(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Edge Detect";
	
	shader = sh_edge_detect;
	uniform_dim    = shader_get_uniform(shader, "dimension");
	uniform_filter = shader_get_uniform(shader, "filter");
	uniform_sam    = shader_get_uniform(shader, "sampleMode");
	
	newInput(0, nodeValue_Surface("Surface in self", self));
	
	newInput(1, nodeValue_Enum_Scroll("Algorithm", self,  0, ["Sobel", "Prewitt", "Laplacian", "Neighbor max diff"] ));
	
	newInput(2, nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
		
	__init_mask_modifier(3); // inputs 7, 8
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6, 
		["Surfaces",	 true],	0, 3, 4, 7, 8, 
		["Edge detect",	false],	1, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var ft = _data[1];
		var ov = struct_try_get(attributes, "oversample");
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, [surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0])]);
			shader_set_uniform_i(uniform_filter, ft);
			shader_set_uniform_i(uniform_sam, ov);
			draw_surface_safe(_data[0]);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}