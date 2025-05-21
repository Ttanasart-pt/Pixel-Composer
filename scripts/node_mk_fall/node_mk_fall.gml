function Node_MK_Fall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Fall";
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface("Background"));
	
	newInput(1, nodeValue_Dimension());
		
	newInput(2, nodeValueSeed(self));
	
	newInput(3, nodeValue_Area("Area", DEF_AREA));
	
	newInput(4, nodeValue_Int("Amount", 10));
	
	newInput(5, nodeValue_Float("Gravity", 0));
	
	newInput(6, nodeValue_Range("X Swing", [ 1, 1 ], { linked : true }));
	
	newInput(7, nodeValue_Range("Y Swing", [ 0.25, 0.25 ], { linked : true }));
	
	newInput(8, nodeValue_Range("Swing frequency", [ 1, 1 ], { linked : true }));
	
	newInput(9, nodeValue_Vec2("Size", [ 4, 2 ]));
	
	newInput(10, nodeValue_Range("Speed", [ 1, 1 ], { linked : true }));
	
	newInput(11, nodeValue_Range("X Momentum", [ 0, 0 ], { linked : true }));
	
	newInput(12, nodeValue_Vec2("Wind", [ 0, 0 ]));
	
	newInput(13, nodeValue_Gradient("Color", new gradientObject(ca_white)))
	
	newInput(14, nodeValue_Curve("Alpha", CURVE_DEF_11));
	
	newInput(15, nodeValue_Bool("Ground", false));
	
	newInput(16, nodeValue_Range("Ground levels", [ DEF_SURF_H / 2, DEF_SURF_H ]));
	
	newInput(17, nodeValue_Range("Y Momentum", [ 0, 0 ], { linked : true }));
		
	newInput(18, nodeValue_Bool("Twist", false));
		
	newInput(19, nodeValue_Float("Twist Rate", 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(20, nodeValue_Range("Twist Speed", [ 5, 10 ]));
		
	newInput(21, nodeValue_Range("Scale", [ 1, 1 ], { linked : true }));
	
	newInput(22, nodeValue_Enum_Scroll("Render Type",  0, [ new scrollItem("Leaf", s_node_shape_leaf, 0), new scrollItem("Circle", s_node_shape_circle, 0) ]));
	
	newInput(23, nodeValue_Float("Twist Radius", 0.7))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 2, 
		["Dimension", false], 0, 1, 
		["Spawn",     false], 3, 4, 
		["Physics",   false], 10, 5, 12,  
		["Swing",     false], 8, 6, 7, 11, 17, 
		["Render",    false], 22, 9, 21, 13, 14, 
		["Ground",     true, 15], 16, 
		["Twist",      true, 18], 19, 20, 23, 
	];
	
	_gravity = 0;
	_speed   = [ 0, 0 ];
	_xswing  = [ 0, 0 ];
	_xswinn  = [ 0, 0 ];
	_yswing  = [ 0, 0 ];
	_yswinn  = [ 0, 0 ];
	_fswing  = [ 0, 0 ];
	_wind    = [ 0, 0 ];
	_twist   = false;
	_twistr  = 0.01;
	_twists  = [ 0, 0 ];
	_ground  = noone;
	_scale   = [ 0, 0 ];
	
	traj = [];
	traj_index = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		draw_set_color(COLORS._main_accent);
		
		for( var i = 0, n = array_length(traj); i < n; i++ ) {
			var _tj = traj[i];
			var ox, oy, nx, ny;
			
			for( var j = 0, m = array_length(_tj); j < m; j++ ) {
				nx = _x + _tj[j][0] * _s;
				ny = _y + _tj[j][1] * _s;
				
				if(j) {
					draw_set_color(_tj[j - 1][2] != 0? c_red : COLORS._main_accent);
					draw_line(ox, oy, nx, ny);
				}
				
				ox = nx;
				oy = ny;
			}
		}
		
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		if(getInputData(15)) {
			var _gr = getInputData(16);
			var _y0 = _y + _gr[0] * _s;
			var _y1 = _y + _gr[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line(0, _y0, 999999, _y0);
			draw_line(0, _y1, 999999, _y1);
		}
		
		return w_hovering;
	}
	
	static getPosition = function(ind, t, _area) { #region
		random_set_seed(ind);
		
		var _px = _area[0], _py = _area[1];
		
		if(_area[4] == 0) {
			_px = irandom_range(_area[0] - _area[2], _area[0] + _area[2]);
			_py = irandom_range(_area[1] - _area[3], _area[1] + _area[3]);
		} else if(_area[4] == 1) {
			var _dir = random(360);
			_px = _area[0] + lengthdir_x(_area[2], _dir);
			_py = _area[1] + lengthdir_y(_area[3], _dir);
		}
		
		var _sg = choose(1, -1);
		
		var _sx = random_range(_xswing[0], _xswing[1]);
		var _nx = random_range(_xswinn[0], _xswinn[1]);
		var _sy = random_range(_yswing[0], _yswing[1]);
		var _ny = random_range(_yswinn[0], _yswinn[1]);
		var _sw = random_range(_fswing[0], _fswing[1]);
		var _sp = random_range(_speed [0], _speed [1]);
		var _td = _twistd;
		var _tr = _twistr;
		
		var _curving = 0;
		var _curved  = false;
		var _cvds = 0;
		var _cvdr = 0;
		var _cvrr = 0;
		var _cv_x = 0;
		var _cv_y = 0;
		
		var _gr = _ground == noone? 999999 : random_range(_ground[0], _ground[1]);
		
		var _vx = 0;
		var _vy = _sp;
		
		var _vvx = _vx;
		var _vvy = _vy;
		
		var _p0  = [ 0, 0 ];
		var _p1  = [ _px, _py ];
		var _frc = 1;
		var life = 0;
		
		_sx *= _sw * _sg;
		_sy *= _sw;
		
		var _swp = _sw * _sp;
		var _sp2 = _sp * _sp;
		
		var poss = array_create(t + 2);
		
		var _vds = point_distance(0, 0, _vx, _vy);
		var _vdr = point_direction(0, 0, _vx, _vy);
		
		for(var i = -2; i < t; i++) {
			
			if(_curving != 0) {
				_cvdr += _curving;
				
				_vx = lengthdir_x(_cvrr, _cvdr);
				_vy = lengthdir_y(_cvrr, _cvdr);
				
				_cvrr    *= _td;
				_curving =  clamp(_curving * 1.05, -45, 45);
				
				if(abs(_cvdr - _cvds) > 360) {
					_curving = 0;
					
					_vx = _cv_x;
					_vy = _cv_y;
				}
			} else {
				var _i = life / 30 * pi * 4;
				
				_vx -= cos(_swp * _i)     * _sx * (1 + life / 30 * _nx) * _sp2;
				_vy += sin(_swp * _i * 2) * _sy * (1 + life / 30 * _ny) * _sp2;
				
				if(life > 2 && _twist && random(1) < (_tr * clamp(life / 30, 0, 1))) {
					_curving = random_range(_twists[0], _twists[1]) * sign(_vx);
					_cvds    = point_direction(0, 0, _vx, _vy);
					_cvdr    = _cvds;
					_cvrr    = point_distance(0, 0, _vx, _vy) * 2;
					_curved  = true;
					
					_cv_x = _vx;
					_cv_y = _vy;
					
					if(abs(_curving) <= 1) _curving = 0;
				}
				
				life++;
			}
			
			poss[i + 2] = [ _px, _py, _curving ];
			
			var __vvds = point_distance(0, 0, _vx, _vy);
			var __vvdr = point_direction(0, 0, _vx, _vy);
			
			_vds = lerp(            _vds, __vvds, 0.5);
			_vdr = lerp_float_angle(_vdr, __vvdr, 0.5);
			
			var _vvx = lengthdir_x(_vds, _vdr);
			var _vvy = lengthdir_y(_vds, _vdr);
			
			if(_frc >= 0.2) {
				_p0[0] = _p1[0];
				_p1[0] = _px;
				_px += (_vvx + _wind[0] * _sp) * _frc;
			}
			
			_p0[1] = _p1[1];
			_p1[1] = _py;
			_py += (_vvy + _wind[1] * _sp) * _frc;
			
			if(_py > _gr) 
				_frc *= 0.5;
			
			_vy += _gravity * _sp;
		}
		
		if(traj_index < 16) traj[traj_index] = poss;
		
		return [ _p0, _p1, [ _px, _py ] ];
	} #endregion
	
	static step = function() { #region
		var _typ = getInputData(22);
		
		inputs[9].setVisible(_typ == 0);
	} #endregion
	
	static update = function() { #region
		var _surf = getInputData(0);
		var _dim  = getInputData(1);
		var _seed = getInputData(2);
		var _area = getInputData(3);
		var _amou = getInputData(4);
		_gravity  = getInputData(5);
		_xswing   = getInputData(6);
		_yswing   = getInputData(7);
		_fswing   = getInputData(8);
		var _size = getInputData(9);
		_speed    = getInputData(10);
		_xswinn   = getInputData(11);
		_wind     = getInputData(12);
		var _colr = getInputData(13);
		var _alph = getInputData(14);
		_ground   = getInputData(15)? getInputData(16) : noone;
		_yswinn   = getInputData(17);
		_twist    = getInputData(18);
		_twistr   = getInputData(19);
		_twists   = getInputData(20);
		_scale    = getInputData(21);
		var _rtyp = getInputData(22);
		_twistd   = getInputData(23); _twistd = power(_twistd, 0.2);
		
		_twistr = _twistr * _twistr * _twistr;
		
		var _sed = _seed;
		
		if(is_surface(_surf)) _dim = surface_get_dimension(_surf);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			BLEND_OVERRIDE
				draw_surface_safe(_surf);
			BLEND_ALPHA_MULP
				
				traj_index = 0;
				traj = array_create(min(16, _amou));
				
				shader_set(sh_draw_divide);
				for( var i = 0; i < _amou; i++ ) {
					_sed += 100;
					
					var _ind  = random_seed(1, _sed + 5);
					var _lifs = irandom_seed(TOTAL_FRAMES, _sed);
					var _lif  = (_lifs + CURRENT_FRAME) % TOTAL_FRAMES;
					
					var _pos = getPosition(_sed, _lif, _area);
					var _p0  = _pos[0];
					var _p1  = _pos[1];
					var _p2  = _pos[2];
					
					var _sc = random_range_seed(_scale[0], _scale[1], _sed + 20);
					var _sx = _size[0] * _sc;
					var _sy = _size[1] * _sc;
					
					var _cc = _colr.eval(_ind);
					var _aa = eval_curve_x(_alph, _lif / TOTAL_FRAMES);
					
					draw_set_color(_cc);
					draw_set_alpha(_aa);
					
					if(_rtyp == 0) {
						var _dr0 = point_direction(_p1[0], _p1[1], _p0[0], _p0[1]);
						var _dr2 = point_direction(_p1[0], _p1[1], _p2[0], _p2[1]);
					
						var _p11 = [ _p1[0] + lengthdir_x(_sy, _dr0 + 90), 
						             _p1[1] + lengthdir_y(_sy, _dr0 + 90) ];
						var _p12 = [ _p1[0] + lengthdir_x(_sy, _dr0 - 90), 
						             _p1[1] + lengthdir_y(_sy, _dr0 - 90) ];
						var _p00 = [ _p1[0] + lengthdir_x(_sx, _dr0), 
						             _p1[1] + lengthdir_y(_sx, _dr0) ];
						var _p22 = [ _p1[0] + lengthdir_x(_sx, _dr2), 
						             _p1[1] + lengthdir_y(_sx, _dr2) ];
						
						draw_primitive_begin(pr_trianglestrip);
							draw_vertex(_p00[0], _p00[1]);
							draw_vertex(_p11[0], _p11[1]);
							draw_vertex(_p12[0], _p12[1]);
							draw_vertex(_p22[0], _p22[1]);
						draw_primitive_end();
					} else if(_rtyp == 1) {
						draw_circle_prec(_p0[0], _p0[1], _sc, false, 16);
					}
					
					draw_set_alpha(1);
					
					traj_index++;
				}
				shader_reset();
				
			BLEND_NORMAL
		surface_reset_target();
	} #endregion
}