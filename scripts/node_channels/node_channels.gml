function Node_RGB_Channel(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "RGB Channel";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface red", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Surface green", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 2] = nodeValue(2, "Surface blue", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, output_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			switch(output_index) {
				case 0 : shader_set(sh_channel_R); break;
				case 1 : shader_set(sh_channel_G); break;
				case 2 : shader_set(sh_channel_B); break;
			}
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}