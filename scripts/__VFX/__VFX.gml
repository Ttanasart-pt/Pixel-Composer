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

function __part(_node) constructor {
	seed   = irandom(99999);
	node   = _node;
	active = false;
	surf   = noone;
	x   = 0;
	y   = 0;
	sx  = 0;
	sy  = 0;
	ac  = 0;
	g   = 0;
	wig = 0;
	
	boundary_data = -1;
	
	gy  = 0;
	
	scx   = 1;
	scy   = 1;
	sc_sx  = 1;
	sc_sy  = 1;
	sct   = CURVE_DEF_11;
	
	rot		= 0;
	follow	= false;
	rot_s	= 0;
	
	col      = -1;
	blend	 = c_white;
	alp      = 1;
	alp_draw = alp;
	alp_fade = 0;
	
	life       = 0;
	life_total = 0;
	step_int   = 0;
	
	anim_speed = 1;
	anim_end   = ANIM_END_ACTION.loop;
	
	static create = function(_surf, _x, _y, _life) {
		active	= true;
		surf	= _surf;
		x		= _x;
		y		= _y;
		gy		= 0;
		
		life = _life;
		life_total = life;
		node.onPartCreate(self);
	}
	
	static setPhysic = function(_sx, _sy, _ac, _g, _wig) {
		sx  = _sx;
		sy  = _sy;
		ac  = _ac;
		g   = _g;
		
		wig = _wig;
	}
	
	static setTransform = function(_scx, _scy, _sct, _rot, _rots, _follow) {
		sc_sx = _scx;
		sc_sy = _scy;
		sct   = _sct;
		
		rot   = _rot;
		rot_s = _rots;
		follow = _follow;
	}
	
	static setDraw = function(_col, _blend, _alp, _fade) {
		col      = _col;
		blend	 = _blend;
		alp      = _alp;
		alp_draw = _alp;
		alp_fade = _fade;
	}
	
	static kill = function() {
		active = false;
		node.onPartDestroy(self);
	}
	
	static step = function() { 
		if(!active) return;
		var xp = x, yp = y;
		x  += sx;
		y  += sy;
		
		var dirr = point_direction(0, 0, sx, sy);
		var diss = point_distance(0, 0, sx, sy);
		if(diss > 0) {
			diss += ac;
			dirr += random_range(-wig, wig);
			sx = lengthdir_x(diss, dirr);
			sy = lengthdir_y(diss, dirr);
		}
		
		gy += g;
		y += gy;
		
		if(follow) 
			rot = point_direction(xp, yp, x, y);
		else
			rot += rot_s;
		
		if(step_int > 0 && safe_mod(life, step_int) == 0) 
			node.onPartStep(self);
		if(life-- < 0) kill();
	}
	
	static draw = function(exact, surf_w, surf_h) { 
		if(!active) return;
		var ss = surf;
		if(is_array(surf)) {
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
					if(ind >= len)	return;
					else			ss = surf[ind];
					break;
			}
		}
		if(!is_surface(ss)) return;
		
		var lifeRat = 1 - life / life_total;
		var scCurve = eval_curve_x(sct, lifeRat);
		scx   = sc_sx * scCurve;
		scy   = sc_sy * scCurve;
		
		var _xx, _yy;
		var s_w = surface_get_width(ss) * scx;
		var s_h = surface_get_height(ss) * scy;
		
		if(boundary_data == -1) {
			var _pp = point_rotate(-s_w / 2, -s_h / 2, 0, 0, rot);
			_xx = x + _pp[0];
			_yy = y + _pp[1];
		} else {
			var ww = boundary_data[2] + boundary_data[0];
			var hh = boundary_data[3] + boundary_data[1];
			
			var cx = (boundary_data[0] + boundary_data[2]) / 2;
			var cy = (boundary_data[1] + boundary_data[3]) / 2;
			
			var _pp = point_rotate(-cx, -cy, 0, 0, rot);
			
			_xx = x + cx + _pp[0] * scx;
			_yy = y + cy + _pp[1] * scy;
		}
		
		if(exact) {
			_xx = round(_xx);
			_yy = round(_yy);
		}
		
		var x0 = _xx - s_w * 1.5;
		var y0 = _yy - s_h * 1.5;
		var x1 = _xx + s_w * 1.5;
		var y1 = _yy + s_h * 1.5;
		
		if(x0 > surf_w || y0 > surf_h || x1 < 0 || y1 < 0) return; //culling
		
		var cc = (col == -1)? c_white : col.eval(lifeRat);
		if(blend != c_white) cc = colorMultiply(blend, cc);
		alp_draw = alp * eval_curve_x(alp_fade, lifeRat);
		draw_surface_ext_safe(ss, _xx, _yy, scx, scy, rot, cc, alp_draw);
	}
	
	static getPivot = function() {
		if(boundary_data == -1) 
			return [x, y];
		
		var ww = (boundary_data[2] - boundary_data[0]) * scx;
		var hh = (boundary_data[3] - boundary_data[1]) * scy;
		var cx = x + boundary_data[0] + ww / 2;
		var cy = y + boundary_data[1] + hh / 2;
		
		return [cx, cy];
	}
}
