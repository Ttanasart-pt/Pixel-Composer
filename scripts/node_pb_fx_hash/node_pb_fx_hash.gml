function Node_PB_Fx_Hash(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Hash";
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 2] = nodeValue("Hash", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2. );
	
	inputs[| 3] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [ 0,
		["Effect",	false], 2, 1, 3, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _colr = _data[1];
		var _hash = _data[2];
		var _inv  = _data[3];
		
		surface_set_shader(_outSurf, sh_pb_hash);
			shader_set_dim(, _surf);
			shader_set_color("color", _colr);
			shader_set_f("hash", _hash);
			shader_set_i("invert", _inv);
			DRAW_CLEAR
			
			draw_surface_ext_safe(_surf, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _outSurf;
	}
}