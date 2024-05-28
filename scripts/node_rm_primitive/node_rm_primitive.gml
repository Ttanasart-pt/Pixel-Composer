function Node_RM_Primitive(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM Primitive";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	shape_types = [ 
		"Plane", "Box", "Box Frame",
		-1, 
		"Sphere", "Ellipse", "Cut Sphere", "Cut Hollow Sphere", "Torus", "Capped Torus",
		-1,
		"Cylinder", "Capsule", "Cone", "Capped Cone", "Round Cone", "3D Arc", 
		-1, 
		"Octahedron", "Pyramid", 
	];
	shape_types_str = [];
	
	var _ind = 0;
	for( var i = 0, n = array_length(shape_types); i < n; i++ ) {
		if(shape_types[i] == -1) 
			shape_types_str[i] = -1;
		else 
			shape_types_str[i] = new scrollItem(shape_types[i], s_node_shape_3d, _ind++, COLORS._main_icon_light);
	}
	
	inputs[| 1] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, shape_types_str);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 5] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 6] = nodeValue("View Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 3, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Depth", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Light Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -.5, -.5, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 9] = nodeValue("Ambient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 10] = nodeValue("Ambient Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 11] = nodeValue("Elongate", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 12] = nodeValue("Rounded", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 13] = nodeValue("Projection", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Perspective", "Orthographic" ])
		.setVisible(false, false);
	
	inputs[| 14] = nodeValue("Ortho Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 5.)
	
	inputs[| 15] = nodeValue("Wave Amplitude", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 16] = nodeValue("Wave Intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 17] = nodeValue("Wave Phase", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 18] = nodeValue("Twist Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y", "Z" ]);
	
	inputs[| 19] = nodeValue("Twist Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 8, 0.1 ] });
	
	inputs[| 20] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 21] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 22] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .7)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 23] = nodeValue("Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 24] = nodeValue("Crop", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 25] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30.)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 26] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 27] = nodeValue("Radius Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .7)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 28] = nodeValue("Uniform Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Primitive", false], 1, 21, 22, 23, 24, 25, 26, 27, 28, 
		["Modify",    false], 12, 11, 
		["Deform",     true], 15, 16, 17, 18, 19, 
		["Transform", false], 3, 4, 
		["Camera",    false], 13, 14, 5, 6, 
		["Render",    false], 7, 9, 10, 8, 20, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {
		var _shp = getSingleValue( 1);
		var _ort = getSingleValue(13);
		
		inputs[| 21].setVisible(false);
		inputs[| 22].setVisible(false);
		inputs[| 23].setVisible(false);
		inputs[| 24].setVisible(false);
		inputs[| 25].setVisible(false);
		inputs[| 26].setVisible(false);
		inputs[| 27].setVisible(false);
		inputs[| 28].setVisible(false);
		
		var _shape = shape_types[_shp];
		switch(_shape) { // Size
			case "Box" : 
			case "Box Frame" : 
			case "Ellipse" : 
				inputs[| 21].setVisible(true);
				break;
		}
		
		switch(_shape) { // Radius
			case "Sphere" : 
			case "Torus" : 
			case "Cut Sphere" : 
			case "Cut Hollow Sphere" : 
			case "Capped Torus" : 
			case "Cylinder" : 
			case "Capsule" : 
			case "3D Arc" : 
				inputs[| 22].setVisible(true);
				break;
		}
		
		switch(_shape) { // Thickness
			case "Box Frame" : 
			case "Torus" : 
			case "Cut Hollow Sphere" : 
			case "Capped Torus" : 
				inputs[| 23].setVisible(true);
				break;
		}
		
		switch(_shape) { // Crop
			case "Cut Sphere" : 
			case "Cut Hollow Sphere" : 
				inputs[| 24].setVisible(true);
				break;
		}
		
		switch(_shape) { // Angle
			case "Capped Torus" : 
			case "Cone" : 
			case "3D Arc" : 
				inputs[| 25].setVisible(true);
				break;
		}
		
		switch(_shape) { // Height
			case "Cylinder" : 
			case "Capsule" : 
			case "Cone" : 
			case "Capped Cone" : 
			case "Round Cone" : 
				inputs[| 26].setVisible(true);
				break;
		}
		
		switch(_shape) { // Radius Range
			case "Capped Cone" : 
			case "Round Cone" : 
				inputs[| 27].setVisible(true);
				break;
		}
		
		switch(_shape) { // Uniform Size
			case "Octahedron" : 
			case "Pyramid" : 
				inputs[| 28].setVisible(true);
				break;
		}
		
		inputs[|  5].setVisible(_ort == 0);
		inputs[| 14].setVisible(_ort == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
		var _dim  = _data[0];
		var _shp  = _data[1];
		
		var _pos  = _data[2];
		var _rot  = _data[3];
		var _sca  = _data[4];
		
		var _fov  = _data[5];
		var _rng  = _data[6];
		
		var _dpi  = _data[7];
		var _lPos = _data[8];
		var _amb  = _data[9];
		var _ambI = _data[10];
		var _elon = _data[11];
		var _rond = _data[12];
		
		var _ort  = _data[13];
		var _ortS = _data[14];
		
		var _wavA = _data[15];
		var _wavI = _data[16];
		var _wavS = _data[17];
		var _twsX = _data[18];
		var _twsA = _data[19];
		var _tile = _data[20];
		
		var _size = _data[21];
		var _rad  = _data[22];
		var _thk  = _data[23];
		var _crop = _data[24];
		var _angl = _data[25];
		var _heig = _data[26];
		var _radR = _data[27];
		var _sizz = _data[28];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, sh_rm_primitive);
			shader_set_i("shape",       _shp);
			shader_set_f("size",        _size);
			shader_set_f("radius",      _rad);
			shader_set_f("thickness",   _thk);
			shader_set_f("crop",        _crop);
			shader_set_f("angle",        degtorad(_angl));
			shader_set_f("height",      _heig);
			shader_set_f("radRange",    _radR);
			shader_set_f("sizeUni",     _sizz);
			shader_set_f("elongate",    _elon);
			shader_set_f("rounded",     _rond);
			
			shader_set_f("waveAmp",     _wavA);
			shader_set_f("waveInt",     _wavI);
			shader_set_f("waveShift",   _wavS);
			
			shader_set_i("twistAxis",   _twsX);
			shader_set_f("twistAmount", _twsA);
			
			shader_set_f("position",    _pos);
			shader_set_f("rotation",    _rot);
			shader_set_f("objectScale", _sca);
			
			shader_set_i("ortho",     _ort);
			shader_set_f("fov",       _fov);
			shader_set_f("orthoScale",_ortS);
			shader_set_f("viewRange", _rng);
			shader_set_f("depthInt",  _dpi);
			shader_set_f("tileSize",  _tile);
			
			shader_set_color("ambient",   _amb);
			shader_set_f("ambientIntns",  _ambI);
			shader_set_f("lightPosition", _lPos);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf; 
	}
} 