function Node_PB_Fx_Strip(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Strip";
	
	inputs[| 1] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
		
	inputs[| 2] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
		
	inputs[| 3] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 );
		
	inputs[| 4] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y" ]);
	
	input_display_list = [ 0, 
		["Effect",	false], 1, 4, 2, 3, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _scal = _data[1];
		var _colr = _data[2];
		var _shft = _data[3];
		var _angl = _data[4];
		
		surface_set_shader(_nbox.content, sh_pb_strip);
			shader_set_dim(, _pbox.content);
			shader_set_f("scale",  _scal);
			shader_set_i("shift", _shft);
			shader_set_i("axis",  _angl);
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}