function dynaSurf() constructor {
	surfaces = [];
	
	static getAbsolutePos = function(_x, _y, _xs = 1, _ys = 1, _rot = 0) {
		var _w    = getWidth() * _xs;
		var _h    = getHeight() * _ys;
		var _px   = point_rotate(0, 0, _w / 2, _h / 2, _rot);
		
		return [ _x - _px[0], _y - _px[1] ];
	}
	
	static getWidth  = function() { return is_surface(array_safe_get_fast(surfaces, 0))? surface_get_width(surfaces[0])  : 1; }
	static getHeight = function() { return is_surface(array_safe_get_fast(surfaces, 0))? surface_get_height(surfaces[0]) : 1; }
	static getFormat = function() { return is_surface(array_safe_get_fast(surfaces, 0))? surface_get_format(surfaces[0]) : surface_rgba8unorm; }
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {}
	static drawStretch = function(_x = 0, _y = 0, _w = 1, _h = 1, _ang = 0, _col = c_white, _alp = 1) {
		var _sx = _w / getWidth();
		var _sy = _h / getHeight();
		
		draw(_x, _y, _sx, _sy, _ang, _col, _alp);
	}
	
	static drawTile = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _col = c_white, _alp = 1) {}
	static drawPart = function(_l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {}
	
	static onFree = function() {}
	static free = function() {
		for( var i = 0, n = array_length(surfaces); i < n; i++ ) 
			surface_free_safe(surfaces[i]);
		onFree();
	}
	
	static clone = function() { return noone; }
	static destroy = function() {}
}

function compute_dynaSurf() : dynaSurf() constructor {
	drawFn   = noone;
	widthFn  = noone;
	heightFn = noone;
	
	useAbsolutePose = false;
	
	static getWidth  = function() { return widthFn?  widthFn.eval() : 1; }
	static getHeight = function() { return heightFn? heightFn.eval() : 1; }
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		if(drawFn == noone) return;
		var pos = useAbsolutePose? getAbsolutePos(_x, _y, _xs, _ys, _rot) : [ _x, _y ];
		
		var params = {
			x: pos[0], 
			y: pos[1], 
			sx: _sx, 
			sy: _sy, 
			angle: _ang, 
			color: _col, 
			alpha: _alp
		};
		
		drawFn.eval(params);
	}
	
	static clone = function() {
		var _surf = new compute_dynaSurf();
		
		_surf.drawFn   = drawFn;
		_surf.widthFn  = widthFn;
		_surf.heightFn = heightFn;
		
		return _surf;
	}
}