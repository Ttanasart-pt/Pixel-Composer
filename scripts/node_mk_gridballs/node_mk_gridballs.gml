function Node_MK_GridBalls(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK GridBalls";
	dimension_index = 1;
	
	newInput( 5, nodeValueSeed());
	newInput( 1, nodeValue_Dimension());
	
	////- =Surface
	newInput( 0, nodeValue_Surface(  "Surface In" ));
	
	////- =Grid
	newInput( 2, nodeValue_Vec2(     "Amount",     [4,4]  ));
	newInput( 8, nodeValue_Vec2(     "Position",   [0,0]  )).setUnitSimple();
	newInput(19, nodeValue_Float(    "Ball Size",   1     )).setMappable(32);
	
	////- =Scatter
	newInput(16, nodeValue_Bool(     "Scatter Use", false ));
	newInput( 4, nodeValue_Float(    "Amount",      0     )).setMappable(21);
	newInput( 7, nodeValue_Rotation( "Phase",       0     ));
	
	////- =Stretch
	newInput(17, nodeValue_Bool(     "Stretch Use", false ));
	newInput( 9, nodeValue_Float(    "Amount",      0     )).setMappable(22);
	newInput(10, nodeValue_Rotation( "Selection",   0     )).setMappable(23);
	newInput(20, nodeValue_Rotation( "Direction",   0     )).setMappable(24);
	newInput(11, nodeValue_Slider(   "Shift",       0, [ -1, 2, 0.01 ] )).setMappable(25);
	
	////- =Twist
	newInput(18, nodeValue_Bool(     "Twist Use",   false ));
	newInput(13, nodeValue_Float(    "Amount",      0     )).setMappable(26);
	newInput(14, nodeValue_Rotation( "Axis",        0     )).setMappable(27);
	newInput(15, nodeValue_Slider(   "Shift",       0, [ -1, 1, 0.01 ] )).setMappable(28);
	
	////- =Render
	newInput(12, nodeValue_Slider(   "Roundness",   1     )).setMappable(29);
	newInput( 3, nodeValue_Rotation( "Light",       0     )).setMappable(30);
	newInput(33, nodeValue_Slider(   "Light Height",1     )).setMappable(34);
	newInput( 6, nodeValue_Slider(   "Shading",    .5     )).setMappable(31);
	// input 35
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 5, 1, 
		[ "Surface",   true     ],  0,
		[ "Grid",     false     ],  2,  8, 19, 32, 
		[ "Scatter",  false, 16 ],  4, 21,  7, 
		[ "Stretch",  false, 17 ],  9, 22, 10, 23, 20, 24, 11, 25, 
		[ "Twist",    false, 18 ], 13, 26, 14, 27, 15, 28, 
		[ "Render",   false     ], 12, 29,  3, 30, 33, 34,  6, 31, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed     = _data[ 5];
			var _dim      = _data[ 1];
			
			var _surf     = _data[ 0];
			
			var _bamo     = _data[ 2];
			var _posi     = _data[ 8];
			var _size     = _data[19], _size_samp     = inputs[19].isMapped()? new Surface_Sampler_Grey(_data[32], _size) : undefined;
			
			var _scat_use = _data[16];
			var _scat     = _data[ 4], _scat_samp     = inputs[ 4].isMapped()? new Surface_Sampler_Grey(_data[21], _scat) : undefined;
			var _scat_rot = _data[ 7];
			
			var _strh_use = _data[17];
			var _strh     = _data[ 9], _strh_samp     = inputs[ 9].isMapped()? new Surface_Sampler_Grey(_data[22], _strh     ) : undefined;
			var _strh_dir = _data[10], _strh_dir_samp = inputs[10].isMapped()? new Surface_Sampler_Grey(_data[23], _strh_dir ) : undefined;
			var _strh_mov = _data[20], _strh_mov_samp = inputs[20].isMapped()? new Surface_Sampler_Grey(_data[24], _strh_mov ) : undefined;
			var _strh_shf = _data[11], _strh_shf_samp = inputs[11].isMapped()? new Surface_Sampler_Grey(_data[25], _strh_shf ) : undefined;
			
			var _twst_use = _data[18];
			var _twst     = _data[13], _twst_samp     = inputs[13].isMapped()? new Surface_Sampler_Grey(_data[26], _twst     ) : undefined;
			var _twst_axs = _data[14], _twst_axs_samp = inputs[14].isMapped()? new Surface_Sampler_Grey(_data[27], _twst_axs ) : undefined;
			var _twst_shf = _data[15], _twst_shf_samp = inputs[15].isMapped()? new Surface_Sampler_Grey(_data[28], _twst_shf ) : undefined;
			
			var _rond     = _data[12], _rond_samp     = inputs[12].isMapped()? new Surface_Sampler_Grey(_data[29], _rond ) : undefined;
			var _ldir     = _data[ 3], _ldir_samp     = inputs[ 3].isMapped()? new Surface_Sampler_Grey(_data[30], _ldir ) : undefined;
			var _lhig     = _data[33], _lhig_samp     = inputs[33].isMapped()? new Surface_Sampler_Grey(_data[34], _lhig ) : undefined;
			var _shad     = _data[ 6], _shad_samp     = inputs[ 6].isMapped()? new Surface_Sampler_Grey(_data[31], _shad ) : undefined;
		#endregion
		
		if(!is_surface(_surf)) return _outSurf;
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		random_set_seed(_seed);
		
		var _sw  = _dim[0];
		var _sh  = _dim[1];
		var _col = round(_bamo[0]), _icol = 1 / _col;
		var _row = round(_bamo[1]), _irow = 1 / _row;
		var _amo = _row * _col;
		
		var _grw = _sw * _icol;
		var _grh = _sh * _irow;
		var _rad = min(_grw, _grh) / 2;
		
		var _cx = _sw / 2;
		var _cy = _sh / 2;
		var _cd = sqrt(_cx * _cx + _cy * _cy);
		_strh_shf *= _cd;
		
		draw_set_circle_precision(32);
		surface_set_shader(_outSurf, sh_mk_ballGrid);
			shader_set_surface("texture", _surf);
			shader_set_f("dimension", _dim);
			
			var i = 0, _r = 0, _c = 0;
			
			repeat(_amo) {
				var _smpw = (_c + .5) * _icol;
				var _smph = (_r + .5) * _irow;
				
				var _bx = (_c + .5) * _grw - 1;
				var _by = (_r + .5) * _grh - 1;
				
				var _bu = _smpw;
				var _bv = _smph;
				
				var bx = _posi[0] + _bx;
				var by = _posi[1] + _by;
				var bz = 0;
				
				var _cdist = point_distance(_cx, _cy, _bx, _by);
				var _cdirr = point_direction(_cx, _cy, _bx, _by);
				
				if(_twst_use) {
					var _tw_str = _twst_samp?     _twst_samp.getPixel(_bu, _bv)     : _twst;
					var _tw_axs = _twst_axs_samp? _twst_axs_samp.getPixel(_bu, _bv) : _twst_axs;
					var _tw_shf = _twst_shf_samp? _twst_shf_samp.getPixel(_bu, _bv) : _twst_shf;
					
					var _cdirr  = _tw_axs - _cdirr;
					
					var _st_prg = _cdist * dsin(_cdirr);
					var _ax_prg = _cdist * dcos(_cdirr);
					var _tw_prg = 90 + _ax_prg * _tw_str + _tw_shf * 360;
					var _twr = _st_prg * dsin(_tw_prg);
					var _twd = _st_prg - _twr;
					
					bx -= lengthdir_x(_twd, _tw_axs - 90);
					by -= lengthdir_y(_twd, _tw_axs - 90);
				}
				
				if(_strh_use) {
					var _sh_str = _strh_samp?     _strh_samp.getPixel(_bu, _bv)     : _strh;
					var _sh_dir = _strh_dir_samp? _strh_dir_samp.getPixel(_bu, _bv) : _strh_dir;
					var _sh_mov = _strh_mov_samp? _strh_mov_samp.getPixel(_bu, _bv) : _strh_mov;
					var _sh_shf = _strh_shf_samp? _strh_shf_samp.getPixel(_bu, _bv) : _strh_shf;
					
					var _cdirr  = _sh_dir + 90 - _cdirr;
					var _st_prg = _cdist * dsin(_cdirr) + _sh_shf;
					var _st_str = max(0, _st_prg * _sh_str);
					
					bx += lengthdir_x(_st_str, _sh_mov);
					by += lengthdir_y(_st_str, _sh_mov);
				}
				
				if(_scat_use) {
					var _st_str = _scat_samp?     _scat_samp.getPixel(_bu, _bv)     : _scat;
					
					var _dir = random_range(0, 360) + _scat_rot;
					var _dis = random_range(0.1, 1) * _st_str;
					
					bx += lengthdir_x(_dis, _dir);
					by += lengthdir_y(_dis, _dir);
				}
				
				var __size = _size_samp? _size_samp.getPixel(_bu, _bv) : _size;
				var __rond = _rond_samp? _rond_samp.getPixel(_bu, _bv) : _rond;
				var __ldir = _ldir_samp? _ldir_samp.getPixel(_bu, _bv) : _ldir;
				var __lhig = _lhig_samp? _lhig_samp.getPixel(_bu, _bv) : _lhig;
				var __shad = _shad_samp? _shad_samp.getPixel(_bu, _bv) : _shad;
				
				var _br      = _rad * __size;
				var _rnd_rad = _rad * __rond * 2;
				
				shader_set_f("lightPos", [ lengthdir_x(1, __ldir), lengthdir_y(1, __ldir), __lhig ]);
				shader_set_f("lightInt", __shad);
				
				shader_set_f("ballPos",    bx+1, by+1);
				shader_set_f("ballRad",   _br);
				shader_set_f("ballShift", 0, 0, 0);
				
				shader_set_f("samplePos", _smpw, _smph);
				
				if(__rond == 1) draw_circle(bx, by, _br, false);
				else draw_roundrect_ext(bx - _br, by - _br, bx + _br, by + _br, _rnd_rad, _rnd_rad, false);
				
				i++; _c++;
				if(_c == _col) { _c = 0; _r++; }
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}