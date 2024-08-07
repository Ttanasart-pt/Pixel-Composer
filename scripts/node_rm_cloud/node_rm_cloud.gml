function Node_RM_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM CLoud";
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	inputs[| 1] = nodeValue_Vector("Position", self, [ 0, 0, 0 ]);
	
	inputs[| 2] = nodeValue_Vector("Rotation", self, [ 0, 0, 0 ]);
	
	inputs[| 3] = nodeValue_Float("Scale", self, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 4] = nodeValue_Float("FOV", self, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 5] = nodeValue_Vector("View Range", self, [ 0, 6 ]);
	
	inputs[| 6] = nodeValue_Float("Density", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue_Int("Detail", self, 8);
	
	inputs[| 8] = nodeValue_Float("Threshold", self, 0.4)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue_Float("Detail Scaling", self, 2.);
	
	inputs[| 10] = nodeValue_Float("Detail Attenuation", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 11] = nodeValue_Enum_Scroll("Shape", self,  0, [ "Volume", "Plane" ]);
	
	inputs[| 12] = nodeValue_Bool("Use Fog", self, 0)
	
	inputs[| 13] = nodeValue_Gradient("Colors", self, new gradientObject([ cola(c_black), cola(c_white) ]))
	
	outputs[| 0] = nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone);
	
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
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
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
