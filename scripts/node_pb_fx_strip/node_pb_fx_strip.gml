function Node_PB_Fx_Strip(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Strip";
	
	newInput(1, nodeValue_Int("Scale", self, 1 ));
		
	newInput(2, nodeValue_Color("Color", self, cola(c_white) ));
		
	newInput(3, nodeValue_Int("Shift", self, 0 ));
		
	newInput(4, nodeValue_Enum_Button("Axis", self,  0 , [ "X", "Y" ]));
	
	input_display_list = [ 0, 
		["Effect",	false], 1, 4, 2, 3, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		if(!is_surface(_pbox.content)) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _scal = _data[1];
		var _colr = _data[2];
		var _shft = _data[3];
		var _angl = _data[4];
		
		surface_set_shader(_nbox.content, sh_pb_strip);
			shader_set_dim(, _pbox.content);
			shader_set_f("scale", _scal);
			shader_set_i("shift", _shft);
			shader_set_i("axis",  _angl);
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}