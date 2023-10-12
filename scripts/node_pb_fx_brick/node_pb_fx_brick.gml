function Node_PB_Fx_Brick(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Brick";
	
	inputs[| 1] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 4, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y" ] );
	
	inputs[| 3] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 4] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 5] = nodeValue("Dissolve", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0. )
		.setDisplay(VALUE_DISPLAY.slider)
	
	inputs[| 6] = nodeValue("Detail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
	
	inputs[| 7] = nodeValue("Dissolve Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	input_display_list = [ 0,
		["Effect",	 false], 1, 2, 3, 4, 
		["Dissolve", false], 5, 7, 6, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		if(!is_surface(_pbox.content)) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _scal = _data[1];
		var _axis = _data[2];
		var _shft = _data[3];
		var _colr = _data[4];
		
		var _diss = _data[5];
		var _dItr = _data[6];
		var _dSca = _data[7];
		
		surface_set_shader(_nbox.content, sh_pb_brick);
			shader_set_dim(, _pbox.content);
			shader_set_f("scale", _scal);
			shader_set_i("axis",  _axis);
			shader_set_f("shift", _shft);
			
			shader_set_f("dissolve", _diss);
			shader_set_f("dissolveSca", _dSca);
			shader_set_i("dissolveItr", _dItr);
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}