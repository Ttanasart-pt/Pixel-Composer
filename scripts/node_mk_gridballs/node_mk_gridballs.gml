function Node_MK_GridBalls(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK GridBalls";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Dimension(self);
	
	inputs[| 2] = nodeValue_Vector("Amount", self, [ 4, 4 ]);
	
	inputs[| 3] = nodeValue_Rotation("Light", self, 0);
	
	inputs[| 4] = nodeValue_Float("Scatter", self, 0);
	
	inputs[| 5] = nodeValue_Int("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		
	inputs[| 6] = nodeValue_Float("Shading", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 7] = nodeValue_Rotation("Scatter direction", self, 0);
		
	inputs[| 8] = nodeValue_Vector("Shift", self, [ 0, 0 ]);
	
	inputs[| 9] = nodeValue_Float("Stretch", self, 0);
	
	inputs[| 10] = nodeValue_Rotation("Stretch direction", self, 0);
		
	inputs[| 11] = nodeValue_Float("Stretch shift", self, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 12] = nodeValue_Float("Roundness", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 13] = nodeValue_Float("Twist", self, 0);
	
	inputs[| 14] = nodeValue_Rotation("Twist axis", self, 0);
		
	inputs[| 15] = nodeValue_Float("Twist shift", self, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 5, 1, 
		["Surface",		 true], 0,
		["Grid",		false], 2,
		["Movement",	false], 8, 4, 7, 9, 10, 11, 13, 14, 15, 
		["Render",		false], 12, 3, 6, 
	];
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	dimension_index = 1;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 8].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _dim  = _data[1];
		var _bamo = _data[2];
		var _ldir = _data[3];
		var _scat = _data[4];
		var _seed = _data[5];
		var _shad = _data[6];
		var _rota = _data[7];
		var _posi = _data[8];
		
		var _strh     = _data[ 9];
		var _strh_dir = _data[10];
		var _strh_shf = _data[11];
		var _rond     = _data[12];
		
		var _twst     = _data[13];
		var _twst_axs = _data[14];
		var _twst_shf = _data[15];
		
		if(!is_surface(_surf)) return _outSurf;
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		random_set_seed(_seed);
		
		var _sw  = _dim[0];
		var _sh  = _dim[1];
		var _col = _bamo[0];
		var _row = _bamo[1];
		var _amo = _row * _col;
		
		var _irow = 1 / _row;
		var _icol = 1 / _col;
		
		var _grw = _sw * _icol;
		var _grh = _sh * _irow;
		var _rad = min(_grw, _grh) / 2;
		
		var _light = [ lengthdir_x(1, _ldir), lengthdir_y(1, _ldir), 1 ];
		
		var _cx = _sw / 2;
		var _cy = _sh / 2;
		var _cd = sqrt(_cx * _cx + _cy * _cy);
		_strh_shf *= _cd;
		
		var _strh_dx = lengthdir_x(1, _strh_dir);
		var _strh_dy = lengthdir_y(1, _strh_dir);
		
		var _twst_dx = lengthdir_x(1, _twst_axs - 90);
		var _twst_dy = lengthdir_y(1, _twst_axs - 90);
		
		var _rnd_rad = _rad * _rond * 2;
		
		surface_set_shader(_outSurf, sh_mk_ballGrid);
			shader_set_surface("texture", _surf);
			shader_set_f("lightPos", _light);
			shader_set_f("lightInt", _shad);
			shader_set_f("dimension", _dim);
			
			for( var i = 0; i < _amo; i++ ) {
				var _c = i % _col;
				var _r = floor(i * _icol);
				
				var _smpw = _c * _icol;
				var _smph = _r * _irow;
				
				var _bx = (_c + 0.5) * _grw - 1;
				var _by = (_r + 0.5) * _grh - 1;
				
				var bx = _posi[0] + _bx;
				var by = _posi[1] + _by;
				
				var _cdist = point_distance(_cx, _cy, _bx, _by);
				
				if(_twst != 0) { #region
					var _cdirr = _twst_axs - point_direction(_cx, _cy, _bx, _by);
					
					var _st_prg = _cdist * dsin(_cdirr);
					var _ax_prg = _cdist * (dcos(_cdirr));
					var _tw_prg = 90 + _ax_prg * _twst + _twst_shf * 360;
					
					bx = (_bx - _twst_dx * _st_prg) + _twst_dx * _st_prg * dsin(_tw_prg);
					by = (_by - _twst_dy * _st_prg) + _twst_dy * _st_prg * dsin(_tw_prg);
				} #endregion
				
				if(_strh != 0) { #region
					var _cdirr  = _strh_dir + 90 - point_direction(_cx, _cy, _bx, _by);
					var _st_prg = _cdist * dsin(_cdirr) + _strh_shf;
					var _st_str = max(0, _st_prg * _strh);
					
					bx += _strh_dx * _st_str;
					by += _strh_dy * _st_str;
				} #endregion
				
				if(_scat != 0) { #region
					var _dir = random_range(0, 360) + _rota;
					var _dis = random_range(0.1, 1);
					
					bx += lengthdir_x(_dis, _dir) * _scat;
					by += lengthdir_y(_dis, _dir) * _scat;
				} #endregion
				
				var _br = _rad;
				
				shader_set_f("ballPos",    bx + 1,  by + 1);
				shader_set_f("ballRad",   _br);
				shader_set_f("ballShift", 0, 0, 0);
				
				shader_set_f("samplePos", _smpw, _smph);
				
				if(_rond == 1) draw_circle(bx, by, _br, false);
				else		   draw_roundrect_ext(bx - _br, by - _br, bx + _br, by + _br, _rnd_rad, _rnd_rad, false);
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}