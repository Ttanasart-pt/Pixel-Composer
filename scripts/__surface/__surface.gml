function Atlas(_surface, _x = 0, _y = 0, _rot = 0, _sx = 1, _sy = 1, _blend = c_white, _alpha = 1) constructor {
	surface  = _surface;
	x        = _x;
	y        = _y;
	rotation = _rot;
	sx       = _sx;
	sy       = _sy;
	blend    = _blend;
	alpha    = _alpha;
	
	w = 1;
	h = 1;
	
	static getSurface = function() /*=>*/ {return surface};
	
	static set = function(_surface, _x = 0, _y = 0, _rot = 0, _sx = 1, _sy = 1, _blend = c_white, _alpha = 1, setDim = true) {
		INLINE
		
		surface  = _surface;
		x        = _x;
		y        = _y;
		rotation = _rot;
		sx       = _sx;
		sy       = _sy;
		blend    = _blend;
		alpha    = _alpha;
		
		return self;
	}
	
	static draw = function() {}
	
}

function SurfaceAtlasFast(_surface, _x = 0, _y = 0, _rot = 0, _sx = 1, _sy = 1, _blend = c_white, _alpha = 1)                : Atlas(_surface, _x, _y, _rot, _sx, _sy, _blend, _alpha) constructor {}
function SurfaceAtlas(    _surface, _x = 0, _y = 0, _rot = 0, _sx = 1, _sy = 1, _blend = c_white, _alpha = 1, setDim = true) : Atlas(_surface, _x, _y, _rot, _sx, _sy, _blend, _alpha) constructor {
	surface  = new Surface(_surface);
	w = setDim? surface_get_width_safe(surface.surface)  : 1;
	h = setDim? surface_get_height_safe(surface.surface) : 1;
	
	oriSurf = noone;
	oriSurf_w = w;
	oriSurf_h = h;
	
	static getSurface = function() /*=>*/ {return surface.get()};
	
	__base_set = set;
	static set = function(_surface, _x = 0, _y = 0, _rot = 0, _sx = 1, _sy = 1, _blend = c_white, _alpha = 1, setDim = true) {
		INLINE
		
		__base_set(_surface, _x, _y, _rot, _sx, _sy, _blend, _alpha);
		surface  = new Surface(_surface);
		
		w = setDim? surface_get_width_safe(surface.surface)  : 1;
		h = setDim? surface_get_height_safe(surface.surface) : 1;
		
		return self;
	}
	
	static setOrginalSurface = function(_surface) {
		INLINE
		
		oriSurf   = _surface;
		oriSurf_w = surface_get_width_safe(_surface);
		oriSurf_h = surface_get_height_safe(_surface);
		return self;
	}
	
	static setSurface = function(_surface) {
		INLINE
		
		surface.set(_surface);
		w = surface_get_width_safe(_surface);
		h = surface_get_height_safe(_surface);
	}
	
	static draw = function(submitInt = false) {
		var _surf = getSurface();
		draw_surface_ext_safe(_surf, x, y, sx, sy, rotation, blend, alpha);
		return self;
	}
	
	static clone = function(_cloneSurf = false) {
		var _surf = getSurface();
		if(_cloneSurf) _surf = surface_clone(_surf);
		return new SurfaceAtlas(_surf, x, y, rotation, sx, sy, blend, alpha);
	}
}

function Surface(_surf) constructor {
	static set = function(_surf) {
		INLINE
		
		self.surface = _surf;
		w = surface_get_width_safe(_surf);
		h = surface_get_height_safe(_surf);
		format = surface_get_format(_surf);
	}
	
	set(_surf);
	
	static get     = function() /*=>*/ {return surface};
	static isValid = function() /*=>*/ {return is_surface(surface)};
	
	static resize = function(_w, _h) { 
		INLINE
		surface_resize(surface, _w, _h);
		w = _w; h = _h;
		return self;
	}
	
	static draw = function(_x, _y, xs = 1, ys = 1, rot = 0, col = c_white, alpha = 1) { 
		INLINE
		draw_surface_ext_safe(surface, _x, _y, xs, ys, rot, col, alpha);
		return self; 
	}
	
	static drawStretch = function(_x, _y, _w = 1, _h = 1, rot = 0, col = c_white, alpha = 1) { 
		INLINE
		draw_surface_stretched_ext(surface, _x, _y, _w, _h, col, alpha);
		return self; 
	}
	
	static destroy = function() {
		INLINE
		if(!isValid()) return;
		surface_free(surface);
	}
}

function Surface_get(_surf) {
	INLINE
		
	if(is_real(_surf)) 
		return _surf;
	if(is_struct(_surf) && struct_has(_surf, "surface")) 
		return _surf.surface;
		
	return noone;
}