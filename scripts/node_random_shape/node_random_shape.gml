function Node_Random_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Random Shape";
	
	newInput(1, nodeValueSeed(VALUE_TYPE.integer));
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 3, nodeValue_Surface( "UV Map"     ));
	newInput( 4, nodeValue_Slider(  "UV Mix", 1  ));
	
	////- =Shape
	newInput( 7, nodeValue_Text(  "Types",   "ret"   )).setDisplay(VALUE_DISPLAY.text_box)
		.setTooltip(@"Pool of all shapes to randomly select from:
- r : Rounded Rectangle
- e : Ellipse
- t : Triangle");

	newInput( 5, nodeValue_Float( "Amount", [1,1,2,2,3,3,3] )).setDisplay(VALUE_DISPLAY.number_array);
	newInput( 6, nodeValue_Range( "Size",   [.25,.5] ));
	newInput( 8, nodeValue_Range( "Shift",  [0,1]    ));
	newInput( 9, nodeValue_Text(  "Mirror", "b"      )).setDisplay(VALUE_DISPLAY.text_box)
		.setTooltip(@"Pool of all mirror type to randomly select from:
- - : None
- h : Horizontal
- v : Vertical
- b : Both");
	
	////- =Cut
	newInput(11, nodeValue_Slider( "Chance", .5    ));
	newInput(12, nodeValue_Slider( "Size",   .6    ));
	newInput(13, nodeValue_Range(  "Shift",  [0,1] ));
	newInput(14, nodeValue_Slider( "Polar",  .5    ));
	newInput(15, nodeValue_Text(   "Mirror", "b"   )).setDisplay(VALUE_DISPLAY.text_box)
		.setTooltip(@"Pool of all mirror type to randomly select from:
- - : None
- h : Horizontal
- v : Vertical
- b : Both");

	////- =Render
	newInput(10, nodeValue_Float(   "Corner", [0,0,1,1,1] )).setDisplay(VALUE_DISPLAY.number_array);
	newInput( 2, nodeValue_EScroll( "SSAA",    0, [ "None", "2x", "4x", "8x" ] ));
	// inputs 15
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 1, 
		[ "Output",  true ],  0,  3,  4, 
		[ "Shape",  false ],  7,  5,  6,  8,  9, 
		[ "Cut",    false ], 11, 12, 13, 14, 15, 
		[ "Render", false ], 10,  2,
	];
	
	////- Node
	
	temp_surface = [ noone, noone ];
	aa = 1;
	
	function generateShape(_data, _dim) {
		#region data
			var type = _data[7];
			var amou = _data[5];
			var size = _data[6];
			var offs = _data[8];
			var mirr = _data[9];
		#endregion
		
		var _sw = _dim[0] * aa;
		var _sh = _dim[1] * aa;
		temp_surface[1] = surface_verify(temp_surface[1], _sw, _sh);
		
		var _shap = temp_surface[1];
		var _amou = amou[irandom(array_length(amou) - 1)];
		var _side = min(_dim[0], _dim[1]);
		
		surface_set_target(_shap);
			DRAW_CLEAR
			draw_set_color(c_white);
			
			repeat(_amou) {
				var _size  = ceil(_side * random_range(size[0], size[1]));
				if(_size < 1) continue;
				
				var _shape = surface_create_valid(_size * aa, _size * aa);
				var _x1 = _size * aa;
				var _y1 = _size * aa;
				var _tt = string_char_at(type, irandom_range(1, string_length(type)));
				
				surface_set_target(_shape);
					DRAW_CLEAR
					draw_set_color(c_white);
					
					switch(_tt) {
						case "r" : 
							var _r  = irandom(4) * 2 * aa;
					        draw_roundrect_ext(0, 0, _x1, _y1, _r, _r, false);  
					        break;
					         
						case "e" : draw_ellipse(0, 0, _x1, _y1, false);                break;
						case "t" : draw_triangle(_x1 / 2, 0, 0, _y1, _x1, _y1, false); break;
					}
				surface_reset_target();
				
				var _sx = _dim[0] / 2 - _size * random_range(offs[0], offs[1]) * aa;
				var _sy = _dim[1] / 2 - _size * random_range(offs[0], offs[1]) * aa;
				draw_surface_safe(_shape, _sx, _sy);
				surface_free(_shape);
			}
		surface_reset_target();
		
		var _surf = surface_create_valid(_sw, _sh);
		var _mirr = string_char_at(mirr, irandom_range(1, string_length(mirr)));
		
		surface_set_target(_surf);
			DRAW_CLEAR
			draw_surface_ext_safe(_shap);
			
			if(_mirr == "h" || _mirr == "b") draw_surface_ext_safe(_shap, _sw,   0, -1,  1);
			if(_mirr == "v" || _mirr == "b") draw_surface_ext_safe(_shap,   0, _sh,  1, -1);
			if(_mirr == "b")                 draw_surface_ext_safe(_shap, _sw, _sh, -1, -1);
		surface_reset_target();
		
		return _surf;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed = _data[ 1];
			var _dim  = _data[ 0];
			var _aa   = _data[ 2];
			
			var _cutc = _data[11];
			var _cuts = _data[12];
			var _cuto = _data[13];
			var _ctcr = _data[14];
			var _cmir = _data[15];
			
			var _corn = _data[10];
			var _aa   = _data[ 2]; aa = power(2, _aa);
		#endregion
		
		random_set_seed(_seed);
		
		var _adim = [ _dim[0] * aa, _dim[1] * aa ];
		var _prog = generateShape(_data, _dim);
		
		if(random(1) < _cutc) {
			var _cutt = surface_create_valid(_adim[0], _adim[1]);
			
			var _size = [ _dim[0] * _cuts, _dim[1] * _cuts ];
			var _subs = generateShape(_data, _size);
			var _sx   = _adim[0] / 2;
			var _sy   = _adim[1] / 2;
				
			var _side = irandom(2);
			switch(_side) {
				case 0 : _sx = round(_dim[0] / 2 - _size[0] * random_range(_cuto[0], _cuto[1])) * aa; break;
				case 1 : _sy = round(_dim[1] / 2 - _size[1] * random_range(_cuto[0], _cuto[1])) * aa; break;
			}
			
			surface_set_target(_cutt);
				DRAW_CLEAR
				if(random(1) < _ctcr) {
					shader_set(sh_rsh_rotate);
					shader_set_f("dimension", _adim[0], _adim[1]);
					draw_surface_safe(_prog);
					shader_reset();
					
				} else
					draw_surface_safe(_prog);
					
				var _mirr = string_char_at(_cmir, irandom_range(1, string_length(_cmir)));
				
				BLEND_SUBTRACT
					draw_surface_ext_safe(_subs, _sx, _sy);
					
					if(_mirr == "h" || _mirr == "b") draw_surface_ext_safe(_subs, _dim[0] - _sx,           _sy, -1,  1);
					if(_mirr == "v" || _mirr == "b") draw_surface_ext_safe(_subs,           _sx, _dim[1] - _sy,  1, -1);
					if(_mirr == "b")                 draw_surface_ext_safe(_subs, _dim[0] - _sx, _dim[1] - _sy, -1, -1);
				BLEND_NORMAL
			surface_reset_target();
			
			surface_free(_subs);
			surface_free(_prog);
			
			_prog = _cutt;
		}
		
		temp_surface[0] = surface_verify(temp_surface[0], _adim[0], _adim[1]);
		
		surface_set_shader(temp_surface[0], sh_rsh_corner, true, BLEND.add);
			shader_set_2( "dimension", _adim );
			shader_set_i( "type",      _corn[irandom(array_length(_corn) - 1)] );
			
			draw_surface_safe(_prog);
		surface_reset_shader();
		surface_free(_prog);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_shader(_outSurf, sh_downsample, true, BLEND.over);
			shader_set_uv(_data[3], _data[4]);
			
			shader_set_2( "dimension", _adim );
			shader_set_f( "down",       aa   );
			
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}
