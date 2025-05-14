function Node_Blur_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path Blur";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	newInput(1, nodeValue_PathNode("Blur Path", self, noone))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Int("Resolution", self, 32));
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8
	
	newInput(9, nodeValue_Float("Intensity", self, 1));
	
	newInput(10, nodeValue_Curve("Intensity Along Path", self, CURVE_DEF_11));
	
	newInput(11, nodeValue_Slider_Range("Range", self, [ 0, 1 ]));
	
	newInput(12, nodeValue_Float("Path Origin", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Path",	false],	1, 12, 11, 
		["Blur",	false],	2, 9, 10, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static getTool = function() { 
		var _path = getInputData(1);
		return is_instanceof(_path, Node)? _path : self; 
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		if(!is_surface(_data[0])) return _outSurf;
		
		var _samp = getAttribute("oversample");
		var _surf = _data[0];
		var _path = _data[1];
		var _reso = _data[2];
		var _intn = _data[9];
		var _curv = _data[10];
		var _rang = _data[11];
		var _orig = _data[12];
		
		var _pntc = clamp(_reso, 2, 128);
		if(!is_struct(_path)) return _outSurf;
		
		var _dim = surface_get_dimension(_surf)
		var _points_x = array_create(_pntc);
		var _points_y = array_create(_pntc);
		var _p = new __vec2P();
		
		var _rst = _rang[0];
		var _red = _rang[1];
		var _rrr = _red - _rst;
		
		var ox = 0, oy = 0;
		_p = _path.getPointRatio(_orig, 0, _p);
		ox = _p.x;
		oy = _p.y;
		
		for(var i = 0; i < _pntc; i++) {
			var _pg = clamp(_rst + _rrr * i / (_pntc - 1), 0., 0.99);
			_p = _path.getPointRatio(_pg, 0, _p);
			
			_points_x[i] = (_p.x - ox) / _dim[0];
			_points_y[i] = (_p.y - oy) / _dim[1];
		}
		
		surface_set_shader(_outSurf, sh_blur_path);
			shader_set_f("dimension",  _dim);
			shader_set_i("sampleMode", _samp);
			
			shader_set_i("resolution",  _pntc);
			shader_set_i("pointAmount", _pntc);
			shader_set_f("points_x",    _points_x);
			shader_set_f("points_y",    _points_y);
			
			shader_set_f("intensity", _intn);
			shader_set_curve("i",     _curv);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}