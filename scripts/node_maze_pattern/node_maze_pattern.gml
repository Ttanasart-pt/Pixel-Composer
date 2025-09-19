function Node_Maze_Pattern(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Maze Pattern";
	
	newInput( 3, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Mask" ));
	
	////- =Maze
	newInput( 2, nodeValue_EScroll( "Algorithm",      0, [ "Backtrack", "Prim" ] ));
	newInput( 4, nodeValue_Int(     "Max Iteration", -1 ));
	newInput( 5, nodeValue_Vec2(    "Origin",   [.5,.5] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 9, nodeValue_EButton( "Bias",           0, [ "None", "X", "Y" ] ));
	newInput(10, nodeValue_Slider(  "Bias Weight",   .5 ));
	
	////- =Rendering
	newInput( 6, nodeValue_Color(    "BG Color",       ca_black ));
	newInput( 7, nodeValue_Gradient( "Path Color",     new gradientObject(ca_white) ));
	newInput( 8, nodeValue_Int(      "Path Iteration", 100 ));
	// input 10
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		[ "Output",    false ], 0, 1, 
		[ "Maze",      false ], 2, 4, 5, 9, 10, 
		[ "Rendering", false ], 6, 7, 8, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _seed = _data[ 3];
		
		var _dim  = _data[ 0];
		var _mask = _data[ 1];
		
		var _algo = _data[ 2];
		var _iter = _data[ 4];
		var _orig = _data[ 5];
		var _bias = _data[ 9];
		var _wigh = _data[10];
		
		var _cbg  = _data[ 6];
		var _cwal = _data[ 7]; _cwal.cache();
		var _psca = _data[ 8]; _psca = max(1, _psca);
		
		inputs[10].setVisible(_bias > 0);
		
		var ww = _dim[0];
		var hh = _dim[1];
		
		var ox = clamp(round(_orig[0]), 1, _dim[0] - 1);
		var oy = clamp(round(_orig[1]), 1, _dim[1] - 1);
		
		random_set_seed(_seed);
		surface_set_target(_outSurf);
		draw_clear(_cbg, color_get_alpha(_cbg));
		
		switch(_algo) {
			case 0 : // Backtrack
				var _path = ds_stack_create();
				var _grid = ds_grid_create(ww, hh);
				var _i = 0;
				ds_stack_push(_path, [ ox, oy, -1, 0 ]);
				
				while(!ds_stack_empty(_path)) {
					if(_iter > -1 && _i >= _iter) break;
					
					var _curr_pos = ds_stack_pop(_path);
					var _x = _curr_pos[0];
					var _y = _curr_pos[1];
					var _d = _curr_pos[2];
					var _p = _curr_pos[3];
					
					draw_set_color(_cwal.evalFast(frac(_p / _psca)));
					
					switch(_d) {
						case 0 : if(_grid[# _x, _y + 1] == 0) { draw_point(_x, _y + 1); _grid[# _x, _y + 1] = 1; } break;
						case 1 : if(_grid[# _x - 1, _y] == 0) { draw_point(_x - 1, _y); _grid[# _x - 1, _y] = 1; } break;
						case 2 : if(_grid[# _x, _y - 1] == 0) { draw_point(_x, _y - 1); _grid[# _x, _y - 1] = 1; } break;
						case 3 : if(_grid[# _x + 1, _y] == 0) { draw_point(_x + 1, _y); _grid[# _x + 1, _y] = 1; } break;
					}
					
					if(_grid[# _x, _y] == 0) {
						_grid[# _x, _y] = 1;
						draw_point(_x, _y);
					}
					
					var _dir = _d;
					switch(_bias) {
						case 0 : _dir = (_d + choose(3, 4, 5)) % 4; break;
						case 1 : _dir = choose_weight(_wigh, choose(1, 3), irandom(3)); break;
						case 2 : _dir = choose_weight(_wigh, choose(0, 2), irandom(3)); break;
					}
					
					var _dirr  = choose(-1, 1);
					var _add   = 1;
					var _moved = false;
					
					repeat(4 - bool(_bias)) {
						switch(_dir) {
							case 0 : if(_y >= 2 && _grid[# _x, _y - 2] == 0) {
								ds_stack_push(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_stack_push(_path, [ _x, _y - 2, _dir, _p + 1 ]);
								_moved = true;
							} break;

							case 1 : if(_x < ww - 2 && _grid[# _x + 2, _y] == 0) {
								ds_stack_push(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_stack_push(_path, [ _x + 2, _y, _dir, _p + 1 ]);
								_moved = true;
							} break;

							case 2 : if(_y < hh - 2 && _grid[# _x, _y + 2] == 0) {
								ds_stack_push(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_stack_push(_path, [ _x, _y + 2, _dir, _p + 1 ]);
								_moved = true;
							} break;

							case 3 : if(_x >= 2 && _grid[# _x - 2, _y] == 0) {
								ds_stack_push(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_stack_push(_path, [ _x - 2, _y, _dir, _p + 1 ]);
								_moved = true;
							} break;
						}
						
						if(_moved) { _i++; break; }
						_dir = (_dir + (1 + _add) * _dirr + 4) % 4;
						_add = !_add;
					}
				}
				
				ds_grid_destroy(_grid);
				ds_stack_destroy(_path);
				break;
				
			case 1 : // Prim's Algorithm
				var _path = ds_list_create();
				var _grid = ds_grid_create(ww, hh);
				var _i = 0;
				ds_list_add(_path, [ ox, oy, -1, 0 ]);
				
				while(!ds_list_empty(_path)) {
					if(_iter > -1 && _i >= _iter) break;
					
					var _indx = irandom(ds_list_size(_path) - 1);
					var _curr_pos = _path[| _indx];
					ds_list_delete(_path, _indx);
					
					var _x = _curr_pos[0];
					var _y = _curr_pos[1];
					var _d = _curr_pos[2];
					var _p = _curr_pos[3];
					
					draw_set_color(_cwal.evalFast(frac(_p / _psca)));
					
					switch(_d) {
						case 0 : draw_point(_x, _y + 1); _grid[# _x, _y + 1] = 1; break;
						case 1 : draw_point(_x - 1, _y); _grid[# _x - 1, _y] = 1; break;
						case 2 : draw_point(_x, _y - 1); _grid[# _x, _y - 1] = 1; break;
						case 3 : draw_point(_x + 1, _y); _grid[# _x + 1, _y] = 1; break;
					}
					
					_grid[# _x, _y] = 1;
					draw_point(_x, _y);
					
					var _dir = _d;
					switch(_bias) {
						case 0 : _dir = (_d + choose(3, 4, 5)) % 4; break;
						case 1 : _dir = choose_weight(_wigh, choose(1, 3), irandom(3)); break;
						case 2 : _dir = choose_weight(_wigh, choose(0, 2), irandom(3)); break;
					}
					
					var _dirr  = choose(-1, 1);
					var _add   = 1;
					var _moved = false;
					
					repeat(4 - bool(_bias)) {
						switch(_dir) {
							case 0 : if(_y >= 2 && _grid[# _x, _y - 2] == 0) {
								_grid[# _x, _y - 2] = 1;
								ds_list_add(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_list_add(_path, [ _x, _y - 2, _dir, _p + 1 ]);
								_moved = true;
							} break;

							case 1 : if(_x < ww - 2 && _grid[# _x + 2, _y] == 0) {
								_grid[# _x + 2, _y] = 1;
								ds_list_add(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_list_add(_path, [ _x + 2, _y, _dir, _p + 1 ]);
								_moved = true;
							} break;

							case 2 : if(_y < hh - 2 && _grid[# _x, _y + 2] == 0) {
								_grid[# _x, _y + 2] = 1;
								ds_list_add(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_list_add(_path, [ _x, _y + 2, _dir, _p + 1 ]);
								_moved = true;
							} break;

							case 3 : if(_x >= 2 && _grid[# _x - 2, _y] == 0) {
								_grid[# _x - 2, _y] = 1;
								ds_list_add(_path, [ _x, _y,       -1, _p + 1 ]);
								ds_list_add(_path, [ _x - 2, _y, _dir, _p + 1 ]);
								_moved = true;
							} break;
						}
						
						if(_moved) { _i++; break; }
						_dir = (_dir + (1 + _add) * _dirr + 4) % 4;
						_add = !_add;
					}
				}
				
				ds_grid_destroy(_grid);
				ds_list_destroy(_path);
				break;
				
		}
		
		surface_reset_target();
		
		return _outSurf; 
	}
}