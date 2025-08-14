function Node_MK_Pile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Pile";
	dimension_index = 1;
	
	newInput( 1, nodeValue_Dimension());
	newInput( 2, nodeValueSeed());
	
	////- =Object
	newInput( 0, nodeValue_Surface(     "Surface In"    ));
	newInput( 3, nodeValue_Enum_Scroll( "Pattern",    0, [ "Auto", "Manual" ] ));
	newInput( 4, nodeValue_Float( "Depth",            2 ));
	newInput( 9, nodeValue_Float( "Depth Adjustment", 0 ));
	
	////- =Pile
	newInput( 5, nodeValue_Vec2(   "Origin",             [.5,.8] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 6, nodeValue_Int(    "Amount",              4            )).setValidator(VV_min(1));
	newInput( 7, nodeValue_Range(  "Angles of Repose",   [45,45], true ));
	newInput( 8, nodeValue_Vec2(   "Column Shift",       [0,0]         ));
	newInput(10, nodeValue_Float(  "Center Bias",         0            ));
	newInput(13, nodeValue_Slider( "Shuffle",             0            ));
	
	////- =Scatter
	newInput(11, nodeValue_Int(   "Amount", 0 )).setValidator(VV_min(0));
	newInput(12, nodeValue_Range( "Range",  [.75, 1.5] ));
	// inputs 14
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 2, 
		["Object",  false ], 0, 3, 4, 9, 
		["Pile",    false ], 5, 6, 7, 8, 10, 13, 
		["Scatter", false ], 11, 12, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		draw_set_color(COLORS._main_accent);
		
		InputDrawOverlay(inputs[5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim  = _data[1];
			var _seed = _data[2];
			
			var _surf = _data[ 0];
			var _patt = _data[ 3];
			var _dept = _data[ 4];
			var _depj = _data[ 9];
			
			var _orig = _data[ 5];
			var _amou = _data[ 6];
			var _repo = _data[ 7];
			var _shft = _data[ 8];
			var _cent = _data[10];
			var _shuf = _data[13];
			
			var _scat    = _data[11];
			var _scatRng = _data[12];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _sw   = surface_get_width_safe(_surf);
		var _sh   = surface_get_height_safe(_surf);
		var _grid = sqrt(_amou * 2);
	    var pile_height = array_create(_grid * _grid);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var dd = _dept + _depj;
			var rowMax = 0, colMax = 0;
			
		    random_set_seed(_seed);
		    repeat(_amou) {
		        var _row = 0, _col = 0;
		        
		        while(true) {
		            var height = pile_height[_row * _grid + _col];
		            if(height == 0) break;
		            var colh   = _sh + (height  - 1) * dd;
		            
		            var heightL = (_row < _grid - 1)? pile_height[(_row + 1) * _grid + _col] : 0;
		            if(heightL < height) {
			            var colhL  = bool(heightL) * (_sh + (heightL - 1) * dd);
			            var angL   = darctan2(colh - colhL, _sw);
			            var repoL  = _repo[0] + _cent * abs((_row + 1) - _col);
			                repoL *= random_range(1 - _shuf, 1 + _shuf);
			            
			            if(angL >= repoL) {
		                    _row++;
		                    if(heightL == 0) break;
		                    continue;
		                }
		            }
	                
		            var heightR = (_col < _grid - 1)? pile_height[_row * _grid + _col + 1] : 0;
		            if(heightR < height) {
			            var colhR  = bool(heightR) * (_sh + (heightR - 1) * dd);
			            var angR   = darctan2(colh - colhR, _sw);
			            var repoR  = _repo[1] + _cent * abs(_row - (_col + 1));
			                repoR *= random_range(1 - _shuf, 1 + _shuf);
			                
		                if(angR >= repoR) {
		                    _col++;
		                    if(heightR == 0) break;
		                    continue;
		                }
		            }
	            	
	            	break;
		        }
		        
	            pile_height[_row * _grid + _col]++;
	            
	            rowMax = max(rowMax, _row);
	            colMax = max(colMax, _col);
		    }
		    
		    random_set_seed(_seed);
		    repeat(_scat) {
		    	var _spanMax  = rowMax + colMax;
		    	var _stepSize = irandom_range(_spanMax * _scatRng[0], _spanMax * _scatRng[1]);
		    	
		    	var _row = 0, 
		    	var _col = 0;
		    	repeat(_stepSize) {
		    		if(choose(0,1)) _row++;
		    		else _col++;
		    	}
		    	
		    	pile_height[min(_row, _grid - 1) * _grid + min(_col, _grid - 1)]++;
		    }
		    
		    var _row = 0, _col = 0;
		    repeat(_amou) {
		    	var _hh = pile_height[_row * _grid + _col];
		    	
		    	if(_hh > 0) {
			    	var _colX = _orig[0] + _col * (_sw / 2 + _shft[0]) - _row * (_sh / 2 + _shft[0]);
			    	var _colY = _orig[1] + _col * (_sw / 2 + _shft[1]) + _row * (_sh / 2 + _shft[1]);
			    	
			    	_colX -= _sw / 2;
					_colY -= _sh / 2;
					
					repeat(_hh) {
						draw_surface(_surf, _colX, _colY);
						_colY -= _dept;
					}
		    	}
		    	
		    	if(_row == 0) {
		    		_row = _col + 1;
		    		_col = 0;
		    		
		    	} else {
		    		_row--;
		    		_col++;
		    	}
		    }
		    
		surface_reset_target();
		
		return _outSurf;
	}
}