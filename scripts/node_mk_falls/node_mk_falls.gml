function Node_MK_Fall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Fall";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random());
	
	inputs[| 3] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, AREA_DEF)
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 4] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 10);
	
	inputs[| 5] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1);
	
	inputs[| 6] = nodeValue("X Swing", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 7] = nodeValue("Y Swing", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 8] = nodeValue("Swing frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 9] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue("Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 11] = nodeValue("X Momentum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 12] = nodeValue("Wind", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 13] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
	
	inputs[| 14] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 15] = nodeValue("Ground", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 16] = nodeValue("Ground levels", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ DEF_SURF_H / 2, DEF_SURF_H ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 17] = nodeValue("Y Momentum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
		
	inputs[| 18] = nodeValue("Twist", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 19] = nodeValue("Twist Rate", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 20] = nodeValue("Twist Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 10 ])
		.setDisplay(VALUE_DISPLAY.range);
		
	inputs[| 21] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 22] = nodeValue("Render Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Leaf", "Circle" ]);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 2, 
		["Dimension", false], 0, 1, 
		["Spawn",     false], 3, 4, 
		["Physics",   false], 10, 5, 12,  
		["Swing",     false], 8, 6, 7, 11, 17, 
		["Render",    false], 22, 9, 21, 13, 14, 
		["Ground",     true, 15], 16, 
		["Twist",      true, 18], 19, 20, 
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
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		if(getInputData(15)) {
			var _gr = getInputData(16);
			var _y0 = _y + _gr[0] * _s;
			var _y1 = _y + _gr[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line(0, _y0, 999999, _y0);
			draw_line(0, _y1, 999999, _y1);
		}
	} #endregion
	
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
		
		var _curving = 0;
		var _cvds = 0;
		var _cvdr = 0;
		var _cvrr = 0;
		
		var _gr = _ground == noone? 999999 : random_range(_ground[0], _ground[1]);
		
		var _vx = 0;
		var _vy = 1;
		
		var _p0  = [ 0, 0 ];
		var _p1  = [ _px, _py ];
		var _frc = 1;
		var life = 0;
		
		for(var i = -2; i < t; i++) {
			var _i = life / TOTAL_FRAMES * pi * 4;
			
			if(_curving != 0) {
				_cvdr += _curving;
				
				_vx = lengthdir_x(_cvrr, _cvdr);
				_vy = lengthdir_y(_cvrr, _cvdr);
				
				_cvrr    *= 0.975;
				_curving = clamp(_curving * 1.05, -10, 10);
				
				if(abs(_cvdr - _cvds) > 300) _curving = 0;
			} else {
				_vx  = sin(_sw * _sp * _i) * _sg * _sx * (1 + life / TOTAL_FRAMES * _nx);
				_vy += sin(_sw / _sp * _i * 2)   * _sy * (1 + life / TOTAL_FRAMES * _ny);
				
				if(_twist && random(1) < _twistr) {
					_curving = random_range(_twists[0], _twists[1]) * sign(_vx);
					_cvds    = point_direction(0, 0, _vx, _vy);
					_cvdr    = _cvds;
					_cvrr    = point_distance(0, 0, _vx, _vy) * 2;
					
					if(abs(_curving) <= 1) _curving = 0;
				}
				
				life++;
			}
			
			if(_frc >= 0.2) {
				_p0[0] = _p1[0];
				_p1[0] = _px;
				_px += (_vx + _wind[0]) * _sp * _frc;
			}
			
			_p0[1] = _p1[1];
			_p1[1] = _py;
			_py += (_vy + _wind[1]) * _sp * _frc;
			
			if(_py > _gr) 
				_frc *= 0.5;
			
			_vy += _gravity * _sp;
		}
		
		return [ _p0, _p1, [ _px, _py ] ];
	} #endregion
	
	static step = function() { #region
		var _typ = getInputData(22);
		
		inputs[| 9].setVisible(_typ == 0);
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
		
		_twistr = _twistr * _twistr * _twistr;
		
		var _sed = _seed;
		
		if(is_surface(_surf)) _dim = surface_get_dimension(_surf);
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			BLEND_OVERRIDE
				draw_surface_safe(_surf);
			BLEND_NORMAL
				
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
					
					var _dr0 = point_direction(_p1[0], _p1[1], _p0[0], _p0[1]);
					var _dr2 = point_direction(_p1[0], _p1[1], _p2[0], _p2[1]);
					
					var _sc = random_range_seed(_scale[0], _scale[1], _sed + 20);
					var _sx = _size[0] * _sc;
					var _sy = _size[1] * _sc;
					
					var _p11 = [ _p1[0] + lengthdir_x(_sy, _dr0 + 90), 
					             _p1[1] + lengthdir_y(_sy, _dr0 + 90) ];
					var _p12 = [ _p1[0] + lengthdir_x(_sy, _dr0 - 90), 
					             _p1[1] + lengthdir_y(_sy, _dr0 - 90) ];
					var _p00 = [ _p1[0] + lengthdir_x(_sx, _dr0), 
					             _p1[1] + lengthdir_y(_sx, _dr0) ];
					var _p22 = [ _p1[0] + lengthdir_x(_sx, _dr2), 
					             _p1[1] + lengthdir_y(_sx, _dr2) ];
					
					var _cc = _colr.eval(_ind);
					var _aa = eval_curve_x(_alph, _lif / TOTAL_FRAMES);
					
					draw_set_color(_cc);
					draw_set_alpha(_aa);
					
					if(_rtyp == 0) {
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
				}
				shader_reset();
			BLEND_NORMAL
		surface_reset_target();
	} #endregion
}