function Node_Pixel_Sampler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Sampler";
	
	////- =Texture
	newInput(0, nodeValue_Surface(     "Base Texture" ));
	newInput(1, nodeValue_Enum_Button( "Sample Mode",  0, [ "Keep Size", "Expand" ] ));
	newInput(2, nodeValue_Enum_Button( "Match Mode",   0, [ "Brightness", "RGB", "Hue" ] ));
	
	////- =Surface
	newInput(3, nodeValue_Surface(  "Surfaces", [])).setArrayDepth(1);
	newInput(4, nodeValue_Gradient( "Gradient", gra_black_white)).setMappable(5);
	
	////- =Render
	newInput(7, nodeValue_Enum_Scroll( "Color Blending",     0, [ "None", "Multiply" ]));
	newInput(8, nodeValue_Slider(      "Blending Intensity", 1 ));
	
	// input 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Base Texture", false], 0, 1, 2, 
		["Surface",		 false], 3, //4, 5, 
		["Render",		 false], 7, 8, 
	];
	
	attribute_surface_depth();
		
	temp_surface = [ noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var _base = _data[0];
		var _samp = _data[1];
		var _mach = _data[2];
		
		var _surf = _data[3];
		var _colr = _data[4];
		
		var _blnd = _data[7];
		var _bint = _data[8];
		
		if(!is_array(_surf)) _surf = [_surf];
		var _inps = array_length(_surf);
		
		if(!is_surface(_base)) return _outSurf;
		if(_inps == 0)         return _outSurf;
		
		var _dim  = surface_get_dimension(_base);
		var _tdim = [ 1, 1 ];
		
		for (var i = 0, n = array_length(_surf); i < n; i++) {
			var _d = surface_get_dimension(_surf[i]);
			_tdim[0] = max(_tdim[0], _d[0]);
			_tdim[1] = max(_tdim[1], _d[1]);
		}
		
		temp_surface[0] = surface_verify(temp_surface[0], 8192, 8192);
		
		var _tcol = floor(8192 / _tdim[0]);
		
		surface_set_shader(temp_surface[0], noone);
			for(var i = 0; i < _inps; i++) {
				var _tex_s = _surf[i];
				var _col   = i % _tcol;
				var _row   = floor(i / _tcol);
				
				var _tx = _col * _tdim[0];
				var _ty = _row * _tdim[1];
				
				draw_surface_safe(_tex_s, _tx, _ty);
			}
		surface_reset_shader();
		
		var _ww = _dim[0];
		var _hh = _dim[1];
		
		switch(_samp) {
			case 0 : 
				_ww = _dim[0];
				_hh = _dim[1];
				break;
			
			case 1 : 
				_ww = _dim[0] * _tdim[0];
				_hh = _dim[1] * _tdim[1];
				break;
		}
		
		_outSurf = surface_verify(_outSurf, _ww, _hh);
		
		surface_set_shader(_outSurf, sh_pixel_sample);
			shader_set_f("dimension",        [ _ww, _hh ]);
			shader_set_f("samplerDimension", _tdim);
			shader_set_f("samplerColumn",    _tcol);
			
			shader_set_surface("samplers", temp_surface[0]);
			shader_set_i("amount",         _inps);
			shader_set_i("sampleMode",     _samp);
			shader_set_i("matchMode",      _mach);
			shader_set_gradient(_data[4], _data[5], _data[6], inputs[4]);
			
			shader_set_i("blendMode",      _blnd);
			shader_set_f("blendIntensity", _bint);
			
			draw_surface_stretched(_base, 0, 0, _ww, _hh);
		surface_reset_shader();
		
		return _outSurf;
	}
}