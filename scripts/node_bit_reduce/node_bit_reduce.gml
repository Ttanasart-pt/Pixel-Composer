function Node_Bit_Reduce(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	static dither2 = [  0,  2,
					    3,  1 ];
	static dither4 = [  0,  8,  2, 10,
					   12,  4, 14,  6,
					    3, 11,  1,  9,
					   15,  7, 13,  5];
	static dither8 = [  0, 32,  8, 40,  2, 34, 10, 42, 
					   48, 16, 56, 24, 50, 18, 58, 26,
					   12, 44,  4, 36, 14, 46,  6, 38, 
					   60, 28, 52, 20, 62, 30, 54, 22,
					    3, 35, 11, 43,  1, 33,  9, 41,
					   51, 19, 59, 27, 49, 17, 57, 25,
					   15, 47,  7, 39, 13, 45,  5, 37,
					   63, 31, 55, 23, 61, 29, 53, 21];
	
	name = "Quantize Colors";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Enum_Scroll("Color Space", self, 0, [ "RGB", "HSV", "OKLAB", "YIQ" ]));
	
	newInput(2, nodeValue_Vec3("Amount", self, [ 4, 4, 4 ]));
	
	newInput(3, nodeValue_Bool("Dithering", self, false));
	
	newInput(4, nodeValue_Enum_Scroll("Pattern", self,  0, [ "2 x 2 Bayer", "4 x 4 Bayer", "8 x 8 Bayer" ]));
	
	newInput(5, nodeValue_Float("Contrast", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 5, 0.1] });
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [  
		["Surfaces",   true], 0,  
		["Quantize",  false], 1, 2,
		["Dithering", false, 3], 4, 5, 
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _spac = _data[1];
		var _quan = _data[2];
		var _dith = _data[3];
		var _dpat = _data[4];
		var _dcon = _data[5];
		
		surface_set_shader(_outSurf, sh_bit_reduce);
		    shader_set_dim("dimension", _surf);
		    shader_set_i("space",       _spac);
		    shader_set_3("quantize",    _quan);
		    shader_set_i("dithering",   _dith);
		    shader_set_f("ditherContrast", _dcon);
		    
			switch(_dpat) {
				case 0 :
					shader_set_f("ditherSize",	2);
					shader_set_f("dither",		dither2);
					break;
					
				case 1 :
					shader_set_f("ditherSize",	4);
					shader_set_f("dither",		dither4);
					break;
					
				case 2 :
					shader_set_f("ditherSize",	8);
					shader_set_f("dither",		dither8);
					break;
			}
			
		    draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf; 
	}
}