function Node_PB_Fx_Hash(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Hash";
	
	newInput(1, nodeValue_Color("Color", self, cola(c_white) ));
	
	newInput(2, nodeValue_Float("Hash", self, 2. ));
	
	newInput(3, nodeValue_Bool("Invert", self, false ));
	
	newInput(4, nodeValue_Float("Dissolve", self, 0. ))
		.setDisplay(VALUE_DISPLAY.slider)
	
	newInput(5, nodeValue_Int("Detail", self, 1 ))
	
	newInput(6, nodeValue_Vec2("Dissolve Scale", self, [ 4, 4 ] ));
	
	input_display_list = [ 0,
		["Effect",	 false], 2, 1, 3, 
		["Dissolve", false], 4, 6, 5, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		if(!is_surface(_pbox.content)) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _colr = _data[1];
		var _hash = _data[2];
		var _inv  = _data[3];
		
		var _diss = _data[4];
		var _dItr = _data[5];
		var _dSca = _data[6];
		
		surface_set_shader(_nbox.content, sh_pb_hash);
			shader_set_dim(, _pbox.content);
			shader_set_color("color", _colr);
			shader_set_f("hash", _hash);
			shader_set_i("invert", _inv);
			
			shader_set_f("dissolve", _diss);
			shader_set_f("dissolveSca", _dSca);
			shader_set_i("dissolveItr", _dItr);
			
			draw_surface_ext_safe(_pbox.content, 0, 0,,,, _colr);
		surface_reset_shader();
		
		return _nbox;
	}
}