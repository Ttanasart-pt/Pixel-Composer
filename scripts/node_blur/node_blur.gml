function Node_Blur(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Clamp border", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _size	= _data[1];
		var _clamp	= _data[2];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			draw_surface_safe(surface_apply_gaussian(_data[0], _size, false, c_white, _clamp), 0, 0);
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}