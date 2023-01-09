enum ANIM_END_ACTION {
	loop,
	pingpong,
	destroy,
}

enum PARTICLE_BLEND_MODE {
	normal,
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
	
	fx  = 0;
	fy  = 0;
	
	gy  = 0;
	
	scx   = 1;
	scy   = 1;
	scx_s = 1;
	scy_s = 1;
	
	rot		= 0;
	follow	= false;
	rot_s	= 0;
	
	col      = -1;
	alp      = 1;
	alp_draw = alp;
	alp_fade = 0;
	
	life       = 0;
	life_total = 0;
	step_int   = 0;
	
	anim_speed = 1;
	anim_end   = ANIM_END_ACTION.loop;
	
	function create(_surf, _x, _y, _life) {
		active	= true;
		surf	= _surf;
		x		= _x;
		y		= _y;
		gy		= 0;
		
		life = _life;
		life_total = life;
		node.onPartCreate(self);
	}
	
	function setPhysic(_sx, _sy, _ac, _g, _wig) {
		sx  = _sx;
		sy  = _sy;
		ac  = _ac;
		g   = _g;
		
		wig = _wig;
	}
	function setTransform(_scx, _scy, _scxs, _scys, _rot, _rots, _follow) {
		scx   = _scx;
		scy   = _scy;
		scx_s = _scxs;
		scy_s = _scys;
		rot   = _rot;
		rot_s = _rots;
		follow = _follow;
	}
	function setDraw(_col, _alp, _fade) {
		col      = _col;
		alp      = _alp;
		alp_draw = _alp;
		alp_fade = _fade;
	}
	
	function kill() {
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
		
		if(scx_s < 0)	scx = max(scx + scx_s, 0);
		else			scx = scx + scx_s;
		if(scy_s < 0)	scy = max(scy + scy_s, 0);
		else			scy = scy + scy_s;
		
		if(follow) 
			rot = point_direction(xp, yp, x, y);
		else
			rot += rot_s;
		alp_draw = alp * eval_curve_bezier_cubic_x(alp_fade, 1 - life / life_total);
		
		if(step_int > 0 && safe_mod(life, step_int) == 0) 
			node.onPartStep(self);
		if(life-- < 0) kill();
	}
	
	function draw(exact) {
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
		
		var cc = (col == -1)? c_white : gradient_eval(col, 1 - life / life_total);
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
		
		draw_surface_ext_safe(ss, _xx, _yy, scx, scy, rot, cc, alp_draw);
	}
	
	function getPivot() {
		if(boundary_data == -1) 
			return [x, y];
		
		var ww = (boundary_data[2] - boundary_data[0]) * scx;
		var hh = (boundary_data[3] - boundary_data[1]) * scy;
		var cx = x + boundary_data[0] + ww / 2;
		var cy = y + boundary_data[1] + hh / 2;
		
		return [cx, cy];
	}
}
