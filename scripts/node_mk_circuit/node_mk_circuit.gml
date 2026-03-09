function Node_MK_Circuit(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Circuit";
	
	newInput( 2, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 8, nodeValue_Surface( "Mask" ));
	
	////- =Circuit
	newInput( 1, nodeValue_IVec2(   "Cell Count",     [8,8]   ));
	newInput( 3, nodeValue_Vec2(    "Clamp Distance", [-1,-1] ));
	newInput(15, nodeValue_Bool(    "Diagonal",       false   ));
	newInput(16, nodeValue_Bool(    "Round Corner",   true    ));
	
	////- =Render
	newInput( 4, nodeValue_Surface(  "Bg Surface"                ));
	newInput( 5, nodeValue_Color(    "Bg Color",       ca_black  ));
	newInput( 6, nodeValue_Float(    "Line Thickness", 1         ));
	newInput( 7, nodeValue_Gradient( "Line Color",     gra_white ));
	
	////- =Connection
	newInput( 9, nodeValue_Bool(    "Connection",   true  ));
	newInput(11, nodeValue_EScroll( "Conn. Shape",  0, [ "Circle", "Square", "Surface" ] ));
	newInput(10, nodeValue_Float(   "Conn. Radius", 4     ));
	newInput(14, nodeValue_Bool(    "Conn. Filled", false ));
	newInput(12, nodeValue_Surface( "Conn. Surface"       ));
	
	////- =Algorithm
	newInput(13, nodeValue_Int( "Max Attempt",  8 ));
	// 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2, 
		[ "Output",     false    ],  0,  8, 
		[ "Circuit",    false    ],  1,  3, 15, 16, 
		[ "Render",     false    ],  4,  5,  6,  7, 
		[ "Connection", false, 9 ], 11, 10, 14, 12, 
		[ "Algorithm",  false    ], 13, 
	];
	
	////- Nodes
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed = _data[ 2];
			var _dim  = _data[ 0];
			var _mask = _data[ 8];
			
			var _celc = _data[ 1];
			var _dist = _data[ 3];
			var _diag = _data[15];
			var _roun = _data[16];
			
			var _bgSurf = _data[ 4];
			var _bgColr = _data[ 5];
			var _lThck  = _data[ 6];
			var _lColr  = _data[ 7]; _lColr.cache();
			
			var _conn  = _data[ 9];
			var _cShp  = _data[11];
			var _cRad  = _data[10];
			var _cFil  = _data[14];
			var _cSurf = _data[12], use_cSurf = is_surface(_cSurf);
			
			var _atmp  = _data[13];
			
			inputs[14].setVisible(_cShp != 2);
			inputs[12].setVisible(_cShp == 2, _cShp == 2);
		#endregion
		
		var _rad = _cRad / 2;
		var _cSurfW  = surface_get_width_safe(_cSurf);
		var _cSurfH  = surface_get_height_safe(_cSurf);
		var _cSurfSW = _rad / _cSurfW;
		var _cSurfSH = _rad / _cSurfH;
		
		random_set_seed(_seed);
		
		var _cellX = _celc[0];
		var _cellY = _celc[1];
		var _cellW = floor(_dim[0] / _cellX);
		var _cellH = floor(_dim[1] / _cellY);
		
		var _grid  = mp_grid_create(0, 0, _cellX, _cellY, _cellW, _cellH);
		var _path  = path_add();
		var failed = 0;
		
		var _csx, _csy, _cex, _cey;
		var _psx, _psy, _pex, _pey;
		var minDist = _dist[0] == -1? -infinity : _dist[0];
		var maxDist = _dist[1] == -1?  infinity : _dist[1];
		
		if(is_surface(_mask)) {
			var _maskSamp = new Surface_Sampler_Grey(_mask);
			for( var i = 0; i < _cellY; i++ )
			for( var j = 0; j < _cellX; j++ ) {
				
				var _y = (i + .5) * _cellW;
				var _x = (j + .5) * _cellH;
				var _s = _maskSamp.getPixelDirect(round(_x), round(_y));
				
				if(_s == 0)
					mp_grid_add_cell(_grid, j, i);
			}
			_maskSamp.free();
		}
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			while(failed < _atmp) {
				var _pointMiss = 0, _noPoint = false;
				
				do {
					if(++_pointMiss > 16) { _noPoint = true; break; }
					
					_csx = irandom(_cellX - 1);
					_csy = irandom(_cellY - 1);
					_cex = irandom(_cellX - 1);
					_cey = irandom(_cellY - 1);
					
					_psx = floor((_csx + .5) * _cellW);
					_psy = floor((_csy + .5) * _cellH);
					_pex = floor((_cex + .5) * _cellW);
					_pey = floor((_cey + .5) * _cellH);
					
					if(mp_grid_get_cell(_grid, _csx, _csy) || mp_grid_get_cell(_grid, _cex, _cey))
						continue;
					
					var d = point_distance(_psx, _psy, _pex, _pey);
				} until(d > 0 && d > minDist && d < maxDist);
				
				if(_noPoint) break;
				
			    if(mp_grid_path(_grid, _path, _psx, _psy, _pex, _pey, _diag)) {
			    	var _pnum = path_get_number(_path);
			    	var _parr = array_create(_pnum + 1);
			    	var ox, oy, nx, ny, _px, _py;
			    	
			    	var cc = _lColr.evalFast(random(1));
			    	
			    	draw_set_color(cc);
			    	for( var i = 0; i < _pnum; i++ ) {
			    		var _px = path_get_point_x(_path, i);
			    		var _py = path_get_point_y(_path, i);
			    		
			    		_parr[i] = [ 1, _px, _py ];
			    		mp_grid_add_cell(_grid, _px div _cellW, _py div _cellH);
			    	}
			    	
			    	if(_roun) {
				    	_parr[_pnum] = [ 1, _px, _py ];
				    	for( var i = _pnum-1; i >= 1; i-- ) {
				    		var _x0 = _parr[i-1][1];
				    		var _y0 = _parr[i-1][2];
				    		
				    		var _x1 = _parr[i  ][1];
				    		var _y1 = _parr[i  ][2];
				    		
				    		_parr[i][1] = (_x0 + _x1) / 2;
							_parr[i][2] = (_y0 + _y1) / 2;
				    	}
				    	
				    	_pnum++;
			    	}
			    	
			    	for( var i = 0; i < _pnum; i++ ) {
			    		if(_parr[i][0] == 0) continue;
			    		
			    		nx = _parr[i][1];
			    		ny = _parr[i][2];
			    		
			    		if(i) draw_line_round(ox, oy, nx, ny, _lThck);
			    		
			    		ox = nx;
			    		oy = ny;
			    	}
			    	
			    	if(_conn)
		    		switch(_cShp) {
		    			case 0 :
					    	BLEND_SUBTRACT
					    	draw_set_color(c_white);
					    	draw_circle(_psx, _psy, _rad, 0);
					    	draw_circle(_pex, _pey, _rad, 0);
					    	
					    	BLEND_NORMAL
					    	draw_set_color(cc);
					    	draw_circle(_psx, _psy, _rad, !_cFil);
					    	draw_circle(_pex, _pey, _rad, !_cFil);
			    		break;
			    		
			    		case 1 :
					    	BLEND_SUBTRACT
					    	draw_set_color(c_white);
					    	draw_rectangle(_psx - _rad, _psy - _rad, _psx + _rad, _psy + _rad, 0);
					    	draw_rectangle(_pex - _rad, _pey - _rad, _pex + _rad, _pey + _rad, 0);
					    	
					    	BLEND_NORMAL
					    	draw_set_color(cc);
					    	draw_rectangle(_psx - _rad, _psy - _rad, _psx + _rad, _psy + _rad, !_cFil);
					    	draw_rectangle(_pex - _rad, _pey - _rad, _pex + _rad, _pey + _rad, !_cFil);
			    		break;
			    		
			    		case 2: if(!use_cSurf) break;
			    			draw_surface_ext(_cSurf, _psx - _rad, _psy - _rad, _cSurfSW, _cSurfSH, 0, c_white, 1);
			    			draw_surface_ext(_cSurf, _pex - _rad, _pey - _rad, _cSurfSW, _cSurfSH, 0, c_white, 1);
		    			break;
		    		}
			    	
			    	failed = 0;
			    	
			    } else 
			    	failed++;
			    
			}
		surface_reset_target();
	    
		surface_set_target(_outSurf);
			DRAW_CLEAR
			if(is_surface(_bgSurf)) 
				 draw_surface(_bgSurf, 0, 0);
			else draw_clear(_bgColr);
			
			 draw_surface(temp_surface[0], 0, 0);
		surface_reset_target();
			
		return _outSurf; 
	}
}