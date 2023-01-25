function Node_Skew(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Skew";
	
	shader = sh_skew;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_cen = shader_get_uniform(shader, "center");
	uniform_axs = shader_get_uniform(shader, "axis");
	uniform_amo = shader_get_uniform(shader, "amount");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["x", "y"]);
	
	inputs[| 2] = nodeValue(2, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 3] = nodeValue(3, "Wrap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 4] = nodeValue(4, "Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector, button(function() { centerAnchor(); })
												.setIcon(THEME.anchor)
												.setTooltip("Set to center"));
	
	inputs[| 5] = nodeValue(5, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	input_display_list = [
		["Surface",	false],	0, 5, 
		["Skew",	false],	1, 2, 4,
	]
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static centerAnchor = function() {
		if(!is_surface(current_data[0])) return;
		var ww = surface_get_width(current_data[0]);
		var hh = surface_get_height(current_data[0]);
		
		inputs[| 4].setValue([ww / 2, hh / 2]);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _axis = _data[1];
		var _amou = _data[2];
		//var _wrap = _data[3];
		var _cent = _data[4];
		var _samp = _data[5];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_data[0]), surface_get_height(_data[0]));
			shader_set_uniform_f(uniform_cen, _cent[0], _cent[1]);
			shader_set_uniform_i(uniform_axs, _axis);
			shader_set_uniform_f(uniform_amo, _amou);
			shader_set_uniform_i(uniform_sam, _samp);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}