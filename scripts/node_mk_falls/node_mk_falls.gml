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
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 2, 
		["Dimension", false], 0, 1, 
		["Spawn",     false], 3, 4, 
		["Physics",   false], 10, 5, 12,  
		["Swing",     false], 8, 6, 7, 11, 
		["Render",    false], 9, 13, 14, 
		["Ground",     true, 15], 16, 
	];
	
	_gravity = 0;
	_speed   = [ 0, 0 ];
	_xswing  = [ 0, 0 ];
	_xswinn  = [ 0, 0 ];
	_yswing  = [ 0, 0 ];
	_fswing  = [ 0, 0 ];
	_wind    = [ 0, 0 ];
	_ground  = noone;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		if(getInputData(15)) {
			var _gr = getInputData(16);
			var _y0 = _y + _gr[0] * _s;
			var _y1 = _y + _gr[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line(0, _y0, 999999, _y0);
			draw_line(0, _y1, 999999, _y1);
		}
	}
	
	static getPosition = function(ind, t, _area) { #region
		random_set_seed(ind);
		
		var _px = irandom_range(_area[0] - _area[2], _area[0] + _area[2]);
		var _py = irandom_range(_area[1] - _area[3], _area[1] + _area[3]);
		
		var _sg = choose(1, -1);
		
		var _sx = random_range(_xswing[0], _xswing[1]);
		var _nx = random_range(_xswinn[0], _xswinn[1]);
		var _sy = random_range(_yswing[0], _yswing[1]);
		var _sw = random_range(_fswing[0], _fswing[1]);
		var _sp = random_range(_speed [0], _speed [1]);
		
		var _gr = _ground == noone? 999999 : random_range(_ground[0], _ground[1]);
		
		var _vx = 0;
		var _vy = 1;
		
		var _p0;
		var _p1 = [ _px, _py ];
		
		for(var i = -2; i < t; i++) {
			var _i = i / TOTAL_FRAMES * pi * 4;
			
			_vx  = sin(_sw * _sp * _i) * _sg * _sx * (1 + i / TOTAL_FRAMES * _nx);
			_vy += sin(_sw / _sp * _i * 2)   * _sy;
			
			if(_py <= _gr || i < 0) {
				_p0 = [ _p1[0], _p1[1] ];
				_p1 = [ _px, _py ];
			}
			
			if(_py <= _gr) {
				_px += (_vx + _wind[0]) * _sp;
				_py += (_vy + _wind[1]) * _sp;
			}
			
			_vy += _gravity * _sp;
		}
		
		return [ _p0, _p1, [ _px, _py ] ];
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
		
		var _sed = _seed;
		
		if(is_surface(_surf)) _dim = surface_get_dimension(_surf);
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			BLEND_OVERRIDE
				draw_surface_safe(_surf);
			BLEND_ALPHA_MULP
			
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
					
					var _p11 = [ _p1[0] + lengthdir_x(_size[1], _dr0 + 90), 
					             _p1[1] + lengthdir_y(_size[1], _dr0 + 90) ];
					var _p12 = [ _p1[0] + lengthdir_x(_size[1], _dr0 - 90), 
					             _p1[1] + lengthdir_y(_size[1], _dr0 - 90) ];
					var _p00 = [ _p1[0] + lengthdir_x(_size[0], _dr0), 
					             _p1[1] + lengthdir_y(_size[0], _dr0) ];
					var _p22 = [ _p1[0] + lengthdir_x(_size[0], _dr2), 
					             _p1[1] + lengthdir_y(_size[0], _dr2) ];
					
					var _cc = _colr.eval(_ind);
					var _aa = eval_curve_x(_alph, _lif / TOTAL_FRAMES);
					
					draw_set_color(_cc);
					draw_set_alpha(_aa);
					
					draw_primitive_begin(pr_trianglestrip);
					
						draw_vertex(_p00[0], _p00[1]);
						draw_vertex(_p11[0], _p11[1]);
						draw_vertex(_p12[0], _p12[1]);
						draw_vertex(_p22[0], _p22[1]);
						
					draw_primitive_end();
					
					draw_set_alpha(1);
				}
			BLEND_NORMAL
		surface_reset_target();
	} #endregion
}