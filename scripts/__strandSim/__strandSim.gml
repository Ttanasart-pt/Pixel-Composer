function StrandPoint(x, y) constructor {
	self.x = x;
	self.y = y;
	
	px = x;
	py = y;
	
	ppx = x;
	ppy = y;
	
	dx = 0;
	dy = 0;
	
	ikx = noone;
	iky = noone;
	
	air_resist = 0.5;
	
	static set = function(x ,y) {
		self.x = x;
		self.y = y;
	}
	
	static motionDelta = function() {
		dx = x - px;
		dy = y - py;
		
		px = x;
		py = y;
	}
	
	static motionPropagate = function(timeStep = 1) {
		x += dx / timeStep;
		y += dy / timeStep;
	}
	
	static clone = function() { return new StrandPoint(x, y); }
}

function Strand(sx = 0, sy = 0, amount = 5, length = 8, direct = 0, curlFreq = 4, curlSize = 8) constructor {
	points = [];
	id = irandom_range(10000, 99999);
	self.length = array_create(amount, length);
	self.direct = direct;
	curl_freq = curlFreq;
	curl_size = curlSize;
	
	tension = 0.8;
	spring  = 0.1;
	angularTension = 0.1;
	
	rootStrength = -1;
	rootForce    = 0;
	free = false;
	
	var _sx = sx;
	var _sy = sy;
	for( var i = 0; i < amount; i++ ) {
		points[i] = new StrandPoint(sx, sy);
		sx += lengthdir_x(self.length[i], direct);
		sy += lengthdir_y(self.length[i], direct);
	}
	
	setOrigin(_sx, _sy);
	for( var i = 1; i < array_length(points); i++ )
		restAngle[i] = 0;
	restAngle[0] = direct;
	
	static motionDelta = function() {
		rootForce = 0;
		for( var i = !free; i < array_length(points); i++ )
			points[i].motionDelta();
	}
	
	static motionPropagate = function(timeStep) {
		for( var i = !free; i < array_length(points); i++ )
			points[i].motionPropagate(timeStep);
	}
	
	static chainConstrain = function() {
		for( var i = 1; i < array_length(points); i++ ) {
			var p0 = points[i - 1];
			var p1 = points[i - 0];
			
			var dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			var dis = point_distance(p0.x, p0.y, p1.x, p1.y);
			
			if(dis < 1) continue;
			var len = lerp(dis, length[i], tension);
			
			if(free) {
				var dx = lengthdir_x(dis - len, dir) / 2;
				var dy = lengthdir_y(dis - len, dir) / 2;
				
				p0.x += dx;
				p0.y += dy;
				
				p1.x -= dx;
				p1.y -= dy;
			} else {
				if(i == 1) rootForce += len;
				p1.x = p0.x + lengthdir_x(len, dir);
				p1.y = p0.y + lengthdir_y(len, dir);
			}
		}
		
		var oa = restAngle[0], na;
		for( var i = 1; i < array_length(points); i++ ) {
			var p0 = points[i - 1];
			var p1 = points[i - 0];
			
			var pdir = point_direction(p0.px, p0.py, p1.px, p1.py);
			var dir  = point_direction(p0.x, p0.y, p1.x, p1.y);
			var dis  = point_distance(p0.x, p0.y, p1.x, p1.y);
			var dst  = oa + restAngle[i];
			var adf  = angle_difference(dst, dir);
			
			if(dis < 1) continue;
			var delt = adf * power(angularTension, 2) * power(1 - i / array_length(points), 2);
			na = dir + delt;
			
			var adlt = angle_difference(pdir, na);
			var delt = adlt * power(1 - spring, 2);
			na += delt;
			
			var tx = p0.x + lengthdir_x(dis, na);
			var ty = p0.y + lengthdir_y(dis, na);
			
			p1.x = tx;
			p1.y = ty;
			
			oa = na;
		}
	}
	
	static springConstrain = function() {
		var spng = array_length(points) / curl_freq;
		if(spng <= 0) return;
		
		for( var i = spng; i < array_length(points); i++ ) {
			var p0 = points[i - spng];
			var p1 = points[i];
			
			var dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			var dis = point_distance(p0.x, p0.y, p1.x, p1.y);
			
			if(dis < 1) continue;
			var len = lerp(dis, length[i] * curl_size * spng, spring);
			
			p1.x = p0.x + lengthdir_x(len, dir);
			p1.y = p0.y + lengthdir_y(len, dir);
		}
	}
	
	static setOrigin = function(x, y) {
		if(array_length(points) < 1) return;
		if(free) return;
		
		points[0].set(x, y);
	}
	
	static step = function(timeStep = 1, iteration = 4, detach = true) {
		motionDelta();
		
		repeat(timeStep) {
			motionPropagate(timeStep);
			
			repeat(iteration) {
				chainConstrain();
				springConstrain();
			}
		}
		
		if(detach && rootStrength > -1 && rootForce > rootStrength) 
			free = true;
	}
	
	static freeze = function(fix = false) {
		var a = restAngle[0];
		
		for( var i = 1; i < array_length(points); i++ ) {
			var p0 = points[i - 1];
			var p1 = points[i - 0];
			
			var dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			var dis = point_distance(p0.x, p0.y, p1.x, p1.y);
			
			if(!fix) length[i] = dis;
			restAngle[i] = angle_difference(dir, a);
			
			a = dir;
		}
	}
	
	static store = function() {
		var op, np;
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			np = points[i];
			
			if(i) {
				np.storeAngle = point_direction(op.x, op.y, np.x, np.y);
				np.storeDistance = point_distance(op.x, op.y, np.x, np.y);
			}
			
			op = np;
		}
	}
	
	static draw = function(_x, _y, _s, drawAngle = false, baked = false) {
		if(drawAngle) {
			draw_set_color(c_red);
			var aa = 0;
			var ox, oy, nx, ny;
		
			for( var i = 0, n = array_length(points); i < n; i++ ) {
				aa += restAngle[i];
				
				if(i) {
					nx = ox + lengthdir_x(length[i], aa);
					ny = oy + lengthdir_y(length[i], aa);
				
					draw_line(_x + ox * _s, _y + oy * _s, _x + nx * _s, _y + ny * _s);
				} else {
					nx = points[i].x;
					ny = points[i].y;
				}
				
				ox = nx;
				oy = ny;
			}
		}
		
		//draw_set_color(c_lime);
		//var ox, oy, nx, ny;
		//for( var i = 0, n = array_length(points); i < n; i++ ) {
		//	nx = points[i].px;
		//	ny = points[i].py;
			
		//	nx = _x + nx * _s;
		//	ny = _y + ny * _s;
			
		//	if(i) draw_line(ox, oy, nx, ny);
			
		//	ox = nx;
		//	oy = ny;
		//}
		
		draw_set_color(baked? c_aqua : c_blue);
		var ox, oy, nx, ny;
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			nx = points[i].x;
			ny = points[i].y;
			
			nx = _x + nx * _s;
			ny = _y + ny * _s;
			
			if(i) draw_line(ox, oy, nx, ny);
			
			ox = nx;
			oy = ny;
		}
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			nx = points[i].x;
			ny = points[i].y;
			
			nx = _x + nx * _s;
			ny = _y + ny * _s;
			
			draw_circle_prec(nx, ny, 3, false);
		}
	}
	
	static set = function(sx = points[0].x, sy = points[0].y) {
		var ox, oy, aa = 0;
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			aa += restAngle[i];
			
			if(i) {
				points[i].x = ox + lengthdir_x(length[i], aa);
				points[i].y = oy + lengthdir_y(length[i], aa);
			} else {
				points[i].x = sx;
				points[i].y = sy;
			}
			
			ox = points[i].x;
			oy = points[i].y;
		}
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			points[i].px = points[i].x;
			points[i].py = points[i].y;
		}
	}
	
	static FABRIK = function(iter = 4) {
		var op, np;
		var amo = array_length(points);
		
		var sx = points[0].x;
		var sy = points[0].y;
		
		var changed = false;
		for( var i = 0; i < amo; i++ ) {
			var p = points[i];
			if(p.ikx == noone) continue;
			if(p.iky == noone) continue;
			
			if(p.x != p.ikx && p.y != p.iky)
				changed = true;
				
			p.x = p.ikx;
			p.y = p.iky;
		}
		
		repeat(iter) {
			for( var i = 0; i < amo; i++ ) {
				np = points[amo - 1 - i];
			
				if(i) {
					var dir = point_direction(op.x, op.y, np.x, np.y);
					var dis = length[amo - 1 - i];
				
					np.x = op.x + lengthdir_x(dis, dir);
					np.y = op.y + lengthdir_y(dis, dir);
				} 
			
				op = np;
			}
		
			for( var i = 0; i < amo; i++ ) {
				np = points[i];
			
				if(i) {
					var dir = point_direction(op.x, op.y, np.x, np.y);
					var dis = length[i];
				
					np.x = op.x + lengthdir_x(dis, dir);
					np.y = op.y + lengthdir_y(dis, dir);
				} else {
					np.x = sx;
					np.y = sy;
				}
			
				op = np;
			}
		}
		
		for( var i = 0; i < amo; i++ ) {
			p.ikx = noone;
			p.iky = noone;
		}
	}
	
	static clone = function() {
		set();
		
		var s = new Strand(points[0].x, points[0].y, array_length(points), length[0], direct, curl_freq, curl_size);
		for( var i = 0, n = array_length(points); i < n; i++ )
			s.points[i] = points[i].clone();
		s.restAngle = array_clone(restAngle);
		s.length    = array_clone(length);
		
		return s;
	}
	
	static serialize = function()  { 
		return {
			points: points,
			restAngle: restAngle,
			length: length,
		}; 
	}
	
	static deserialize = function(s) { 
		points    = s.points;
		restAngle = s.restAngle;
		length    = s.length;
		return self;
	}
}

function StrandMesh() constructor {
	hairs = [];
	loop  = false;
	mesh  = noone;
	
	static step = function(iteration = 4) {
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			hairs[i].step(iteration);
	}
	
	static draw = function(_x, _y, _s, drawAngle = false, baked = false) {
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			hairs[i].draw(_x, _y, _s, drawAngle, baked);
	}
	
	static store = function() {
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			hairs[i].store();
	}
	
	static freeze = function(fixLength = false) {
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			hairs[i].freeze(fixLength);
	}
	
	static getPointRatio = function(rat, ind = 0) {
		if(array_length(hairs) == 0) return new __vec2();
		
		var h  = array_safe_get(hairs, ind);
		var sg = rat * (array_length(h.points) - 1);
		var fr = frac(sg);
		
		var p0 = array_safe_get(h.points, floor(sg));
		var p1 = array_safe_get(h.points, floor(sg) + 1);
		
		return new __vec2(lerp(p0.x, p1.x, fr), lerp(p0.y, p1.y, fr));
	}
	
	static getLineCount = function() {
		return array_length(hairs);
	}
	
	static set = function() {
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			hairs[i].set();
		
		return self;
	}
	
	static clone = function() {
		var s = new StrandMesh();
		
		s.loop = loop;
		s.mesh = mesh;
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			s.hairs[i] = hairs[i].clone();
		
		return s;
	}
	
	static serialize = function()  { 
		var _h = [];
		for( var i = 0, n = array_length(hairs); i < n; i++ )
			_h[i] = hairs[i].serialize();
		return json_stringify(_h); 
	}
	
	static deserialize = function(s) { 
		var j = json_parse(s);
		
		for( var i = 0, n = array_length(j); i < n; i++ )
			hairs[i] = new Strand().deserialize(j[i]);
		return self;
	}
}