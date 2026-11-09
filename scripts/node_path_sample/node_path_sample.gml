function Node_Path_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sample Path";
	setDrawIcon();
	setDimension(96, 48);
	
	newInput(11, nodeValue_Seed());
	
	////- =Path
	newInput( 6, nodeValue_EScroll(  "Dimension",  0, [ "2D", "3D" ] ));
	newInput( 0, nodeValue_Path(     "Path"              ));
	newInput( 5, nodeValue_Int(      "Path Index", 0     ));
	newInput( 3, nodeValue_SliRange( "Range",     [0,1]  ));
	newInput( 4, nodeValue_Slider(   "Shift",      0     ));
	
	////- =Sample
	newInput( 2, nodeValue_EScroll(  "Type",  0, [ "Loop", "Ping pong", "Clamp" ] ));
	newInput( 1, nodeValue_Float(    "Ratio", 0 ));
	
	////- =Array
	newInput( 8, nodeValue_Bool(    "Multiple",     false ));
	newInput( 9, nodeValue_Int(     "Amount",       4     ));
	newInput(10, nodeValue_EScroll( "Distribution", 0, [ "Random", "Uniform" ] ));

	////- =Output
	newInput( 7, nodeValue_Bool( "Direction", false ));
	// 12
	
	newOutput( 0, nodeValue_Output( "Position",  VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput( 1, nodeValue_Output( "Direction", VALUE_TYPE.float,  0    ));
	newOutput( 2, nodeValue_Output( "Weight",    VALUE_TYPE.float,  0    ));
	
	input_display_list = [ 11, 
		[ "Path",   false    ],  6,  0,  5,  3,  4,  
		[ "Sample", false    ],  2,  1, 
		[ "Array",  false, 8 ],  9, 10, 
		[ "Output", false    ],  7,  
	];
	
	////- Node
	
	__temp_p  = new PathPoint();
	__temp_p0 = new PathPoint();
	__temp_p1 = new PathPoint();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		
		var _pnt = outputs[0].getValue();
		if(array_get_depth(_pnt) == 1) _pnt = [ _pnt ];
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(_pnt); i < n; i++ ) {
			var _p  = _pnt[i];
			var _px = _x + _p[0] * _s;
			var _py = _y + _p[1] * _s;
			
			draw_circle(_px, _py, 4, false);
		}
		
		return w_hovering;
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _seed = _data[11];
			
			var _dimm = _data[ 6];
			var _path = _data[ 0];
			var _pind = _data[ 5];
			var _rng  = _data[ 3];
			var _shft = _data[ 4];
			
			var _mod  = _data[ 2];
			var _rat  = _data[ 1];
			
			var _dirr = _data[ 7];
			
			var _arr  = _data[ 8];
			var _amo  = _data[ 9];
			var _dist = _data[10];
		#endregion
		
		if(!is_path(_path) || !is_real(_rat))  return _output;
		
		random_set_seed(_seed);
		
		var poss = [];
		var dirs = [];
		var weis = [];
		var _amo = _arr? max(1, _amo) : 1;
		
		for( var i = 0; i < _amo; i++ ) {
			var inv = false;
			var rat = _rat;
			
			if(_arr) {
				switch(_dist) {
					case 0 : rat += random(1) break;
					case 1 : rat += i / _amo; break;
				}
			}
			
			rat = lerp(_rng[0], _rng[1], rat + frac(_shft));
			
			switch(_mod) {
				case 0 : rat = frac(rat); break;
				
				case 1 : 
					var fl = floor(rat);
					var fr = frac(rat);
					
					if(fl % 2 == 1 && fr != 0) {
						fr = 1 - fr;
						inv = true;
					}
					rat = fr;
					break;
					
				case 2 : rat = clamp(rat, 0, 0.999); break;
			}
			
			__temp_p = _path.getPointRatio(rat, _pind, __temp_p);
			
			var _px = __temp_p.x;
			var _py = __temp_p.y;
			var wei = __temp_p.w;
			
			var r0 = clamp(rat - 0.0001, 0, 1);
			var r1 = clamp(rat + 0.0001, 0, 1);
			
			if(_dirr) {
				__temp_p0 = _path.getPointRatio(r0, _pind, __temp_p0);
				__temp_p1 = _path.getPointRatio(r1, _pind, __temp_p1);
			}
			
			var pos = [0,0];
			var dir = 0;
			
		    if(_dimm == 0) {
		    	pos = [__temp_p.x, __temp_p.y];
		    	
		    	if(_dirr) {
			     	dir = inv? point_direction(__temp_p1.x, __temp_p1.y, __temp_p0.x, __temp_p0.y) : 
			     	           point_direction(__temp_p0.x, __temp_p0.y, __temp_p1.x, __temp_p1.y)
		    	}
		     	
		    } else if(_dimm == 1) {
		    	pos = [__temp_p.x, __temp_p.y, __temp_p.z];
		    	
		    	if(_dirr) {
			    	dir = inv? [ __temp_p1.x - __temp_p0.x, __temp_p1.y - __temp_p0.y, __temp_p1.z - __temp_p0.z ] : 
			    	           [ __temp_p0.x - __temp_p1.x, __temp_p0.y - __temp_p1.y, __temp_p0.z - __temp_p1.z ]
		    	}
		    }
		    
		    poss[i] = pos;
			dirs[i] = dir;
			weis[i] = wei;
		}
	    
	    if(!_arr) {
	    	poss = poss[0];
			dirs = dirs[0];
			weis = weis[0];
	    }
		
		return [ poss, dirs, weis ];
		
	}
	
}