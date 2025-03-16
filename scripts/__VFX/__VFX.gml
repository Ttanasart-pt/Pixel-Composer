enum ANIM_END_ACTION {
	loop,
	pingpong,
	destroy,
}

enum PARTICLE_BLEND_MODE {
	normal,
	alpha,
	additive,
	maximum,
	minimum,
}

enum PARTICLE_RENDER_TYPE {	
	surface,
	line,
}

function __particleObject() constructor {
	active  = false;
	
	x   = 0;
	y   = 0;
	rot	= 0;
	scx = 1;
	scy = 1;
	
	x_history = [];
	y_history = [];
	
	surf  = noone;
	blend = c_white;
	alp   = 1;
	
	static kill = function() {}
	
	static step = function() {}
	
	__temp_pt = [ 0, 0 ];
	static draw = function(exact, surf_w = 1, surf_h = 1) {
		if(!is_surface(surf)) {
			draw_point_color(x, y, blend);
			return;
		}
		
		var _sw = surface_get_width(surf)  * scx;
		var _sh = surface_get_height(surf) * scy;
		
		point_rotate(-_sw / 2, -_sh / 2, 0, 0, rot, __temp_pt);
		draw_surface_ext(surf, x + __temp_pt[0], y + __temp_pt[1], scx, scy, rot, blend, alp);
	}
	
	static clone = function() {
		var _p = new __particleObject();
		struct_override(_p, self);
		return _p;
	}
}

function __part(_node) : __particleObject() constructor {
	
	seed    = irandom(99999);
	node    = _node;
	
	////- Lifes
	
	life       = 0;
	life_total = 0;
	life_incr  = 0;
	step_int   = 0;
	
	////-  Transforms
	
	startx  = 0; starty  = 0;
	prevx   = 0; prevy   = 0;
	speedx  = 0; speedy  = 0;
	
	turning = 0;
	turnSpd = 0;
	
	frict   = 0;
	accel   = 0;
	spVec   = [ 0, 0 ];
	
	grav    = 0;
	gravDir = -90;
	gravX   = 0; gravY   = 0;
	
	sc_sx = 1; sc_sy = 1;
	sct   = noone;
	
	scx_history = [];
	scy_history = [];
	
	follow 	 = false;
	rot_base = 0;
	rot_s	 = 0;
	
	path      = noone;
	pathIndex = 0;
	pathPos   = new __vec2();
	pathDiv   = noone;
	
	////- Render
	
	render_type = PARTICLE_RENDER_TYPE.surface;
	
	arr_type = 0;
	
	drawx   = 0; drawy   = 0;
	drawsx  = 0; drawsy  = 0;
	drawrot = 0;
	
	col       = -1;
	alp_draw  = alp;
	alp_fade  = 0;
	currColor = c_white;
	
	blend_history = [];
	alp_history   = [];
	
	anim_speed = 1;
	anim_end   = ANIM_END_ACTION.loop;
	anim_stre  = false;
	anim_len   = 1;
	
	line_draw = 1;
	
	////- Physics
	
	ground			= false;
	ground_y		= 0;
	ground_bounce	= 0;
	ground_friction = 1;
	
	trailLife   = 0;
	trailActive = false;
	
	frame  = 0;
	params = {};
	
	use_phy = false;
	use_wig = false;
	
	////- Wiggles
	
	use_wig = false;
	wig_psx = noone;
	wig_psy = noone;
	wig_rot = noone;
	wig_scx = noone;
	wig_scy = noone;
	wig_dir = noone;
	
	static reset = function() {
		INLINE
		
		surf   = noone;
		prevx  = undefined;
		prevy  = undefined;
	}
	
	static create = function(_surf, _x, _y, _life) {
		INLINE
		
		active = true;
		surf   = _surf;
		x	   = _x;
		y	   = _y;
		startx = _x; 
		starty = _y;
		
		drawx  = undefined;
		drawy  = undefined;
		
		anim_len = is_array(surf)? array_length(surf) : 1;
		
		life_incr  = 0;
		life_total = _life;
		life       = _life;
		
		if(node.onPartCreate != noone) node.onPartCreate(self);
		
		trailLife     = 0;
		x_history     = array_create(life);
		y_history     = array_create(life);
		scx_history   = array_create(life);
		scy_history   = array_create(life);
		blend_history = array_create(life);
		alp_history   = array_create(life);
	}
	
	static setPhysic = function(_use_phy, _sx, _sy, _ac, _fr, _g, _gDir, _turn, _turnSpd) {
		INLINE
		
		use_phy = _use_phy;
		speedx  = _sx;
		speedy  = _sy;
		accel   = _ac;
		frict   = _fr;
		grav    = _g;
		gravDir = _gDir;
		gravX   = lengthdir_x(grav, gravDir);
		gravY   = lengthdir_y(grav, gravDir);
		
		turning = _turn;
		turnSpd = _turnSpd;
	
		spVec[0] = point_distance(0, 0, speedx, speedy);
		spVec[1] = point_direction(0, 0, speedx, speedy);
	}
	
	static setWiggle = function(_use_wig, wiggle_maps) {
		INLINE
		
		use_wig = _use_wig;
		wig_psx = wiggle_maps.wig_psx;
		wig_psy = wiggle_maps.wig_psy;
		wig_rot = wiggle_maps.wig_rot;
		wig_scx = wiggle_maps.wig_scx;
		wig_scy = wiggle_maps.wig_scy;
		wig_dir = wiggle_maps.wig_dir;
	}
	
	static setGround = function(_ground, _ground_offset, _ground_bounce, _ground_frict) {
		INLINE
		
		ground			= _ground;
		ground_y		= y + _ground_offset;
		ground_bounce	= _ground_bounce;
		ground_friction	= clamp(1 - _ground_frict, 0, 1);
	}
	
	static setTransform = function(_scx, _scy, _sct, _rot, _rots, _follow) {
		INLINE
		
		sc_sx = _scx;
		sc_sy = _scy;
		sct   = _sct;
		
		rot_base = _rot;
		rot      = _rot;
		rot_s    = _rots;
		follow   = _follow;
	}
	
	static setDraw = function(_col, _blend, _alp, _fade) {
		INLINE
		
		col      = _col;
		blend	 = _blend;
		alp      = _alp;
		alp_draw = _alp;
		alp_fade = _fade;
	}
	
	static setPath = function(_path, _pathDiv) {
		INLINE
		
		path    = _path;
		pathDiv = _pathDiv;
	}
	
	static kill = function(callDestroy = true) {
		INLINE
		
		active = false;
		if(callDestroy && node.onPartDestroy != noone)
			node.onPartDestroy(self);
	}
	
	static step = function(_frame = 0) {
		INLINE
		trailLife++;
		
		if(!active) return;
		x += speedx;
		frame = _frame;
		
		var lifeRat = 1 - life / life_total;
		
		random_set_seed(seed + life);
		
		#region ground
			if(ground && y + speedy > ground_y) {
				y = ground_y;
				speedy = -speedy * ground_bounce;
				
				if(abs(speedy) < 0.1)
					speedx *= ground_friction;
			} else
				y += speedy;
		#endregion
		
		#region physics
			var dirr = point_direction(0, 0, speedx, speedy);
			var diss = point_distance(0, 0, speedx, speedy);
			
			if(use_phy) diss = max(0, diss + accel) * (1 - frict);
			
			if(speedx != 0 || speedy != 0) {
				if(use_wig) dirr += wig_dir.get(seed + life);
				
				if(use_phy && turning != 0) {
					var trn = turning;
					
					     if(turnSpd > 0) trn = turning * diss * turnSpd;
					else if(turnSpd < 0) trn = turning / diss * turnSpd;
					
					dirr += trn
				}
			}
			
			speedx = lengthdir_x(diss, dirr);
			speedy = lengthdir_y(diss, dirr);
			
			if(use_phy) {
				speedx += gravX;
				speedy += gravY;
			}
		#endregion
		
		#region rotation
			rot_base += rot_s;
			
			if(follow)  rot = spVec[1] + rot_base;
			else        rot = rot_base;
		#endregion
		
		if(node.onPartStep != noone && step_int > 0 && safe_mod(life, step_int) == 0) 
			node.onPartStep(self);
		
		if(life-- < 0) kill();
		
		if(prevx != undefined) {
			spVec[0] = point_distance(prevx, prevy, x, y);
			if(spVec[0] > 1)
				spVec[1] = point_direction(prevx, prevy, x, y);
		}
		
		if(drawx != undefined) {
			x_history[life_incr] = drawx;
			y_history[life_incr] = drawy;
			life_incr++;
		}
		
		prevx = x;
		prevy = y;
		
		drawx   = x;
		drawy   = y;
		drawrot = rot;
		drawsx  = sc_sx;
		drawsy  = sc_sy;
		
		if(use_wig) {
			drawx   += wig_psx.get(seed + life);
			drawy   += wig_psy.get(seed + life);
			drawrot += wig_rot.get(seed + life);
			drawsx  += wig_scy.get(seed + life);
			drawsy  += wig_scy.get(seed + life);
		}
		
		if(path != noone) {
			var _lifeRat = clamp(lifeRat, 0., 1.);
			var _pathDiv = pathDiv.get(_lifeRat);
			
			pathPos = path.getPointRatio(clamp(_lifeRat, 0, 0.99), pathIndex, pathPos);
			drawx   = pathPos.x + drawx * _pathDiv;
			drawy   = pathPos.y + drawy * _pathDiv;
		}
	
		#region color
			var cc = (col == -1)? c_white : col.eval(lifeRat);
			if(blend != c_white) cc = colorMultiply(blend, cc);
			alp_draw = alp * (alp_fade == noone? 1 : alp_fade.get(lifeRat)) * _color_get_alpha(cc);
			
			if(life_incr) {
				blend_history[life_incr - 1] = cc;
				alp_history[life_incr - 1]   = alp_draw;
			}
			
			currColor = cola(cc, alp_draw);
		#endregion
	}
	
	static setDrawParameter = function() {
		drawx   = x;
		drawy   = y;
		drawrot = rot;
		drawsx  = sc_sx;
		drawsy  = sc_sy;
	}
	
	static draw = function(exact, surf_w = 1, surf_h = 1) {
		INLINE
		
		if(render_type == PARTICLE_RENDER_TYPE.line) {
			var _trail_ed  = min(life_incr, life_total);
			var _trail_st  = max(0, trailLife - line_draw);
			var _trail_len = _trail_ed - _trail_st;
				
			if(_trail_len <= 0) return;
		}
		
		var ss = surf;
		
		var lifeRat = 1 - life / life_total;
		var scCurve = sct == noone? 1 : sct.get(lifeRat);
		scx = drawsx * scCurve;
		scy = drawsy * scCurve;
		
		if(arr_type == 2 && surf != noone && is_array(surf)) {
			var _life_prog = life_total - life;
			var ind = anim_stre? _life_prog / life_total * anim_speed * (anim_len - 1) :
			                     _life_prog * anim_speed;
			ind = abs(round(ind));
			
			switch(anim_end) {
				case ANIM_END_ACTION.loop: 
					ss = surf[safe_mod(ind, anim_len)];
					break;
					
				case ANIM_END_ACTION.pingpong:
					var ping = safe_mod(ind, (anim_len - 1) * 2 + 1); 
					ss = surf[ping >= anim_len? (anim_len - 1) * 2 - ping : ping];
					break;
					
				case ANIM_END_ACTION.destroy:
					if(ind >= anim_len) {
						kill();
						return;
					}
					
					ss = surf[ind];
					break;
			}
		} else if(arr_type == 3) {
			var _sca = round(min(scx, scy));
			ss = array_safe_get_fast(surf, clamp(_sca, 0, array_length(surf) - 1));
		}
		
		var _surf = node.surface_cache[$ ss];
		var _useS = is_surface(_surf);
		
		if(arr_type == 3) {
			scx = 1;
			scy = 1;
		}
		
		if(life_incr) {
			scx_history[life_incr - 1] = scx;
			scy_history[life_incr - 1] = scy;
		}
		
		var _xx = drawx;
		var _yy = drawy;
		
		if(exact) {
			_xx = round(_xx);
			_yy = round(_yy);
		}
		
		var s_w = (_useS? surface_get_width_safe(_surf)  : 1) * scx;
		var s_h = (_useS? surface_get_height_safe(_surf) : 1) * scy;
		var _pp = point_rotate(-s_w / 2, -s_h / 2, 0, 0, rot);
		_xx += _pp[0];
		_yy += _pp[1];
		
		var x0 = _xx - s_w * 1.5;
		var y0 = _yy - s_h * 1.5;
		var x1 = _xx + s_w * 1.5;
		var y1 = _yy + s_h * 1.5;
		
		if(_useS && (x0 > surf_w || y0 > surf_h || x1 < 0 || y1 < 0))
			return;
		
		switch(render_type) {
			case PARTICLE_RENDER_TYPE.surface : 
				if(surface_exists(_surf)) 
					draw_surface_ext_safe(_surf, _xx, _yy, scx, scy, drawrot, currColor, alp_draw);
				else {
					var ss = round(min(scx, scy));
					if(round(ss) == 0) return;
					
					_xx = drawx
					_yy = drawy;
					
					if(exact) { 
						_xx = round(_xx); 
						_yy = round(_yy);
						 ss = round( ss); 
					}
					
					var _s = shader_current();
					shader_reset();
						if(is(_surf, dynaSurf)) {
							for( var i = 0, n = array_length(_surf.parameters); i < n; i++ ) {
								var _param = _surf.parameters[i]
								var _parcv = params[$ _param];
								if(_parcv == undefined) continue;
								
								_surf.params[$ _param] = _parcv.get(lifeRat) * _surf[$ _param];
							}
							
							_surf.draw(_xx, _yy, ss, ss, drawrot, currColor, alp_draw);
						} else DYNADRAW_DEFAULT.draw(_xx, _yy, ss, ss, 0, currColor, alp_draw);
					shader_set(_s);
				}
				break;
				
			case PARTICLE_RENDER_TYPE.line : 
				var  _ox,  _nx,  _oy,  _ny;
				var _osx, _nsx, _osy, _nsy;
				var  _oc,  _nc,  _oa,  _na;
				
				for( var j = 0; j < _trail_len; j++ ) {
					var _index = _trail_st + j;
					
					_nx  = x_history[    _index];
					_ny  = y_history[    _index];
					_nsx = scx_history[  _index];
					_nsy = scy_history[  _index];
					_nc  = blend_history[_index];
					_na  = alp_history[  _index];
					
					if(j) {
						draw_set_color(_nc);
						draw_set_alpha(_na);
						if(_osx == 1 && _nsx == 1) draw_line(_ox, _oy, _nx, _ny);
						else if(_osx == _nsx)      draw_line_width(_ox, _oy, _nx, _ny, _osx);
						else                       draw_line_width2(_ox, _oy, _nx, _ny, _osx, _nsx, false);
						draw_set_alpha(1);
					}
					
					_ox  = _nx ;
					_oy  = _ny ;
					_osx = _nsx;
					_osy = _nsy;
					_oc  = _nc ;
					_oa  = _na ;
				}
				
				break;
		}
	}
	
	static getPivot = function() {
		INLINE
		return [x, y];
	}
		
	static clone = function() {
		var _p = new __part(node);
		struct_override(_p, self);
		return _p;
	}

	static set = function(_part) {
		var _keys = struct_get_names(self);
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			if(is_struct(self[$ _keys[i]])) {
				self[$ _keys[i]] = _part[$ _keys[i]];
				continue;
			}
			
			self[$ _keys[i]] = variable_clone(_part[$ _keys[i]]);
		}
		
		return self;
	}

	static toString = function() { return $"[particle]: pos = ({x}, {y})" }
}

#region helper
	#macro UPDATE_PART_FORWARD static updateParticleForward = function() {		\
		var pt = outputs[0];													\
		for( var i = 0; i < array_length(pt.value_to); i++ ) {					\
			var _n = pt.value_to[i];											\
			if(_n.value_from != pt) continue;									\
																				\
			if(variable_struct_exists(_n.node, "updateParticleForward"))		\
				_n.node.updateParticleForward();								\
		}																		\
	}
#endregion