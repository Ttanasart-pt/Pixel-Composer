function Node_PB_Fx_Radial(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Radial";
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 )
		.setVisible(true, true);
		
	input_display_list = [ 0, 
		["Effect",	false], 1,
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _amo  = _data[1];
		
		surface_set_shader(_outSurf);
			for( var i = 0; i < _amo; i++ ) {
				var aa = i / _amo * 360;
				var p  = point_rotate(0, 0, surface_get_width(_outSurf) / 2, surface_get_height(_outSurf) / 2, aa);
				
				draw_surface_ext_safe(_surf, p[0], p[1],,, aa);
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}