enum ANIM_END_ACTION {
	loop,
	pingpong,
	destroy,
}

enum PARTICLE_BLEND_MODE {
	normal,
	alpha,
	additive
}

enum PARTICLE_RENDER_TYPE {	
	surface,
	line,
}

function __part(_node) constructor {
	seed    = irandom(99999);
	node    = _node;
	active  = false;
	
	/////////////////////// Lifespans /////////////////////// 
	life       = 0;
	life_total = 0;
	life_incr  = 0;
	step_int   = 0;
	
	/////////////////////// Transforms /////////////////////// 
	prevx   = 0;
	prevy   = 0;
	x       = 0;
	y       = 0;
	speedx  = 0;
	speedy  = 0;
	turning = 0;
	turnSpd = 0;
	
	x_history = [];
	y_history = [];
	
	accel   = 0;
	spVec   = [ 0, 0 ];
	
	grav    = 0;
	gravDir = -90;
	gravX   = 0;
	gravY   = 0;
	
	scx   = 1;
	scy   = 1;
	sc_sx = 1;
	sc_sy = 1;
	sct   = noone;
	
	scx_history = [];
	scy_history = [];
	
	rot		= 0;
	follow	= false;
	rot_s	= 0;
	
	path      = noone;
	pathIndex = 0;
	pathPos   = new __vec2();
	pathDiv   = noone;
	
	/////////////////////// Render /////////////////////// 
	render_type = PARTICLE_RENDER_TYPE.surface;
	
	surf     = noone;
	arr_type = 0;
	
	drawx   = 0;
	drawy   = 0;
	drawrot = 0;
	drawsx  = 0;
	drawsy  = 0;
	
	col       = -1;
	blend	  = c_white;
	alp       = 1;
	alp_draw  = alp;
	alp_fade  = 0;
	currColor = c_white;
	
	blend_history = [];
	alp_history   = [];
	
	anim_speed = 1;
	anim_end   = ANIM_END_ACTION.loop;
	
	line_draw = 1;
	
	/////////////////////// Physics /////////////////////// 
	ground			= false;
	ground_y		= 0;
	ground_bounce	= 0;
	ground_friction = 1;
	
	trailLife   = 0;
	trailActive = false;
	
	frame = 0;
	
	static reset = function() { #region
		INLINE
		
		surf  = noone;
		
		prevx  = undefined;
		prevy  = undefined;
	} #endregion
	
	static create = function(_surf, _x, _y, _life) { #region
		INLINE
		
		active = true;
		surf   = _surf;
		x	   = _x;
		y	   = _y;
		
		drawx = x;
		drawy = y;
		
		life_incr = 0;
		life = _life;
		life_total = life;
		if(node.onPartCreate != noone) node.onPartCreate(self);
		
		trailLife     = 0;
		x_history     = array_create(life);
		y_history     = array_create(life);
		scx_history   = array_create(life);
		scy_history   = array_create(life);
		blend_history = array_create(life);
		alp_history   = array_create(life);
	} #endregion
	
	static setPhysic = function(_sx, _sy, _ac, _g, _gDir, _turn, _turnSpd) { #region
		INLINE
		
		speedx  = _sx;
		speedy  = _sy;
		accel   = _ac;
		grav    = _g;
		gravDir = _gDir;
		gravX   = lengthdir_x(grav, gravDir);
		gravY   = lengthdir_y(grav, gravDir);
		
		turning = _turn;
		turnSpd = _turnSpd;
	
		spVec[0] = point_distance(0, 0, speedx, speedy);
		spVec[1] = point_direction(0, 0, speedx, speedy);
	} #endregion
	
	static setWiggle = function(wiggle_maps) { #region
		INLINE
		
		wig_psx = wiggle_maps.wig_psx;
		wig_psy = wiggle_maps.wig_psy;
		wig_rot = wiggle_maps.wig_rot;
		wig_scx = wiggle_maps.wig_scx;
		wig_scy = wiggle_maps.wig_scy;
		wig_dir = wiggle_maps.wig_dir;
	} #endregion
	
	static setGround = function(_ground, _ground_offset, _ground_bounce, _ground_frict) { #region
		INLINE
		
		ground			= _ground;
		ground_y		= y + _ground_offset;
		ground_bounce	= _ground_bounce;
		ground_friction	= clamp(1 - _ground_frict, 0, 1);
	} #endregion
	
	static setTransform = function(_scx, _scy, _sct, _rot, _rots, _follow) { #region
		INLINE
		
		sc_sx = _scx;
		sc_sy = _scy;
		sct   = _sct;
		
		rot   = _rot;
		rot_s = _rots;
		follow = _follow;
	} #endregion
	
	static setDraw = function(_col, _blend, _alp, _fade) { #region
		INLINE
		
		col      = _col;
		blend	 = _blend;
		alp      = _alp;
		alp_draw = _alp;
		alp_fade = _fade;
	} #endregion
	
	static setPath = function(_path, _pathDiv) { #region
		INLINE
		
		path    = _path;
		pathDiv = _pathDiv;
	} #endregion
	
	static kill = function(callDestroy = true) { #region
		INLINE
		
		active = false;
		if(callDestroy && node.onPartDestroy != noone)
			node.onPartDestroy(self);
	} #endregion
	
	static step = function(frame = 0) { #region
		INLINE
		trailLife++;
		
		if(!active) return;
		x += speedx;
		self.frame = frame;
		
		random_set_seed(seed + life);
		
		if(ground && y + speedy > ground_y) {
			y = ground_y;
			speedy = -speedy * ground_bounce;
			
			if(abs(speedy) < 0.1)
				speedx *= ground_friction;
		} else
			y += speedy;
		
		var dirr = point_direction(0, 0, speedx, speedy);
		var diss = point_distance(0, 0, speedx, speedy);
		diss = max(0, diss + accel);
		
		if(speedx != 0 || speedy != 0) {
			dirr += wig_dir.get(seed + life);
			
			if(turning != 0) {
				var trn = turning;
				
				     if(turnSpd > 0) trn = turning * diss * turnSpd;
				else if(turnSpd < 0) trn = turning / diss * turnSpd;
				
				dirr += trn
			}
		}
		
		speedx = lengthdir_x(diss, dirr) + gravX;
		speedy = lengthdir_y(diss, dirr) + gravY;
		
		if(follow)  rot = spVec[1];
		else        rot += rot_s;
		
		if(node.onPartStep != noone && step_int > 0 && safe_mod(life, step_int) == 0) 
			node.onPartStep(self);
		
		if(life-- < 0) kill();
		
		if(prevx != undefined) {
			spVec[0] = point_distance(prevx, prevy, x, y);
			spVec[1] = point_direction(prevx, prevy, x, y);
		}
		
		x_history[life_incr] = drawx;
		y_history[life_incr] = drawy;
		life_incr++;
		
		prevx = x;
		prevy = y;
		
		drawx   = x;
		drawy   = y;
		drawrot = rot;
		drawsx  = sc_sx;
		drawsy  = sc_sy;
		
		drawx   += wig_psx.get(seed + life);
		drawy   += wig_psy.get(seed + life);
		drawrot += wig_rot.get(seed + life);
		drawsx  += wig_scy.get(seed + life);
		drawsy  += wig_scy.get(seed + life);
	} #endregion
	
	static draw = function(exact, surf_w, surf_h) { #region
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
			var ind = abs(round((life_total - life) * anim_speed));
			var len = array_length(surf);
			
			switch(anim_end) {
				case ANIM_END_ACTION.loop: 
					ss = surf[safe_mod(ind, len)];
					break;
				case ANIM_END_ACTION.pingpong:
					var ping = safe_mod(ind, (len - 1) * 2 + 1); 
					ss = surf[ping >= len? (len - 1) * 2 - ping : ping];
					break;
				case ANIM_END_ACTION.destroy:
					if(ind >= len) {
						kill();
						return;
					}
					
					ss = surf[ind];
					break;
			}
		} else if(arr_type == 3) {
			var _sca = round(min(scx, scy));
			ss = array_safe_get(surf, clamp(_sca, 0, array_length(surf) - 1));
		}
		
		var surface = is_instanceof(ss, SurfaceAtlas)? ss.getSurface() : node.surface_cache[$ ss];
		var _useS   = is_surface(surface);
		
		if(arr_type == 3) {
			scx = 1;
			scy = 1;
		}
		
		scx_history[life_incr - 1]   = scx;
		scy_history[life_incr - 1]   = scy;
		
		var _xx, _yy;
		var s_w = (_useS? surface_get_width_safe(surface)  : 1) * scx;
		var s_h = (_useS? surface_get_height_safe(surface) : 1) * scy;
		
		var _pp = point_rotate(-s_w / 2, -s_h / 2, 0, 0, rot);
		_xx = drawx + _pp[0];
		_yy = drawy + _pp[1];
		
		if(path != noone) {
			var _div = pathDiv.get(lifeRat);
			
			pathPos = path.getPointRatio(clamp(lifeRat, 0, 0.99), pathIndex, pathPos);
			_xx = _xx * _div + pathPos.x;
			_yy = _yy * _div + pathPos.y;
		}
		
		if(exact) {
			_xx = round(_xx);
			_yy = round(_yy);
		}
		
		var x0 = _xx - s_w * 1.5;
		var y0 = _yy - s_h * 1.5;
		var x1 = _xx + s_w * 1.5;
		var y1 = _yy + s_h * 1.5;
		
		var cc = (col == -1)? c_white : col.eval(lifeRat);
		if(blend != c_white) cc = colorMultiply(blend, cc);
		alp_draw = alp * (alp_fade == noone? 1 : alp_fade.get(lifeRat)) * _color_get_alpha(cc);
		
		blend_history[life_incr - 1] = cc;
		alp_history[life_incr - 1]   = alp_draw;
		
		currColor = cola(cc, alp_draw);
		
		if(_useS && (x0 > surf_w || y0 > surf_h || x1 < 0 || y1 < 0))
			return;
		
		switch(render_type) {
			case PARTICLE_RENDER_TYPE.surface : 
				if(_useS) draw_surface_ext_safe(surface, _xx, _yy, scx, scy, drawrot, cc, alp_draw);
				else {
					var ss = round(min(scx, scy));
					if(round(ss) == 0) return;
					
					var _s = shader_current();
					shader_reset();
						
						draw_set_color(cc);
						draw_set_alpha(alp_draw);
						dynaSurf_circle_fill(_xx, _yy, exact? round(ss) : ss);
						draw_set_alpha(1);
					
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
	} #endregion
	
	static getPivot = function() { #region
		INLINE
		
		return [x, y];
	} #endregion
		
	static clone = function() { #region
		var _p = new __part(node);
		struct_override(_p, self);
		return _p;
	} #endregion
}

#region helper
	#macro UPDATE_PART_FORWARD static updateParticleForward = function() {		\
		var pt = outputs[| 0];													\
		for( var i = 0; i < array_length(pt.value_to); i++ ) {					\
			var _n = pt.value_to[i];											\
			if(_n.value_from != pt) continue;									\
																				\
			if(variable_struct_exists(_n.node, "updateParticleForward"))		\
				_n.node.updateParticleForward();								\
		}																		\
	}
#endregion