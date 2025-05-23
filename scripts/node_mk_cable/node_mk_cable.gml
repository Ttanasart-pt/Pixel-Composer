function Node_MK_Cable(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Cables";
	
	newInput(3, nodeValueSeed());
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Anchors
	
	newInput( 1, nodeValue_Vec2(  "Point 1",  [ 0, 0 ]));
	newInput( 2, nodeValue_Vec2(  "Point 2",  [ 16, 16 ]));
	newInput( 9, nodeValue_Float( "Radius 1", 0));
	newInput(10, nodeValue_Float( "Radius 2", 0));
	
	////- =Cable
	
	newInput(4, nodeValue_Range( "Tension",  [ 1, 1 ], { linked : true } ));
	newInput(8, nodeValue_Int(   "Segments", 16 ));
	newInput(5, nodeValue_Int(   "Amount",    1 ));
	
	////- =Swing
	
	newInput(11, nodeValue_Bool(  "Swing",     false ));
	newInput(12, nodeValue_Range( "Amplitude", [ .5, .5 ], { linked : true } ));
	newInput(13, nodeValue_Range( "Frequency", [ 1, 1 ], { linked : true } ));
	
	////- =Render
	
	newInput(6, nodeValue_Range(    "Thickness", [ 1, 1 ], { linked : true } ));
	newInput(7, nodeValue_Gradient( "Colors", new gradientObject(ca_white)));
	
	// input 14
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 3, 0, 
		["Anchors", false    ], 1, 2, 9, 10, 
		["Cable",   false    ], 4, 8, 5, 
		["Swing",   false, 11], 12, 13, 
		["Render",  false    ], 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
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
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _seed = _data[3];
		var _surf = _data[0];
		
		var _p1   = _data[ 1];
		var _p2   = _data[ 2];
		var _rad1 = _data[ 9];
		var _rad2 = _data[10];
		
		var _tens = _data[4];
		var _segs = _data[8];
		var _amo  = _data[5];
		
		var _thks = _data[6];
		var _colr = _data[7];
		
		var _swng     = _data[11];
		var _swng_amp = _data[12];
		var _swng_frq = _data[13];
		
		random_set_seed(_seed);
		
		update_on_frame = _swng;
		
		var _isg   = 1/_segs;
		var _swphs = array_create_ext(_amo, function(i) /*=>*/ {return random(1)});
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(_surf);
			BLEND_NORMAL
			
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
				
				var dx = x1 - x0;
			    var dy = y1 - y0;
			    var length = point_distance(x0, y0, x1, y1);
			    var a = _ten * length / 2;
			
			    var ox, oy, nx, ny;
				
				draw_set_color(_colr.eval(random(1)));
				
				var _samp = random_range(_swng_amp[0], _swng_amp[1]) * .1;
	        	var _sfrq = round(random_range(_swng_frq[0], _swng_frq[1]));
			        	
			    for (var i = 0; i <= _segs; i++) {
			        var t = i  * _isg;
			        var _drop = a * sin(t * pi);
			        
			        nx = x0 + dx * t;
			        ny = y0 + dy * t + _drop;
			        
			        if(_swng) {
			        	var _phs   = _swphs[c] + (CURRENT_FRAME / TOTAL_FRAMES) * _sfrq;
			        	var _swamo = cos(_phs * 2 * pi) * _samp;
			        	
			        	nx += _swamo * _drop;
			        }
			        
			        if (i) draw_line_round(ox, oy, nx, ny, _thk);
			
			        ox = nx;
			        oy = ny;
			    }
			}
			
		surface_reset_target();
		
		return _outSurf;
	}
}