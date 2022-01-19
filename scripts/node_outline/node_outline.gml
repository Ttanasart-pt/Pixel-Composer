function Node_create_Outline(_x, _y) {
	var node = new Node_Outline(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Outline(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Outline";
	
	uniform_dim          = shader_get_uniform(sh_outline, "dimension");
	uniform_border_size  = shader_get_uniform(sh_outline, "borderSize");
	uniform_border_color = shader_get_uniform(sh_outline, "borderColor");
	
	uniform_blend		= shader_get_uniform(sh_outline, "is_blend");
	uniform_blend_alpha = shader_get_uniform(sh_outline, "blend_alpha");
	
	uniform_side		= shader_get_uniform(sh_outline, "side");
	uniform_aa  		= shader_get_uniform(sh_outline, "is_aa");
	
	uniform_out_only	= shader_get_uniform(sh_outline, "outline_only");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Width",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	inputs[| 2] = nodeValue(2, "Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue(3, "Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0);
	
	inputs[| 4] = nodeValue(4, "Blend alpha",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue(5, "Position",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["Inside", "Outside"]);
	
	inputs[| 6] = nodeValue(6, "Anti alising",   self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	outputs[| 1] = nodeValue(1, "Outline", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static process_data = function(_outSurf, _data, _output_index) {
		var ww = surface_get_width(_data[0]);
		var hh = surface_get_height(_data[0]);
		var wd = _data[1];
		var cl = _data[2];
		
		var blend = _data[3];
		var alpha = _data[4];
		var side  = _data[5];
		var aa    = _data[6];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
		
			shader_set(sh_outline);
			shader_set_uniform_f_array(uniform_dim, [ww, hh]);
			shader_set_uniform_f(uniform_border_size, wd);
			shader_set_uniform_f_array(uniform_border_color, [color_get_red(cl) / 255, color_get_green(cl) / 255, color_get_blue(cl) / 255, 1.0]);
			
			shader_set_uniform_i(uniform_side, side);
			shader_set_uniform_i(uniform_aa, aa);
			shader_set_uniform_i(uniform_out_only, _output_index);
			shader_set_uniform_i(uniform_blend, blend);
			shader_set_uniform_f(uniform_blend_alpha, alpha);
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
	
	static step = function() {
		var blend = inputs[| 3].getValue();
		inputs[| 4].show_in_inspector = blend;
	}
}