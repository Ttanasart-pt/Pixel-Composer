function Node_Ambient_Occlusion(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Ambient Occlusion";
	
	newActiveInput(2);
	newInput(0, nodeValue_Surface("Height Map", self));
	
	newInput(3, nodeValue_Float(  "Height",      self, 8));
	newInput(1, nodeValue_Slider( "Intensity",   self, 4, [ 0, 8, 0.1 ] ));
	newInput(4, nodeValue_Bool(   "Pixel Sweep", self, true));
	
	newInput(5, nodeValue_Bool(        "Blend Original", self, false));
	newInput(6, nodeValue_Enum_Scroll( "Blendmode",      self, 0, [ "Multiply", "Subtract" ]));
	newInput(7, nodeValue_Slider(      "Blend Strength", self, 1 ));
	
	input_display_list = [ 2, 0, 
		["Effect", false], 3, 1, 4, 
		["Blend Original", false, 5], 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _map = _data[0];
		var _int = _data[1];
		var _hei = _data[3];
		var _pxs = _data[4];
		
		var _bl  = _data[5];
		var _blm = _data[6];
		var _bls = _data[7];
		
		surface_set_shader(_outSurf, sh_sao);
			shader_set_dim("dimension", _map);
			shader_set_f("intensity",   _int);
			shader_set_f("height",      _hei);
			shader_set_i("pixel",       _pxs);
			
			shader_set_i("blend",         _bl);
			shader_set_i("blendMode",     _blm);
			shader_set_f("blendStrength", _bls);
			
			draw_surface_safe(_map);
		surface_reset_shader();
		
		return _outSurf;
	}
}