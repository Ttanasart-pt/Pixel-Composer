function Node_MK_GridFlip(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK GridFlip";
	
	newInput(0, nodeValue_Surface("Surface front"));
	
	newInput(1, nodeValue_Dimension());
	
	newInput(2, nodeValue_Vec2("Amount", [ 4, 4 ]));
		
	newInput(3, nodeValueSeed());
	
	newInput(4, nodeValue_Surface("Surface back"));
	
	newInput(5, nodeValue_Rotation("Rotation", 0));
	
	newInput(6, nodeValue_Enum_Button("Axis",  0, [ "X", "Y" ]));
	
	newInput(7, nodeValue_Float("Sweep", 0));
	
	newInput(8, nodeValue_Rotation("Sweep direction", 0));
		
	newInput(9, nodeValue_Slider("Sweep shift", 0, [ -1, 1, 0.01 ] ));
	
	newInput(10, nodeValue_Enum_Scroll("Flip limit",  0, [ new scrollItem("None", s_node_mk_grid_flip, 0), 
												                 new scrollItem("90",   s_node_mk_grid_flip, 1), 
												                 new scrollItem("180",  s_node_mk_grid_flip, 2), ]));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 3, 1, 
		["Surface",		 true], 0, 4, 
		["Grid",		false], 2,
		["Flip",		false], 6, 10, 5, 7, 8, 9, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	dimension_index = 1;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _dim  = _data[1];
		var _bamo = _data[2];
		var _seed = _data[3];
		var _srfB = _data[4];
		var _flip = _data[5];
		var _axis = _data[6];
		
		var _swp     = _data[7];
		var _swp_dir = _data[8];
		var _swp_shf = _data[9];
		
		var _limt = _data[10];
		
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
		
		var _flpw = _sw * _icol;
		var _flph = _sh * _irow;
		
		var _cx = _sw / 2;
		var _cy = _sh / 2;
		var _cd = sqrt(_cx * _cx + _cy * _cy);
		_swp_shf *= _cd;
		
		var _strh_dx = lengthdir_x(1, _swp_dir);
		var _strh_dy = lengthdir_y(1, _swp_dir);
		
		surface_set_shader(_outSurf, sh_mk_flipGrid);
			shader_set_surface("texture",     _surf);
			shader_set_surface("textureBack", _srfB);
			shader_set_i("hasBack",   is_surface(_srfB));
			shader_set_f("dimension", _dim);
			
			for( var i = 0; i < _amo; i++ ) {
				var _c = i % _col;
				var _r = floor(i * _icol);
				
				var _flxc = (_c + 0.5) * _flpw;
				var _flyc = (_r + 0.5) * _flph;
				
				var _cdist = point_distance(_cx, _cy, _flxc, _flyc);
				var _fRot  = _flip;
				
				if(_swp != 0) {
					var _cdirr  = _swp_dir + 90 - point_direction(_cx, _cy, _flxc, _flyc);
					var _st_prg = _cdist * dsin(_cdirr) + _swp_shf;
					
					_fRot += max(0, _st_prg * _swp);
				}
				
				     if(_limt == 1) _fRot = clamp(_fRot,  -90,  90);
				else if(_limt == 2) _fRot = clamp(_fRot, -180, 180);
				
				var _fw   = _flpw / 2 * ((_axis == 1)? dcos(_fRot) : 1);
				var _fh   = _flph / 2 * ((_axis == 0)? dcos(_fRot) : 1);
				
				var _flx = _c * _flpw;
				var _fly = _r * _flph;
				
				var _flx0 = _flxc - _fw;
				var _flx1 = _flxc + _fw;
				var _fly0 = _flyc - _fh;
				var _fly1 = _flyc + _fh;
				
				var _rRot = _fRot < 0? 360 - abs(_fRot) % 360 : _fRot;
				var _f = floor(_rRot / 90) % 4;
				
				shader_set_f("flipPos",     _flx0,   _fly0);
				shader_set_f("flipSize",    _fw * 2, _fh * 2);
				
				shader_set_f("fr_flipPos",  _flx,  _fly);
				shader_set_f("fr_flipSize", _flpw, _flph);
				
				shader_set_i("axis", _axis);
				shader_set_i("flip", _f == 1 || _f == 2);
				
				var _x0 = min(_flx0, _flx1);
				var _x1 = max(_flx0, _flx1);
				var _y0 = min(_fly0, _fly1);
				var _y1 = max(_fly0, _fly1);
				
				draw_rectangle(_x0, _y0, _x1, _y1, false);
			}
		surface_reset_shader();
		
		return _outSurf;
	}
}