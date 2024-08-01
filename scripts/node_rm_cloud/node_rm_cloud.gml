function Node_RM_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM CLoud";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 4] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 5] = nodeValue("View Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Detail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 8] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Detail Scaling", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2.);
	
	inputs[| 10] = nodeValue("Detail Attenuation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 11] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Volume", "Plane" ]);
		
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Transform", false], 1, 2, 3, 
		["Camera",    false], 4, 5, 
		["Cloud",     false], 11, 6, 8, 
		["Noise",     false], 7, 9, 10, 
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
			
			shader_set_i("iteration",   _itrr);
			shader_set_f("detailScale", _dsca);
			shader_set_f("detailAtten", _datt);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
