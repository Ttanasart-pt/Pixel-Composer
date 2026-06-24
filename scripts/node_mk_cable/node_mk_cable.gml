function Node_MK_Cable(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Cables";
	dimension_index = 19;
	
	newInput( 3, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Surface( "BG Surface" ));
	newInput(19, nodeValue_Dimension());
	
	////- =Anchors
	newInput(15, nodeValue_EScroll( "Type", 0, [ "Fix Points", "Fix Point Array", "Path Anchor", "Path Sample", "Areas" ] ));
	
	newInput( 1, nodeValue_Vec2(  "Point 1",    [0,.5] )).setUnitSimple();
	newInput( 2, nodeValue_Vec2(  "Point 2",    [1,.5] )).setUnitSimple();
	newInput( 9, nodeValue_Float( "Radius 1",    0     ));
	newInput(10, nodeValue_Float( "Radius 2",    0     ));
	newInput(16, nodeValue_Vec2(  "Points",      []    )).setArrayDepth(1);
	newInput(17, nodeValue_Path(  "Path",        noone ));
	newInput(18, nodeValue_Int(   "Path Points", 8     ));
	newInput(22, nodeValue_Area(  "Area 1",      [.25,.5,.25,.25,0,0], false )).setUnitSimple();
	newInput(23, nodeValue_Area(  "Area 2",      [.75,.5,.25,.25,0,0], false )).setUnitSimple();
	
	////- =Cable
	newInput( 5, nodeValue_Int(      "Amount",    1          ));
	newInput(14, nodeValue_Rotation( "Gravity",  -90         ));
	newInput( 4, nodeValue_Range(    "Tension",  [1,1], true ));
	newInput( 8, nodeValue_Int(      "Segments",  16         ));
	
	////- =Swing
	newInput(11, nodeValue_Bool(     "Swing",     false         ));
	newInput(12, nodeValue_Range(    "Amplitude", [.5,.5], true ));
	newInput(13, nodeValue_Range(    "Frequency", [1,1],   true ));
	
		////- =/End Swing
	newInput(24, nodeValue_Bool(     "End Swing", false ));
	newInput(27, nodeValue_Float(    "Strength",  1     ));
	newInput(25, nodeValue_Int(      "Speed",     1     ));
	newInput(26, nodeValue_Slider(   "Ratio",    .5     ));
	
	////- =Render
	newInput( 6, nodeValue_Range(    "Thickness", [1,1], true )).setCurvable(20, CURVE_DEF_11, "Over Cable");
	newInput( 7, nodeValue_Gradient( "Colors",    gra_white   )).setGradable(21, gra_white,    "Over Cable");
	
		////- =/Texture
	newInput(28, nodeValue_Surface(  "Texture"                ));
	newInput(29, nodeValue_Vec2(     "UV Position", [0,0]     ));
	newInput(30, nodeValue_Vec2(     "UV Scale",    [1,1]     ));
	// input 29
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ s_MKFX, 3, 
		[ "Output",         false     ],  0, 19, 
		[ "Anchors",        false     ], 15,  1,  2,  9, 10, 16, 17, 18, 22, 23, 
		[ "Cable",          false     ],  5, 14,  4,  8, 
		[ "Swing",          false, 11 ], 12, 13, 
			[ "/End Swing", false, 24 ], 27, 25, 26, 
		[ "Render",         false     ],  6, 20,  7, 21, 
			[ "/Texture",   false     ], 28, 29, 30, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation(false, true);
	attribute_oversample();
	
	swing_precal = [];
	thick_curve  = new curveMap();
	
	gravx = 0; gravsx = 0;
	gravy = 0; gravsy = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _type = getInputSingle(15);
		
		switch(_type) {
			case 0 : 
				var _pos1 = getInputSingle( 1);
				var _pos2 = getInputSingle( 2);
				
				var _rad1 = getInputSingle( 9);
				var _rad2 = getInputSingle(10);
				
				var _p1x = _x + _pos1[0]*_s;
				var _p1y = _y + _pos1[1]*_s;
				
				var _p2x = _x + _pos2[0]*_s;
				var _p2y = _y + _pos2[1]*_s;
				
				draw_set_color(COLORS._main_accent);
				draw_circle_dash(_p1x, _p1y, _rad1*_s);
				draw_circle_dash(_p2x, _p2y, _rad2*_s);
				
				drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				
				if(_rad1) drawOverlayInput(inputs[ 9].drawOverlay(w_hoverable, active, _p1x, _p1y, _s, _mx, _my, 0, 1, 1));
				if(_rad2) drawOverlayInput(inputs[10].drawOverlay(w_hoverable, active, _p2x, _p2y, _s, _mx, _my, 0, 1, 1));
				break;
			
			case 4 : 
				drawOverlayInput(inputs[22].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[23].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				break;
		}
		
		return w_hovering;
	}
	
	function drawCable(_data, c, x0, y0, x1, y1, _ten, _segs, _thk) {
	    #region data
		    var _grav     = _data[14];
		    
		    var _swng     = _data[11];
			var _swng_amp = _data[12];
			var _swng_frq = _data[13];
			
			var _eswg     = _data[24];
			var _eswg_str = _data[27];
			var _eswg_spd = _data[25];
			var _eswg_rat = _data[26];
			
			var _colrMap  = _data[21]; 
			var _linTex   = _data[28]; 
			
			var _thk_curved = inputs[6].attributes.curved;
			var _col_graded = inputs[7].attributes.graded;
		#endregion
	    
	    #region end Swing
	    if(_eswg) {
	    	var len  = point_distance( x0, y0, x1, y1);
	    	var dir  = point_direction(x0, y0, x1, y1);
	    	
	    	var nx1 = x0 + lengthdir_x(len, dir - _grav);
	    	var ny1 = y0 + lengthdir_y(len, dir - _grav);
	    	
			var cx  = nx1;
			var cy  = y0;
			var rd  = abs(ny1 - cy);
			
			var pha = random(1);
			var rot = (pha + CURRENT_FRAME / TOTAL_FRAMES) * _eswg_spd * 360;
			
			var dx = lengthdir_x(rd, rot) * _eswg_str * _eswg_rat;
			var dy = lengthdir_y(rd, rot) * _eswg_str;
			
			nx1 = cx + dx;
			ny1 = cy + dy;
			
			var len  = point_distance( x0, y0, nx1, ny1);
	    	var dir  = point_direction(x0, y0, nx1, ny1);
	    	
	    	x1 = x0 + lengthdir_x(len, dir + _grav);
	    	y1 = y0 + lengthdir_y(len, dir + _grav);
	    }
		#endregion
		
		var len  = point_distance( x0, y0, x1, y1);
		var dir  = point_direction(x0, y0, x1, y1);
	    var aa   = _ten * len / 2;
	    var ox, oy, ot, oc, oa, ol, ott;
	    var nx, ny, nt, nc, na, nl, ntt;
		var cc = draw_get_color();
		
	    var _samp = random_range(_swng_amp[0], _swng_amp[1]) * .1;
    	var _sfrq = round(random_range(_swng_frq[0], _swng_frq[1]));
	    
	    if(is_surface(_linTex))
			 draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_linTex));
		else draw_primitive_begin(pr_trianglelist);
		
		var _total_len = 0;
		ol = 0;
		
	    var _isg = 1 / _segs;
	    for (var i = 0; i <= _segs; i++) {
	        var t = i * _isg;
	        var _drop = aa * sin(t * pi);
	        
	        ntt = t;
	        
	        nx = lerp(x0, x1, t) + _drop * gravx;
	        ny = lerp(y0, y1, t) + _drop * gravy;
	        nt = max(1, _thk * (_thk_curved? thick_curve.get(t) : 1));
	        nc = _col_graded? colorMultiply(cc, _colrMap.evalFast(t)) : cc;
	        
	        if(_swng) {
	        	var _phs   = swing_precal[c] + (CURRENT_FRAME / TOTAL_FRAMES) * _sfrq;
	        	var _swamo = cos(_phs * 2 * pi) * _samp;
	        	var _swamo = cos(_phs * 1 * pi) * _samp;
	        	
	        	nx += _swamo * _drop * gravsx;
	        	ny += _swamo * _drop * gravsy;
	        }
	        
	        na = i? point_direction(ox, oy, nx, ny) : dir;
	        
	        if(i) {
	        	_total_len += point_distance(ox, oy, nx, ny);
	        	nl = _total_len;
	        	draw_line_width2_angle(ox, oy, nx, ny, ot, nt, oa + 90, na + 90, oc, nc, [ol,nl,0,1]);
	        	ol = nl;
	        }
	        
			ott = ntt;
			
	        ox = nx;
	        oy = ny;
	        ot = nt;
	        oc = nc;
	        oa = na;
	    }
		
		shader_set_f("lineThickness", _thk);
		shader_set_f("lineLength",    _total_len);
		
	    draw_primitive_end();
	}
	
	static getDimension = function() /*=>*/ {return inputs[19].getValue()};
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed = _data[ 3];
			var _surf = _data[ 0];
			var _dimm = _data[19];
			
			var _type = _data[15];
			var _p1   = _data[ 1];
			var _p2   = _data[ 2];
			var _rad1 = _data[ 9];
			var _rad2 = _data[10];
			var _pnts = _data[16];
			var _pth  = _data[17];
			var _ptha = _data[18]; _ptha = max(_ptha, 2);
			var _ar1  = _data[22];
			var _ar2  = _data[23];
			
			var _amo  = _data[ 5];
			var _grav = _data[14];
			var _tens = _data[ 4];
			var _segs = _data[ 8];
			
			var _thks     = _data[ 6];
			var _colr     = _data[ 7]; _colr.cache();
			var _colrMap  = _data[21]; _colrMap.cache();
			
			var _swng     = _data[11];
			var _swng_amp = _data[12];
			var _swng_frq = _data[13];
			
			var _linTex   = _data[28]; 
			var _uvPos    = _data[29];
			var _uvSca    = _data[30];
			
			thick_curve.set(_data[20]);
			
			var _ptyp = _type == 2 || _type == 3;
			
			var _useSurf = is_surface(_surf);
			update_on_frame = _swng;
			
			inputs[19].setVisible(!_useSurf);
			
			inputs[ 1].setVisible(_type == 0);
			inputs[ 2].setVisible(_type == 0);
			inputs[ 9].setVisible(_type == 0);
			inputs[10].setVisible(_type == 0);
			
			inputs[16].setVisible(_type == 1, _type == 1);
			inputs[17].setVisible(_ptyp, _ptyp);
			inputs[18].setVisible(_type == 2);
			
			inputs[22].setVisible(_type == 4);
			inputs[23].setVisible(_type == 4);
		#endregion
		
		#region precalc
			random_set_seed(_seed);
			swing_precal = array_create_ext(_amo, function(i) /*=>*/ {return random(1)});
			
			gravx = lengthdir_x(1, _grav); gravsx = lengthdir_x(1, _grav + 90);
			gravy = lengthdir_y(1, _grav); gravsy = lengthdir_y(1, _grav + 90);
		#endregion
		
		surface_set_shader(_outSurf);
			BLEND_OVERRIDE
			draw_surface_safe(_surf);
			BLEND_NORMAL
			
			shader_set(sh_mk_cable_draw);
			shader_set_interpolation(_linTex);
			shader_set_2( "uvPosition", _uvPos );
			shader_set_2( "uvScale",    _uvSca );
			
			switch(_type) {
				case 0 :
					for( var c = 0; c < _amo; c++ ) {
						var _ten = random_range(_tens[0], _tens[1]);
						var _thk = random_range(_thks[0], _thks[1]);
						
						var _rd0 = sqrt(random(1)) * _rad1;
						var _ra0 = random(360);
						
						var _rd1 = sqrt(random(1)) * _rad2;
						var _ra1 = random(360);
						
						var x0 = _p1[0] + lengthdir_x(_rd0, _ra0);
						var y0 = _p1[1] + lengthdir_y(_rd0, _ra0);
						var x1 = _p2[0] + lengthdir_x(_rd1, _ra1);
						var y1 = _p2[1] + lengthdir_y(_rd1, _ra1);
						
						draw_set_color(_colr.evalFast(random(1)));
						drawCable(_data, c, x0, y0, x1, y1, _ten, _segs, _thk);
					}
					break;
					
				case 1 : 
					if(array_safe_length(_pnts) < 2) { surface_reset_target(); return _outSurf; }
					var _pnts_len = array_length(_pnts);
					
					for( var i = 1; i < _pnts_len; i++ ) {
						var ox = _pnts[i - 1][0];
						var oy = _pnts[i - 1][1];
						var nx = _pnts[i][0];
						var ny = _pnts[i][1];
					
						for( var c = 0; c < _amo; c++ ) {
							var _ten = random_range(_tens[0], _tens[1]);
							var _thk = random_range(_thks[0], _thks[1]);
							
							draw_set_color(_colr.evalFast(random(1)));
							drawCable(_data, c, ox, oy, nx, ny, _ten, _segs, _thk);
						}
					}
					break;
					
				case 2 : 
					if(!is_path(_pth)) { surface_reset_target(); return _outSurf; }
					var ox, oy, nx, ny;
					var _p = new __vec2P();
					
					for( var i = 0; i < _ptha; i++ ) {
						_p = _pth.getPointRatio(i / (_ptha - 1), 0, _p);
						nx = _p.x;
						ny = _p.y;
						
						if(i)
						for( var c = 0; c < _amo; c++ ) {
							var _ten = random_range(_tens[0], _tens[1]);
							var _thk = random_range(_thks[0], _thks[1]);
							
							draw_set_color(_colr.evalFast(random(1)));
							drawCable(_data, c, ox, oy, nx, ny, _ten, _segs, _thk);
						}
						
						ox = nx;
						oy = ny;
					}
					break;
					
				case 3 : 
					if(!is_path(_pth)) { surface_reset_target(); return _outSurf; }
					var ox, oy, ot, oc;
					var nx, ny, nt, nc;
					
					var _points = array_create(_segs + 1);
					var _p      = new __vec2P();
					var _isg    = 1 / _segs;
					var len     = _pth.getLength();
					
					var _colrMap  = _data[21]; 
					
					var _thk_curved = inputs[6].attributes.curved;
					var _col_graded = inputs[7].attributes.graded;
	    			
					for( var i = 0; i <= _segs; i++ ) {
						_p = _pth.getPointRatio(i * _isg, 0, _p);
						_points[i] = [_p.x, _p.y];
					}
					
					for( var c = 0; c < _amo; c++ ) {
						var _ten = random_range(_tens[0], _tens[1]);
						var _thk = random_range(_thks[0], _thks[1]);
						var  aa  = _ten * len / 2;
						
					    var _samp = random_range(_swng_amp[0], _swng_amp[1]) * .1;
				    	var _sfrq = round(random_range(_swng_frq[0], _swng_frq[1]));
					    
					    var cc = _colr.evalFast(random(1));
						draw_set_color(cc);
						
						for( var i = 0; i <= _segs; i++ ) {
							var t = i * _isg;
					        var _drop = aa * sin(t * pi);
					        
					        nx = _points[i][0] + _drop * gravx;
							ny = _points[i][1] + _drop * gravy;
							nt = max(1, _thk * (_thk_curved? thick_curve.get(t) : 1));
	        				nc = _col_graded? colorMultiply(cc, _colrMap.evalFast(t)) : cc;
	        				
					        if(_swng) {
					        	var _phs   = swing_precal[c] + (CURRENT_FRAME / TOTAL_FRAMES) * _sfrq;
					        	var _swamo = cos(_phs * 2 * pi) * _samp;
					        	
					        	nx += _swamo * _drop * gravsx;
					        	ny += _swamo * _drop * gravsy;
					        }
					        
							if(i) draw_line_width2(ox, oy, nx, ny, ot, nt, true, oc, nc);
							
							ox = nx;
							oy = ny;
					        ot = nt;
					        oc = nc;
						}
					}
					break;
				
				case 4 :
					for( var c = 0; c < _amo; c++ ) {
						var _ten = random_range(_tens[0], _tens[1]);
						var _thk = random_range(_thks[0], _thks[1]);
						
						var x0 = _ar1[0] + random_range(-_ar1[2], _ar1[2]);
						var y0 = _ar1[1] + random_range(-_ar1[3], _ar1[3]);
						var x1 = _ar2[0] + random_range(-_ar2[2], _ar2[2]);
						var y1 = _ar2[1] + random_range(-_ar2[3], _ar2[3]);
						
						draw_set_color(_colr.evalFast(random(1)));
						drawCable(_data, c, x0, y0, x1, y1, _ten, _segs, _thk);
					}
					break;
			}
			
			shader_reset();
		surface_reset_shader();
		
		return _outSurf;
	}
}