function Node_Outline(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Outline";
	
	shader = sh_outline;
	uniform_dim          = shader_get_uniform(shader, "dimension");
	uniform_border_start = shader_get_uniform(shader, "borderStart");
	uniform_border_size  = shader_get_uniform(shader, "borderSize");
	uniform_border_color = shader_get_uniform(shader, "borderColor");
	
	uniform_blend		= shader_get_uniform(shader, "is_blend");
	uniform_blend_alpha = shader_get_uniform(shader, "blend_alpha");
	
	uniform_side		= shader_get_uniform(shader, "side");
	uniform_aa  		= shader_get_uniform(shader, "is_aa");
	
	uniform_out_only	= shader_get_uniform(shader, "outline_only");
	uniform_sam         = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Width",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	inputs[| 2] = nodeValue("Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue("Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0, "Blend outline color with the original color.");
	
	inputs[| 4] = nodeValue("Blend alpha",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue("Position",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, ["Inside", "Outside"]);
	
	inputs[| 6] = nodeValue("Anti alising",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0);
	
	inputs[| 7] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 8] = nodeValue("Start",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Shift outline inside, outside the shape.");
	
	inputs[| 9] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 10] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 11] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 11;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Outline", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 11, 
		["Surface",	 true], 0, 9, 10, 
		["Outline",	false], 1, 5, 7, 8,
		["Render",	false], 2, 3, 4, 6,
	];
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) { 
		var ww = surface_get_width(_data[0]);
		var hh = surface_get_height(_data[0]);
		var wd = _data[1];
		var cl = _data[2];
		
		var blend = _data[3];
		var alpha = _data[4];
		var side  = _data[5];
		var aa    = _data[6];
		var sam   = _data[7];
		var bst   = _data[8];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
		
			shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, [ww, hh]);
			shader_set_uniform_f(uniform_border_start, bst);
			shader_set_uniform_f(uniform_border_size, wd);
			shader_set_uniform_f_array_safe(uniform_border_color, [color_get_red(cl) / 255, color_get_green(cl) / 255, color_get_blue(cl) / 255, 1.0]);
			
			shader_set_uniform_i(uniform_side, side);
			shader_set_uniform_i(uniform_aa, aa);
			shader_set_uniform_i(uniform_out_only, _output_index);
			shader_set_uniform_i(uniform_blend, blend);
			shader_set_uniform_f(uniform_blend_alpha, alpha);
			shader_set_uniform_i(uniform_sam, sam);
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[9], _data[10]);
		
		return _outSurf;  
	}
	
	static step = function() {
		var blend = inputs[| 3].getValue();
		inputs[| 4].setVisible(blend);
	}
}