function Node_Scale(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 2] = nodeValue(2, "Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Upscale", "Scale to fit" ]);
	
	inputs[| 3] = nodeValue(3, "Target dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 
		["Surface",  true], 0,
		["Scale",	false], 2, 1, 3,
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var scale	= _data[1];
		var mode	= _data[2];
		var targ	= _data[3];
		
		inputs[| 1].setVisible(mode == 0);
		inputs[| 3].setVisible(mode == 1);
		
		var ww, hh;
		switch(mode) {
			case 0 :
				ww	= scale * surface_get_width(_data[0]);
				hh	= scale * surface_get_height(_data[0]);
				break;
			case 1 :
				ww	= targ[0];
				hh	= targ[1];
				break;
		}
		
		_outSurf = surface_verify(_outSurf, ww, hh);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			draw_surface_stretched_safe(_data[0], 0, 0, ww, hh);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}