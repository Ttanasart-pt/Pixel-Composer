function Node_PB_Fx_Outline(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Outline";
	
	inputs[| 1] = nodeValue_Bool("Corner", self, false );
		
	inputs[| 2] = nodeValue_Color("Color", self, c_white );
	
	inputs[| 3] = nodeValue_Enum_Button("Side", self,  0, [ "Inside", "Outside" ]);
	
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