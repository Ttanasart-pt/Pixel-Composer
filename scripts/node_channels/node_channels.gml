function Node_RGB_Channel(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "RGB Extract";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Output type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Channel value", "Greyscale"]);
	
	outputs[| 0] = nodeValue(0, "Red", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Green", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 2] = nodeValue(2, "Blue", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 3] = nodeValue(3, "Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, output_index) {
		var _out = _data[1];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE
			switch(output_index) {
				case 0 : shader_set(_out? sh_channel_R_grey : sh_channel_R); break;
				case 1 : shader_set(_out? sh_channel_G_grey : sh_channel_G); break;
				case 2 : shader_set(_out? sh_channel_B_grey : sh_channel_B); break;
				case 3 : shader_set(sh_channel_A); break;
			}
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}