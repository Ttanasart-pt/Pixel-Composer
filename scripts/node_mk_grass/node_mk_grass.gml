function Node_MK_Grass(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Grass";
	
	newInput(1, nodeValueSeed());
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Source
	
	onSurfaceSize = function() /*=>*/ {return getDimension()};
	
	newInput(2, nodeValue_Enum_Scroll("Source", 0, [ "Area", "Mask", "Region", "Color Picker" ]));
	newInput(3, nodeValue_Area(       "Area",  DEF_AREA_REF, { onSurfaceSize })).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(4, nodeValue_Surface(    "Mask" ));
	newInput(5, nodeValue_Vec2(       "Picker", [ 0, 0 ] ));
	newInput(6, nodeValue_Slider(     "Picker Threshold", .1 ));
	
	////- =Shape
	
	shape_types = __enum_array_gen([ "Dense Bush", "V", "Hash" ], s_node_mk_grass_type, c_white);
	newInput( 7, nodeValue_Enum_Scroll( "Shape",   0, { data: shape_types, horizontal: 2, text_pad: ui(16) } ));
	newInput( 8, nodeValue_Range(       "Size",   [4,4], { linked: true }));
	newInput(17, nodeValue_Slider(      "Spread", .0));
	newInput(20, nodeValue_Float(       "Extra",  .0));
	
	////- =Scatter
	
	newInput( 9, nodeValue_Slider( "Density",     .5));
	newInput(10, nodeValue_Int(    "Level",        1));
	newInput(11, nodeValue_Slider( "Sharpness",   .5));
	newInput(14, nodeValue_Float(  "Noise Scale",  1));
	newInput(15, nodeValue_Int(    "Noise Detail", 1));
	
	////- =Render
	
	newInput(12, nodeValue_Enum_Scroll( "Render Type", 0, [ "Gradient", "Sample Multiply", "Sample Add" ]));
	newInput(13, nodeValue_Gradient(    "Colors",      new gradientObject([ca_black, ca_white])));
	newInput(16, nodeValue_Slider(      "Color Variance", 0));
	
	////- =Ground
	
	newInput(18, nodeValue_Bool(  "Fill Ground", false));
	newInput(19, nodeValue_Color( "Ground",      ca_black));
	
	// input 21
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		["Source",  false], 2, 3, 4, 5, 6, 
		["Shape",   false], 7, 8, 17, 20, 
		["Scatter", false], 9, 11, 14, 15,
		["Render",  false], 12, 13, 16, 
		["Ground",  false, 18], 19, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	temp_surface = [ 0, 0, 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _src = getSingleValue(2);
		
		switch(_src) {
			case 0 :
				InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				break;
			
			case 2 :
			case 3 :
				InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				break;
		}
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _seed     = _data[1];
		var _surf     = _data[0];
		
		var _src      = _data[2];
		var _area     = _data[3];
		var _mask     = _data[4];
		var _pick     = _data[5];
		var _pick_thr = _data[6];
		
		var _shape    = _data[ 7];
		var _size     = _data[ 8];
		var _spread   = _data[17];
		var _expand   = _data[20];
		
		var _dens     = _data[9];
		var _noi_lev  = _data[10];
		var _noi_shp  = _data[11];
		var _sizeSca  = _data[14];
		var _sizeItr  = _data[15];
		
		var _rtype    = _data[12];
		var _color    = _data[13];
		var _color_vr = _data[16];
		var _gnd_fil  = _data[18];
		var _gnd_clr  = _data[19];
		
		inputs[ 8].setVisible(_shape == 0 || _shape == 2);
		inputs[17].setVisible(_shape == 0);
		inputs[16].setVisible(_shape == 0);
		inputs[20].setVisible(_shape == 0);
		
		inputs[3].setVisible(_src == 0);
		inputs[4].setVisible(_src == 1, _src == 1);
		inputs[5].setVisible(_src == 2 || _src == 3);
		inputs[6].setVisible(_src == 2 || _src == 3);
		
		random_set_seed(_seed);
		
		var _dim = surface_get_dimension(_surf);
		var _gMaskIndex = 0;
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_rgba32float);
		
		switch(_src) {
			case 0 : 
				var x0 = _area[0] - _area[2];
				var y0 = _area[1] - _area[3];
				var x1 = _area[0] + _area[2];
				var y1 = _area[1] + _area[3];
				
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					draw_set_color(c_white);
					     if(_area[4] == AREA_SHAPE.rectangle) draw_rectangle( x0, y0, x1, y1, false );
					else if(_area[4] == AREA_SHAPE.elipse)    draw_ellipse(   x0, y0, x1, y1, false );
				surface_reset_target();
				
				_gMaskIndex = 0;
				break;
				
			case 1 : 
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					draw_surface_safe(_mask); 
				surface_reset_target();
				
				_gMaskIndex = 0;
				break;
			
			case 2 : 
			case 3 : 
				var _itr = _src == 2? max(_dim[0], _dim[1]) / 2 : 1;
				var _bg  = 0;
				
				var _baseColor = surface_getpixel_ext(_surf, _pick[0], _pick[1]);
				
				draw_set_color(c_white);
				surface_set_shader(temp_surface[0], noone); draw_point(_pick[0]-1, _pick[1]-1); surface_reset_shader();
				surface_set_shader(temp_surface[1], noone); draw_point(_pick[0]-1, _pick[1]-1); surface_reset_shader();
				
				repeat(_itr) {
					surface_set_shader(temp_surface[_bg], sh_mk_grass_floodfill);
						shader_set_surface("baseSurface", _surf);
						shader_set_2("dimension", _dim);
						shader_set_c("baseColor", _baseColor);
						shader_set_f("threshold", _pick_thr);
						shader_set_i("region",    _src == 2);
						
						draw_surface_safe(temp_surface[!_bg]);
					surface_reset_shader();
					_bg = !_bg;
				}
				
				_gMaskIndex = !_bg;
				break;
		}
		
		surface_set_shader(temp_surface[2], sh_mk_grass_noise);
			shader_set_f("seed",        _seed);
			shader_set_2("dimension",    _dim);
			
			shader_set_3("position",     [0, 0, _seed]);
			shader_set_f("rotation",     0);
			shader_set_2("scale",        [_sizeSca, _sizeSca]);
			shader_set_f("iteration",    _sizeItr);
			shader_set_f("phase",        0);
			shader_set_f("itrScaling",   2);
			shader_set_f("itrAmplitude",.5);
			
			shader_set_f("density",     _dens);
			shader_set_f("sharpness",   _noi_shp);
			
			draw_surface_safe(temp_surface[_gMaskIndex]);
		surface_reset_shader();
		
		// Grow
		
		switch(_shape) {
			case 0 : surface_set_shader(_outSurf, sh_mk_grass_grow);        break;
			case 1 : surface_set_shader(_outSurf, sh_mk_grass_grow_v);      break;
			case 2 : surface_set_shader(_outSurf, sh_mk_grass_grow_hash);   break;
			default: return _outSurf;
		}
		
		shader_set_surface("grassMask", temp_surface[2]);
		shader_set_f("seed",          _seed);
		shader_set_2("dimension",     _dim);
		shader_set_2("grassSize",     _size);
		shader_set_f("colorVariance", _color_vr);
		shader_set_f("density",       _dens);
		shader_set_f("expand",        _expand);
		
		shader_set_i("renderType",    _rtype);
		shader_set_i("groundFill",    _gnd_fil);
		shader_set_c("groundColor",   _gnd_clr);
		
		_color.shader_submit();
		
		draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}