function Node_RM_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM CLoud";
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValue_Vec3("Position", [ 0, 0, 0 ]));
	
	newInput(2, nodeValue_Vec3("Rotation", [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Slider("Scale", 1, [ 0, 4, 0.01 ] ));
	
	newInput(4, nodeValue_Slider("FOV", 30, [ 0, 90, 1 ] ));
	
	newInput(5, nodeValue_Vec2("View Range", [ 0, 6 ]));
	
	newInput(6, nodeValue_Slider("Density", 0.5));
	
	newInput(7, nodeValue_Int("Detail", 8));
	
	newInput(8, nodeValue_Slider("Threshold", 0.4));
	
	newInput(9, nodeValue_Float("Detail Scaling", 2.));
	
	newInput(10, nodeValue_Slider("Detail Attenuation", 0.5));
	
	newInput(11, nodeValue_Enum_Scroll("Shape",  0, [ "Volume", "Plane" ]));
	
	newInput(12, nodeValue_Bool("Use Fog", 0))
	
	newInput(13, nodeValue_Gradient("Colors", new gradientObject([ ca_black, ca_white ])))
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		["Transform", false],  1,  2,  3, 
		["Camera",    false],  4,  5, 
		["Cloud",     false], 11,  6,  8, 
		["Noise",     false],  7,  9, 10, 
		["Render",    false], 13, 12, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		var _dim  = _data[0];
		
		var _pos  = _data[1];
		var _rot  = _data[2];
		var _sca  = _data[3];
		
		var _fov  = _data[4];
		var _rng  = _data[5];
		
		var _type = _data[11];
		var _dens = _data[ 6];
		var _thrs = _data[ 8];
		
		var _itrr = _data[ 7];
		var _dsca = _data[ 9];
		var _datt = _data[10];
		var _fogu = _data[12];
		var _colr = _data[13];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, sh_rm_cloud);
		
			shader_set_2("dimension",   _dim);
			shader_set_3("position",    _pos);
			shader_set_3("rotation",    _rot);
			shader_set_f("objectScale", _sca * 4);
			
			shader_set_f("fov",         _fov);
			shader_set_2("viewRange",   _rng);
			
			shader_set_i("type",        _type);
			shader_set_f("density",     _dens);
			shader_set_f("threshold",   _thrs);
			
			shader_set_i("fogUse",      _fogu);
			shader_set_i("iteration",   _itrr);
			shader_set_f("detailScale", _dsca);
			shader_set_f("detailAtten", _datt);
			
			_colr.shader_submit();
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
