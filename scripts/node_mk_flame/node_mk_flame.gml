function Node_MK_Flame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Flame";
	update_on_frame = true;
	
	newInput( 0, nodeValue_Dimension());
	newInput( 2, nodeValueSeed());
	
	////- =Shape
	newInput( 1, nodeValue_Rotation("Direction", 45));
	
	// 3
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ s_MKFX, 0, 2, 
		[ "Shape",	false ], 
	];
	
	////- Node
	
	temp_surface = [ noone, noone ];
	
	static update = function(_frame = CURRENT_FRAME) { 
		#region data 
			var _dim  = getInputData(0);
			var _seed = getInputData(2);
			
			var _spawn = [0,0];
			var _amoun = 3;
			
			var _orig  = [_dim[0] / 2, _dim[1] / 2];
			var _area  = [0,0];
			var _radd  = [2,6];
			
			var _life  = [6,9];
			
			var _group    = [6,9];
			var _groupAng = 15;
			var _groupSpd = .4;
			
			var _size      = [6,10];
			var _cres_offs = [4,6];
			
			var _speed = [.2, .6];
			var _dirr  = ROTATION_RANDOM_DEF_0_360;
			
			var _persp = [2,2];
			
			var _center = [_dim[0] / 2, _dim[1] / 2];
			var _center = [_dim[0] / 3, _dim[1] / 3];
			random_set_seed(_seed);
		#endregion
		
		var _outSurf = surface_verify(outputs[0].getValue(), _dim[0], _dim[1]);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_rgba16float);
		
		var _layers = [];
		for( var a = 0; a < _amoun; a++ ) {
			var _prg = a / (_amoun - 1);
			
			var _spd = random_range(_speed[0], _speed[1]);
			var _dir = rotation_random_eval(_dirr);
			
			var _lifeT = irandom_range(_life[0],  _life[1]);
			var _spFrm = irandom_range(_spawn[0], _spawn[1]);
			var _gro   = irandom_range(_group[0], _group[1]);
			var _siz   = irandom_range(_size[0],  _size[1]);
			
			var _lifeT = lerp(_life[1],  _life[0],  _prg);
			var _rad   = lerp(_radd[1],  _radd[0],  _prg);
			var _spd   = lerp(_speed[1], _speed[0], _prg);
			var _gro   = lerp(_group[1], _group[0], _prg);
			var _siz   = lerp(_size[1],  _size[0],  _prg);
			
			var _pers  = lerp(_persp[0], _persp[1],  _prg);
			
			var _grAng = 360 / _gro;
			var _grAsp = _groupAng / _gro;
			var _flames = [];
				
			for( var g = 0; g < _gro; g++ ) {
				var _ele = new MKFlame_Ball();
				var pDir = _dir + g * _grAng + random_range(-_grAsp, _grAsp);
				
				var ox = _orig[0] + random_range(-_area[0], _area[0]) + lengthdir_x(_rad, pDir);
				var oy = _orig[1] + random_range(-_area[1], _area[1]) + lengthdir_y(_rad, pDir);
				
				_ele.origin    = _center;
				_ele.originDim = _dim;
				
				_ele.sx = ox;
				_ele.sy = oy;
				
				_ele.life      = _frame - _spFrm;
				_ele.lifeTotal = _lifeT;
				
				_ele.speed     = _spd + random_range(-_groupSpd, _groupSpd);
				_ele.direction = pDir;
				
				_ele.size[0]   = _siz / 2;
				_ele.size[1]   = _siz;
				_ele.cresent_offset = random_range(_cres_offs[0], _cres_offs[1]);
				
				_ele.perspective = _pers;
				
				_ele.step();
				
				array_push(_flames, _ele);
			}
			
			array_push(_layers, _flames);
		}
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR
			
			for( var i = 0, n = array_length(_layers); i < n; i++ ) {
				var _flames = _layers[i];
				
				surface_set_target(temp_surface[0]);
				DRAW_CLEAR
				draw_clear_alpha(c_white, 0);
				for( var j = 0, m = array_length(_flames); j < m; j++ )
					_flames[j].draw();
				surface_reset_target();
				
				draw_surface(temp_surface[0], 0, 0);
			}
			
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			shader_set(sh_mk_flame_remove_black);
				draw_surface(temp_surface[1], 0, 0);
			shader_reset();
		surface_reset_target();
		
		outputs[0].setValue(_outSurf);
	} 
}

function MKFlame_Element() constructor {
	x = 0; sx = 0;
	y = 0; sy = 0;
	
	life      = 0;
	lifeTotal = 0;
	
	color  = c_white;
	size   = [0,8];
	angle  = 0;
	
	speed     = 0;
	direction = 0;
	
	origin    = [0,0];
	originDim = [1,1];
	perspective = 2.;
	__p = [0,0];
	
	static step = function() {}
	static draw = function(_x = 0, _y = 0, _r = 0, _s = 1) {}
}

function MKFlame_Ball() : MKFlame_Element() constructor {
	radius    = 0;
	radius_in = 0;
	rotaDir   = choose(-1, 1);
	
	normal    = [0,0];
	cresent_offset = 6;
	
	static step = function() {
		radius    = lerp(size[0], size[1], clamp(life / lifeTotal, 0, 1));
		radius_in = max(0, (life - cresent_offset) / lifeTotal) * .4;
		
		angle = life * 30 * rotaDir;
		angle = direction;
		
		x = sx + lengthdir_x(speed * life, direction);
		y = sy + lengthdir_y(speed * life, direction);
	}
	
	static draw = function(_x = 0, _y = 0, _r = 0, _s = 1) {
		var ro = radius * _s;
		if(life < 0 || ro <= 0) return;
		
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		normal[0] = (x - origin[0]) / originDim[0] * perspective;
		normal[1] = (y - origin[1]) / originDim[1] * perspective;
		
		BLEND_MIN
		shader_set(sh_mk_flame_ball);
			shader_set_f("innerRad", radius_in);
			shader_set_2("origin",   normal);
			
			draw_sprite_ext(s_fx_pixel2, 0, xx, yy, ro, ro);
		shader_reset();
		BLEND_NORMAL
	}
}
