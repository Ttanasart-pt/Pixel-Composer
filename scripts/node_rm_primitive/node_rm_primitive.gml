function Node_RM_Primitive(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM Primitive";
	batch_output = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	shape_types = [ 
		"Plane", "Box", "Box Frame", "Box Round", 
		-1, 
		"Sphere", "Ellipse", "Cut Sphere", "Cut Hollow Sphere", "Torus", "Capped Torus",
		-1,
		"Cylinder", "Prism", "Capsule", "Cone", "Capped Cone", "Round Cone", "3D Arc", 
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
	
	inputs[| 1] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_scroll, shape_types_str);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 30, 45, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 5] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 6] = nodeValue("View Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 3, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Depth", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Light Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ -.5, -.5, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 9] = nodeValue("Base Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 10] = nodeValue("Ambient Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
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
	
	inputs[| 27] = nodeValue("Radius Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ .7, .1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 28] = nodeValue("Uniform Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 29] = nodeValue("Tile Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 30] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 31] = nodeValue("Draw BG", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 32] = nodeValue("Volumetric", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 33] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 34] = nodeValue("Environment", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, false);
	
	inputs[| 35] = nodeValue("Reflective", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 36] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, false);
	
	inputs[| 37] = nodeValue("Triplanar Smoothing", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 10, 0.1 ] });
	
	inputs[| 38] = nodeValue("Texture Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.);
	
	inputs[| 39] = nodeValue("Corner", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.25, 0.25, 0.25, 0.25 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 40] = nodeValue("2D Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 41] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Shape Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, noone);
	
	input_display_list = [ 0,
		["Primitive",  false],  1, 21, 22, 23, 24, 25, 26, 27, 28, 39, 40, 41, 
		["Modify",     false], 12, 11, 
		["Deform",      true], 15, 16, 17, 18, 19, 
		["Transform",  false],  2,  3,  4, 
		["Material",   false],  9, 36, 35, 37, 38, 
		["Camera",     false], 13, 14,  5,  6, 
		["Render",     false], 31, 30, 34, 10,  7,  8, 
		["Tile",       false], 20, 29, 
		["Volumetric",  true, 32], 33, 
	];
	
	temp_surface = [ 0, 0 ];
	object = new RM_Shape();
	
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
		inputs[| 39].setVisible(false);
		inputs[| 40].setVisible(false);
		inputs[| 41].setVisible(false);
		
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
			case "Box Round" : 
			case "Torus" : 
			case "Cut Hollow Sphere" : 
			case "Capped Torus" : 
			case "Terrain" : 
			case "Extrude" : 
			case "Prism" : 
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
			case "Terrain" : 
			case "Extrude" : 
				inputs[| 28].setVisible(true);
				break;
		}
		
		switch(_shape) { // Corner
			case "Box Round" : 
				inputs[| 39].setVisible(true);
				break;
		}
		
		switch(_shape) { // Size 2D
			case "Box Round" : 
				inputs[| 40].setVisible(true);
				break;
		}
		
		switch(_shape) { // Sides
			case "Prism" : 
				inputs[| 41].setVisible(true);
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
		var _tilA = _data[29];
		var _bgc  = _data[30];
		var _bgd  = _data[31];
		
		var _vol  = _data[32];
		var _vden = _data[33];
		var bgEnv = _data[34];
		var _refl = _data[35];
		
		var _text = _data[36];
		var _triS = _data[37];
		var _texs = _data[38];
		var _corn = _data[39];
		var _sz2d = _data[40];
		var _side = _data[41];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			draw_surface_stretched_safe(bgEnv, tx * 0, tx * 0, tx, tx);
		surface_reset_shader();
		
		var _shape = shape_types[_shp];
		var _shpI  = 0;
		
		switch(_shape) {
			case "Plane" :				_shpI = 100;												break;
			case "Box" :				_shpI = 101;												break;
			case "Box Frame" :      	_shpI = 102;												break;
			case "Box Round" :      	_shpI = 103;												break;
								
			case "Sphere" :         	_shpI = 200;												break;
			case "Ellipse" :        	_shpI = 201;												break;
			case "Cut Sphere" :     	_shpI = 202;												break;
			case "Cut Hollow Sphere" :	_shpI = 203; _crop = _crop / pi * 2.15;						break;
			case "Torus" :          	_shpI = 204;												break;
			case "Capped Torus" :   	_shpI = 205;												break;
			
			case "Cylinder" :       	_shpI = 300;												break;
			case "Capsule" :        	_shpI = 301;												break;
			case "Cone" :           	_shpI = 302;												break;
			case "Capped Cone" :    	_shpI = 303;												break;
			case "Round Cone" :     	_shpI = 304;												break;
			case "3D Arc" :         	_shpI = 305;												break;
			case "Prism" :         		_shpI = 306;												break;
			
			case "Octahedron" :     	_shpI = 400;												break;
			case "Pyramid" :        	_shpI = 401;												break;
		}
		
		object.operations    = -1;
		object.shapeAmount   =  1;
		
		object.shape         = _shpI;
		object.size          = _size;
		object.radius        = _rad ;
		object.thickness     = _thk ;
		object.crop          = _crop;
		object.angle         = degtorad(_angl);
		object.height        = _heig;
		object.radRange      = _radR;
		object.sizeUni       = _sizz;
		object.elongate      = _elon;
		object.rounded       = _rond;
		object.corner        = _corn;
		object.size2D        = _sz2d;
		object.sides         = _side;
		
		object.waveAmp       = _wavA;
		object.waveInt       = _wavI;
		object.waveShift     = _wavS;
		
		object.twistAxis     = _twsX;
		object.twistAmount   = _twsA;
		
		object.position      = _pos;
		object.rotation      = _rot;
		object.objectScale   = _sca;
		
		object.tileSize      = _tile;
		object.tileAmount    = _tilA;
		
		object.diffuseColor  = colorToArray(_amb, true);
		object.reflective    = _refl;
		    
		object.volumetric    = _vol;
		object.volumeDensity = _vden;
		    
		object.texture       = [ _text ];
		object.useTexture    = is_surface(_text);
		object.textureScale  = _texs;
		object.triplanar     = _triS;
			
		object.setTexture(temp_surface[1]);
		
		gpu_set_texfilter(true);
		surface_set_shader(_outSurf, sh_rm_primitive);
			
			shader_set_surface($"texture0", temp_surface[0]);
			
			shader_set_i("ortho",       _ort);
			shader_set_f("fov",         _fov);
			shader_set_f("orthoScale",  _ortS);
			shader_set_f("viewRange",   _rng);
			shader_set_f("depthInt",    _dpi);
			
			shader_set_i("drawBg",  	   _bgd);
			shader_set_color("background", _bgc);
			shader_set_f("ambientIntns",   _ambI);
			shader_set_f("lightPosition",  _lPos);
			
			shader_set_i("useEnv",      is_surface(bgEnv));
			
			object.apply();
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		gpu_set_texfilter(false);
		
		return [ _outSurf, object ]; 
	}
} 
