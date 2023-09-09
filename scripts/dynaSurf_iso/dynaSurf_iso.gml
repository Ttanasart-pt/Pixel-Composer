function DynaSurf_iso() : DynaSurf() constructor {
	angle    = 0;
	
	static getSurface = function(_rot) {}
	
	static draw = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		var _surf = getSurface(_rot);
		var _w    = getWidth() * _xs;
		var _h    = getHeight() * _ys;
		var _px   = point_rotate(0, 0, _w / 2, _h / 2, _rot);
		
		draw_surface_ext_safe(_surf, _x - _px[0], _y - _px[1], _xs, _ys, 0, _col, _alp);
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

function dynaSurf_iso_4() : DynaSurf_iso() constructor {
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

function dynaSurf_iso_8() : DynaSurf_iso() constructor {
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