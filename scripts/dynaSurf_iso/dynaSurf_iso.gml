function dynaSurf_iso() : dynaSurf() constructor {
	angles      = [];
	angle_shift = 0;
	
	static getSurface = function(_rot) {
		_rot += angle_shift;
		var _ind  = 0;
		var _minA = 360;
		
		for( var i = 0, n = array_length(angles); i < n; i++ ) {
			var _dif = abs(angle_difference(_rot, angles[i]));
			if(_dif < _minA) {
				_minA = _dif;
				_ind  = i;
			}
		}
		
		return array_safe_get(surfaces, _ind);
	}
	
	static draw = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		var _surf = getSurface(_rot);
		var _pos  = getAbsolutePos(_x, _y, _xs, _ys, _rot);
		
		draw_surface_ext_safe(_surf, _pos[0], _pos[1], _xs, _ys, 0, _col, _alp);
	}
	
	static drawTile = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _col = c_white, _alp = 1) {
		var _surf = surfaces[0];
		draw_surface_tiled_ext_safe(_surf, _x, _y, _xs, _ys, _col, _alp);
	}
	
	static drawPart = function(_l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		var _surf = getSurface(_rot);
		draw_surface_part_ext_safe(_surf, _l, _t, _w, _h, _x, _y, _xs, _ys, 0, _col, _alp);
	}
}

function dynaSurf_iso_4() : dynaSurf_iso() constructor {
	surfaces = array_create(4, noone);
	
	static getSurface = function(_rot) {
		_rot += angle;
		var ind = 0;
			 if(abs(angle_difference(  0, _rot)) <= 45) ind = 0;
		else if(abs(angle_difference( 90, _rot)) <= 45) ind = 1;
		else if(abs(angle_difference(180, _rot)) <= 45) ind = 2;
		else if(abs(angle_difference(270, _rot)) <= 45) ind = 3;
		
		return surfaces[ind];
	}
	
	static clone = function() {
		var _new = new dynaSurf_iso_4();
		_new.surfaces = surfaces;
		_new.angle    = angle;
		
		return _new;
	}
}

function dynaSurf_iso_8() : dynaSurf_iso() constructor {
	surfaces = array_create(8, noone);
	
	static getSurface = function(_rot) {
		_rot += angle;
		var ind = 0;
			 if(abs(angle_difference(  0, _rot)) <= 22.5) ind = 0;
		else if(abs(angle_difference( 45, _rot)) <= 22.5) ind = 1;
		else if(abs(angle_difference( 90, _rot)) <= 22.5) ind = 2;
		else if(abs(angle_difference(135, _rot)) <= 22.5) ind = 3;
		else if(abs(angle_difference(180, _rot)) <= 22.5) ind = 4;
		else if(abs(angle_difference(225, _rot)) <= 22.5) ind = 5;
		else if(abs(angle_difference(270, _rot)) <= 22.5) ind = 6;
		else if(abs(angle_difference(315, _rot)) <= 22.5) ind = 7;
		
		return surfaces[ind];
	}
	
	static clone = function() {
		var _new = new dynaSurf_iso_8();
		_new.surfaces = surfaces;
		_new.angle    = angle;
		
		return _new;
	}
}