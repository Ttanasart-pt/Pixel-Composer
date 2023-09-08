function DynaSurf() constructor {
	surfaces = [];
	
	static getWidth  = function() { return 1; }
	static getHeight = function() { return 1; }
	
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
	
	static clone = function() {}
}