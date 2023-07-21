function Node_PB_Fx_Subtract(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Subtract";
	
	inputs[| 1] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setVisible(true, true);
		
	input_display_list = [ 0, 
		["Effect",	false], 1,
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _subs = _data[1];
		
		surface_set_shader(_outSurf);
			draw_surface_safe(_surf);
			
			BLEND_SUBTRACT
				draw_surface_safe(_subs);
			BLEND_NORMAL
		surface_reset_shader();
		
		return _outSurf;
	}
}