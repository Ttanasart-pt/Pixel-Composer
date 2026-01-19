function Node_Combine_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Combine";
	
	////- =Surfaces
	newInput(6, nodeValue_EButton( "Color Space",  0, [ "HSV", "HSL" ] ));
	newInput(4, nodeValue_Bool(    "Array Input", false));
	newInput(0, nodeValue_Surface( "Hue"           ));
	newInput(1, nodeValue_Surface( "Saturation"    ));
	newInput(2, nodeValue_Surface( "Value"         ));
	newInput(3, nodeValue_Surface( "Alpha"         ));
	newInput(5, nodeValue_Surface( "HSV Array", [] )).setArrayDepth(1);
	// 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 
		[ "Surfaces", false ], 4, 0, 1, 2, 3, 5, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _arr  = _data[4];
			var _spac = _data[6];
			
			inputs[0].setVisible(!_arr, !_arr);
			inputs[1].setVisible(!_arr, !_arr);
			inputs[2].setVisible(!_arr, !_arr);
			inputs[3].setVisible(!_arr, !_arr);
			
			inputs[5].setVisible(_arr, _arr);
		#endregion
		
		var _h = _arr? array_safe_get_fast(_data[5], 0) : _data[0];
		var _s = _arr? array_safe_get_fast(_data[5], 1) : _data[1];
		var _v = _arr? array_safe_get_fast(_data[5], 2) : _data[2];
		var _a = _arr? array_safe_get_fast(_data[5], 3) : _data[3];
		
		var _baseS = is_surface(_h)? _h : (is_surface(_s)? _s : _v);
		if(!is_surface(_baseS)) return _outSurf;
		
		var _ww = surface_get_width_safe(_baseS);
		var _hh = surface_get_height_safe(_baseS);
		
		_outSurf = surface_verify(_outSurf, _ww, _hh);
		
		surface_set_shader(_outSurf, sh_combine_hsv);
			shader_set_i("space", _spac);
			
			shader_set_surface("samH", _h);
			shader_set_surface("samS", _s);
			shader_set_surface("samV", _v);
			shader_set_surface("samA", _a);
			
			shader_set_i("useH", is_surface(_h));
			shader_set_i("useS", is_surface(_s));
			shader_set_i("useV", is_surface(_v));
			shader_set_i("useA", is_surface(_a));
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _ww, _hh);
		surface_reset_shader();
		
		return _outSurf;
	}
}