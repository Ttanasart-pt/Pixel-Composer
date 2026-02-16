function Node_Blur_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path Blur";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(13, nodeValue_Surface( "UV Map"     ));
	newInput(14, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Path
	newInput( 1, nodeValue_PathNode(     "Blur Path"       ));
	newInput(12, nodeValue_Slider(       "Path Origin", 0  ));
	newInput(11, nodeValue_Slider_Range( "Range", [ 0, 1 ] ));
	
	////- =Blur
	newInput( 2, nodeValue_Int(   "Resolution",   32 ));
	newInput( 9, nodeValue_Float( "Intensity",    1  )).setCurvable(10, CURVE_DEF_11);
	// input 15
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],	0, 13, 14, 3, 4, 7, 8, 
		["Path",	false],	1, 12, 11, 
		["Blur",	false],	2, 9, 10, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		if(!is_surface(_data[0])) return _outSurf;
		
		var _surf = _data[ 0];
		var _path = _data[ 1];
		var _reso = _data[ 2];
		var _intn = _data[ 9];
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
			shader_set_uv(_data[13], _data[14]);
			shader_set_i("sampleMode", getAttribute("oversample"));
			shader_set_f("dimension",  _dim);
			
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