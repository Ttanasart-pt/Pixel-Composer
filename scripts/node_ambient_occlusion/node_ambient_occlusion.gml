function Node_Ambient_Occlusion(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Ambient Occlusion";
	
	newInput(0, nodeValue_Surface("Height Map", self));
	
	newInput(1, nodeValue_Float("Intensity", self, 4))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 8, 0.1 ] });
	
	newInput(2, nodeValue_Bool("Active", self, true));
		active_index = 2;
	
	newInput(3, nodeValue_Float("Height", self, 8));
	
	newInput(4, nodeValue_Bool("Pixel Sweep", self, true));
	
	input_display_list = [ 2, 0, 
		["Effect",		false], 3, 1, 4, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _map = _data[0];
		var _int = _data[1];
		var _hei = _data[3];
		var _pxs = _data[4];
		
		var _dim = surface_get_dimension(_map);
		
		surface_set_shader(_outSurf, sh_sao);
			shader_set_f("dimension", _dim);
			shader_set_f("intensity", _int);
			shader_set_f("height",    _hei);
			shader_set_i("pixel",     _pxs);
			
			draw_surface_safe(_map);
		surface_reset_shader();
		
		return _outSurf;
	}
}