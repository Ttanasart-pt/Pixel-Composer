function Node_Repeat(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Repeat";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, PIXEL_SURFACE );
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 3] = nodeValue(3, "Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Linear", "Grid", "Circular" ]);
	
	inputs[| 4] = nodeValue(4, "Repeat position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [def_surf_size / 2, 0])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function() { return getDimension(); });
	
	inputs[| 5] = nodeValue(5, "Repeat rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 6] = nodeValue(6, "Scale multiply", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 7] = nodeValue(7, "Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 360])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 8] = nodeValue(8, "Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
		
	inputs[| 9] = nodeValue(9, "Start position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return inputs[| 1].getValue(); });
		
	inputs[| 10] = nodeValue(10, "Scale over copy", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 11] = nodeValue(11, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, noone )
		.setVisible(true, true);
	
	inputs[| 12] = nodeValue(12, "Path range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
	
	inputs[| 13] = nodeValue(13, "Path shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 14] = nodeValue(14, "Color over copy", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
		
	inputs[| 15] = nodeValue(15, "Alpha over copy", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 16] = nodeValue(16, "Array select", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Order", "Random" ]);
	
	inputs[| 17] = nodeValue(17, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(99999) );
	
	inputs[| 18] = nodeValue(18, "Column", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 19] = nodeValue(19, "Column shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, def_surf_size / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function() { return getDimension(); });
	
	inputs[| 20] = nodeValue(20, "Animator midpoint", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 2, 0.01]);
	
	inputs[| 21] = nodeValue(21, "Animator range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 22] = nodeValue(22, "Animator position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 23] = nodeValue(23, "Animator rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 24] = nodeValue(24, "Animator scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 25] = nodeValue(25, "Animator falloff", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_10);
	
	inputs[| 26] = nodeValue(26, "Stack", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "X", "Y" ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Surface",		 true],	0, 1, 16, 17,
		["Pattern",		false],	3, 9, 2, 18, 7, 8, 
		["Path",		 true],	11, 12, 13, 
		["Transform",	false],	4, 26, 19, 5, 6, 10, 
		["Render",		false],	14, 15,
		["Animator",	 true],	20, 21, 25, 22, 23, 24, 
	];
	
	static getDimension = function() {
		var _surf = inputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return [1, 1];
			if(!is_surface(_surf[0])) return [1, 1];
			return [ surface_get_width(_surf[0]), surface_get_height(_surf[0]) ];
		}
			
		if(!is_surface(_surf)) return [1, 1];
		return [ surface_get_width(_surf), surface_get_height(_surf) ];
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inputs[| 9].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny, THEME.anchor))
			active = false;
		
		var _pat  = inputs[| 3].getValue();
		var _spos = inputs[| 9].getValue();
		
		var px = _x + _spos[0] * _s;
		var py = _y + _spos[1] * _s;
			
		if(_pat == 0 || _pat == 1) {
			if(inputs[| 4].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny))
				active = false;
		} else if(_pat == 2) {
			if(inputs[| 8].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny))
				active = false;
		}
	}
	
	static update = function() {
		var _inSurf = inputs[| 0].getValue();
		var _dim  = inputs[|  1].getValue();
		var _amo  = inputs[|  2].getValue();
		var _pat  = inputs[|  3].getValue();
							  
		var _spos = inputs[|  9].getValue();
		
		var _rpos = inputs[|  4].getValue();
		var _rsta = inputs[| 26].getValue();
		var _rrot = inputs[|  5].getValue();
		var _rsca = inputs[|  6].getValue();
		var _msca = inputs[| 10].getValue();
		
		var _aran = inputs[|  7].getValue();
		var _arad = inputs[|  8].getValue();
		
		var _path = inputs[| 11].getValue();
		var _prng = inputs[| 12].getValue();
		var _prsh = inputs[| 13].getValue();
		
		var _grad = inputs[| 14].getValue();
		var _grad_data = inputs[| 14].getExtraData();
		var _alph = inputs[| 15].getValue();
		
		var _arr = inputs[| 16].getValue();
		var _sed = inputs[| 17].getValue();
		
		var _col = inputs[| 18].getValue();
		var _cls = inputs[| 19].getValue();
		
		var _an_mid = inputs[| 20].getValue();
		var _an_ran = inputs[| 21].getValue();
		var _an_fal = inputs[| 25].getValue();
		var _an_pos = inputs[| 22].getValue();
		var _an_rot = inputs[| 23].getValue();
		var _an_sca = inputs[| 24].getValue();
		
		random_set_seed(_sed);
		
		inputs[|  4].setVisible( _pat == 0 || _pat == 1);
		inputs[|  7].setVisible( _pat == 2);
		inputs[|  8].setVisible( _pat == 2);
		inputs[| 18].setVisible( _pat == 1);
		inputs[| 19].setVisible( _pat == 1);
		inputs[| 26].setVisible( _pat == 0);
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[| 0].setValue(_outSurf);
		
		var runx, runy, posx, posy, scax, scay, rot;
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
			runx = 0;
			runy = 0;
			
			for( var i = 0; i < _amo; i++ ) {
				posx = runx;
				posy = runy;
				
				if(_pat == 0) {
					if(_path == noone || !variable_struct_exists(_path, "getPointRatio")) {
						posx += _spos[0] + _rpos[0] * i;
						posy += _spos[1] + _rpos[1] * i;
					} else {
						var rat = _prsh + _prng[0] + (_prng[1] - _prng[0]) * i / (_amo - 1);
						rat = abs(frac(rat));
						
						var _p = _path.getPointRatio(rat);
						posx = _p[0];
						posy = _p[1];
					}
				} else if(_pat == 1) {
					var row = floor(i / _col);
					var col = i % _col;
					
					posx = _spos[0] + _rpos[0] * col + _cls[0] * row;
					posy = _spos[1] + _rpos[1] * col + _cls[1] * row;
				} else if(_pat == 2) {
					var aa = _aran[0] + (_aran[1] - _aran[0]) * i / _amo;
					posx = _spos[0] + lengthdir_x(_arad, aa);
					posy = _spos[1] + lengthdir_y(_arad, aa);
				}
				
				scax = eval_curve_bezier_cubic_x(_msca, i / (_amo - 1)) * _rsca;
				scay = scax;
				rot = _rrot[0] + (_rrot[1] - _rrot[0]) * i / (_amo - 1);
				
				var _an_dist = abs(i - _an_mid * (_amo - 1));
				if(_an_dist < _an_ran * _amo) {
					var _inf = eval_curve_bezier_cubic_x(_an_fal, _an_dist / (_an_ran * _amo));
					posx += _an_pos[0] * _inf;
					posy += _an_pos[1] * _inf;
					rot  += _an_rot    * _inf;
					scax += _an_sca[0] * _inf;
					scay += _an_sca[1] * _inf;
				}
				
				var _surf = _inSurf;
				
				if(is_array(_surf)) 
					_surf = array_safe_get(_inSurf, _arr? irandom(array_length(_inSurf) - 1) : i % array_length(_inSurf));
				
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				var sw = _sw * scax;
				var sh = _sh * scay;
				
				if(i) {
					if(_rsta == 1) { 
						runx += _sw / 2;
						posx += _sw / 2;
					}
					if(_rsta == 2) { 
						runy += _sh / 2;
						posy += _sh / 2;
					}
				}
				
				var pos = point_rotate(-sw / 2, -sh / 2, 0, 0, rot);
				var cc  = gradient_eval(_grad, i / (_amo - 1), ds_list_get(_grad_data, 0));
				var aa  = eval_curve_bezier_cubic_x(_alph, i / (_amo - 1));
				
				draw_surface_ext_safe(_surf, posx + pos[0], posy + pos[1], scax, scay, rot, cc, aa);
				
				if(_rsta == 1)	runx += _sw / 2;
				if(_rsta == 2)	runy += _sh / 2;
			}
		surface_reset_target();
	}
}