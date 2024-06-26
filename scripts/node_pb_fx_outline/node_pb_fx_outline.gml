function Node_PB_Fx_Outline(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Outline";
	
	inputs[| 1] = nodeValue("Corner", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
		
	inputs[| 2] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 3] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Inside", "Outside" ]);
	
	input_display_list = [ 0, 
		["Effect",	false], 3, 1, 2, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		if(!is_surface(_pbox.content)) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _corn = _data[1];
		var _colr = _data[2];
		var _side = _data[3];
		
		surface_set_shader(_nbox.content, sh_pb_outline);
			shader_set_dim(, _pbox.content);
			shader_set_i("corner", _corn);
			shader_set_i("side", _side);
			DRAW_CLEAR
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}