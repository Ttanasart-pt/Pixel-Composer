function Node_MK_Cable(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Cables";
	
	newInput(3, nodeValueSeed());
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Anchors
	
	newInput(15, nodeValue_Enum_Scroll("Type",   0, [ "Fix Points", "Fix Point Array", "Path Anchor", "Path Sample" ] ));
	
	newInput( 1, nodeValue_Vec2(  "Point 1",  [ 0, 0 ]));
	newInput( 2, nodeValue_Vec2(  "Point 2",  [ 16, 16 ]));
	newInput( 9, nodeValue_Float( "Radius 1", 0));
	newInput(10, nodeValue_Float( "Radius 2", 0));
	newInput(16, nodeValue_Vec2(  "Points",   [])).setArrayDepth(1);
	newInput(17, nodeValue_PathNode( "Path",    noone));
	newInput(18, nodeValue_Int(      "Path Points", 8));
	
	////- =Cable
	
	newInput( 5, nodeValue_Int(      "Amount",   1  ));
	newInput(14, nodeValue_Rotation( "Gravity", -90 ));
	newInput( 4, nodeValue_Range(    "Tension",  [ 1, 1 ], { linked : true } ));
	newInput( 8, nodeValue_Int(      "Segments", 16 ));
	
	////- =Swing
	
	newInput(11, nodeValue_Bool(  "Swing",     false ));
	newInput(12, nodeValue_Range( "Amplitude", [ .5, .5 ], { linked : true } ));
	newInput(13, nodeValue_Range( "Frequency", [ 1, 1 ], { linked : true } ));
	
	////- =Render
	
	newInput(6, nodeValue_Range(    "Thickness", [ 1, 1 ], { linked : true } ));
	newInput(7, nodeValue_Gradient( "Colors", new gradientObject(ca_white)));
	
	// input 19
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 3, 0, 
		["Anchors", false    ], 15, 1, 2, 9, 10, 16, 17, 18, 
		["Cable",   false    ], 5, 14, 4, 8, 
		["Swing",   false, 11], 12, 13, 
		["Render",  false    ], 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _type = getSingleValue(15);
		
		if(_type == 0) {
			var _pos1 = getSingleValue( 1);
			var _pos2 = getSingleValue( 2);
			
			var _rad1 = getSingleValue( 9);
			var _rad2 = getSingleValue(10);
			
			var _p1x = _x + _pos1[0]*_s;
			var _p1y = _y + _pos1[1]*_s;
			
			var _p2x = _x + _pos2[0]*_s;
			var _p2y = _y + _pos2[1]*_s;
			
			draw_set_color(COLORS._main_accent);
			draw_circle_dash(_p1x, _p1y, _rad1*_s);
			draw_circle_dash(_p2x, _p2y, _rad2*_s);
			
			InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			
			if(_rad1) InputDrawOverlay(inputs[ 9].drawOverlay(w_hoverable, active, _p1x, _p1y, _s, _mx, _my, _snx, _sny, 0, 1, 1));
			if(_rad2) InputDrawOverlay(inputs[10].drawOverlay(w_hoverable, active, _p2x, _p2y, _s, _mx, _my, _snx, _sny, 0, 1, 1));
		}
		
		return w_hovering;
	}
	
	function drawCable(c, x0, y0, x1, y1, _ten, _segs, _thk) {
		var len  = point_distance(x0, y0, x1, y1);
	    var aa   = _ten * len / 2;
	    var _isg = 1 / _segs;
	    var ox, oy, nx, ny;
	    
	    var _samp = random_range(_swng_amp[0], _swng_amp[1]) * .1;
    	var _sfrq = round(random_range(_swng_frq[0], _swng_frq[1]));
	    
	    for (var i = 0; i <= _segs; i++) {
	        var t = i  * _isg;
	        var _drop = aa * sin(t * pi);
	        
	        nx = lerp(x0, x1, t) + _drop * _gx;
	        ny = lerp(y0, y1, t) + _drop * _gy;
	        
	        if(_swng) {
	        	var _phs   = _swphs[c] + (CURRENT_FRAME / TOTAL_FRAMES) * _sfrq;
	        	var _swamo = cos(_phs * 2 * pi) * _samp;
	        	
	        	nx += _swamo * _drop * _gsx;
	        	ny += _swamo * _drop * _gsy;
	        }
	        
	        if (i) draw_line_round(ox, oy, nx, ny, _thk);
	
	        ox = nx;
	        oy = ny;
	    }
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _seed = _data[3];
		var _surf = _data[0];
		
		var _type = _data[15];
		var _p1   = _data[ 1];
		var _p2   = _data[ 2];
		var _rad1 = _data[ 9];
		var _rad2 = _data[10];
		var _pnts = _data[16];
		var _pth  = _data[17];
		var _ptha = _data[18]; _ptha = max(_ptha, 2);
		
		var _amo  = _data[ 5];
		var _grav = _data[14];
		var _tens = _data[ 4];
		var _segs = _data[ 8];
		
		var _thks = _data[6];
		var _colr = _data[7];
		
		_swng     = _data[11];
		_swng_amp = _data[12];
		_swng_frq = _data[13];
		
		var _ptyp = _type == 2 || _type == 3;
		
		inputs[ 1].setVisible(_type == 0);
		inputs[ 2].setVisible(_type == 0);
		inputs[ 9].setVisible(_type == 0);
		inputs[10].setVisible(_type == 0);
		
		inputs[16].setVisible(_type == 1, _type == 1);
		inputs[17].setVisible(_ptyp, _ptyp);
		inputs[18].setVisible(_type == 2);
		
		random_set_seed(_seed);
		
		update_on_frame = _swng;
		_swphs = array_create_ext(_amo, function(i) /*=>*/ {return random(1)});
		
		_gx  = lengthdir_x(1, _grav);
		_gy  = lengthdir_y(1, _grav);
		_gsx = lengthdir_x(1, _grav + 90);
		_gsy = lengthdir_y(1, _grav + 90);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(_surf);
			BLEND_NORMAL
			
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
						
						draw_set_color(_colr.eval(random(1)));
						drawCable(c, x0, y0, x1, y1, _ten, _segs, _thk);
					}
					break;
					
				case 1: 
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
							
							draw_set_color(_colr.eval(random(1)));
							drawCable(c, ox, oy, nx, ny, _ten, _segs, _thk);
						}
					}
					break;
					
				case 2 : 
					if(!struct_has(_pth, "getPointRatio")) { surface_reset_target(); return _outSurf; }
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
							
							draw_set_color(_colr.eval(random(1)));
							drawCable(c, ox, oy, nx, ny, _ten, _segs, _thk);
						}
						
						ox = nx;
						oy = ny;
					}
					break;
					
				case 3 : 
					if(!struct_has(_pth, "getPointRatio")) { surface_reset_target(); return _outSurf; }
					var ox, oy, nx, ny;
					
					var _points = array_create(_segs + 1);
					var _p      = new __vec2P();
					var _isg    = 1 / _segs;
					var len     = _pth.getLength();
	    			
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
					    
						draw_set_color(_colr.eval(random(1)));
						
						for( var i = 0; i <= _segs; i++ ) {
							var t = i * _isg;
					        var _drop = aa * sin(t * pi);
					        
					        nx = _points[i][0] + _drop * _gx;
							ny = _points[i][1] + _drop * _gy;
									        
					        if(_swng) {
					        	var _phs   = _swphs[c] + (CURRENT_FRAME / TOTAL_FRAMES) * _sfrq;
					        	var _swamo = cos(_phs * 2 * pi) * _samp;
					        	
					        	nx += _swamo * _drop * _gsx;
					        	ny += _swamo * _drop * _gsy;
					        }
					        
							if(i) draw_line_round(ox, oy, nx, ny, _thk);
							
							ox = nx;
							oy = ny;
						}
					}
					break;
			}
			
		surface_reset_target();
		
		return _outSurf;
	}
}