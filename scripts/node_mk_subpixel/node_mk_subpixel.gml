function Node_MK_Subpixel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Subpixel";
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValue_Enum_Scroll("Type", 0, [ "Hex Disc", "Strip", "Linear Block", "Linear Block offset", "Chevron", "Square", "Square Non-Uniform" ]));
	
	newInput(2, nodeValue_Int("Density", 8));
	
	newInput(3, nodeValue_Float("Size", .6))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Float("Blur", .1))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Float("Noise", .1))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newInput(6, nodeValue_Float("Intensity", 1))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Surface("Surface"));
	
	newInput(8, nodeValueSeed(self));
	
	newInput(9, nodeValue_Float("Ridge amount", 8));
	
	newInput(10, nodeValue_Float("Ridge Intensity", 1))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Bool("Ridge", false));
	
	newInput(12, nodeValue_Float("Scene Scale", 1));
	
	newInput(13, nodeValue_Bool("Flicker", false));
	
	newInput(14, nodeValue_Float("Flicker Intensity", .2))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(15, nodeValue_Float("Flicker Frequency", 4))
	
	newInput(16, nodeValue_Float("Flicker Cut", .5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 7, 
		["Subpixel", false],      1,  2, 12, 
		["Effect",   false],      3,  4,  8, 
		["Ridge",    false, 11],  9, 10, 
		["Render",   false],      6,  5, 
		["Flicker",  false, 13], 14, 15, 16, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	static processData = function(_outSurf, _data, _array_index) {
		var _type = _data[1];
		var _scal = _data[2];
		var _size = _data[3];
		var _blur = _data[4];
		var _nise = _data[5];
		var _ints = _data[6];
		var _surf = _data[7];
		var _seed = _data[8];
		var _rgcn = _data[9];
		var _rgin = _data[10];
		var _ruse = _data[11];
		var _scns = _data[12];
		var _flku = _data[13];
		var _flki = _data[14];
		var _flkf = _data[15];
		var _flkc = _data[16];
		
		update_on_frame = _flku;
		
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim = surface_get_dimension(_surf);
		var sh   = sh_mk_subpixel_hex_disc;
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		switch(_type) {
    	    case 0 : sh = sh_mk_subpixel_hex_disc;				break;
    	    case 1 : sh = sh_mk_subpixel_linear;				break;
    	    case 2 : sh = sh_mk_subpixel_linear_block;  		break;
    	    case 3 : sh = sh_mk_subpixel_linear_block_offset;  	break;
    	    case 4 : sh = sh_mk_subpixel_chevron;  				break;
    	    case 5 : sh = sh_mk_subpixel_square;  				break;
    	    case 6 : sh = sh_mk_subpixel_square_non;			break;
    	    case 7 : sh = sh_mk_subpixel_diagonal;				break;
    	}
		
		surface_set_shader(_outSurf, sh);
			shader_set_surface("texture", _surf);
			shader_set_f("dimension",     _dim);
			shader_set_f("seed",          _seed / 10000);
			shader_set_f("scale",         _scal);
			shader_set_f("size",          _size);
			shader_set_f("blur",          _blur);
			shader_set_f("noise",         _nise);
			shader_set_f("intensity",     _ints);
			
			shader_set_i("ridgeUse",      _ruse);
			shader_set_f("ridgeCount",    _rgcn);
			shader_set_f("ridgeIntens",   _rgin);
			
			shader_set_i("flickerUse",      _flku);
			shader_set_f("flickerIntens",   _flki);
			shader_set_f("flickerCut",      _flkc);
			shader_set_f("flickerTime",     (CURRENT_FRAME / TOTAL_FRAMES) * pi * _flkf);
			
			var _cx = _dim[0] / 2;
			var _cy = _dim[1] / 2;
			var _px = _cx - _dim[0] * _scns / 2;
			var _py = _cy - _dim[1] * _scns / 2;
			
			draw_surface_ext(_surf, _px, _py, _scns, _scns, 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}
