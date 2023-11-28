function SurfaceAtlas(surface, _x = 0, _y = 0, rot = 0, sx = 1, sy = 1, blend = c_white, alpha = 1) constructor {
	self.surface  = new Surface(surface);
	self.x = _x;
	self.y = _y;
	self.rotation = rot;
	self.sx = sx;
	self.sy = sy;
	self.blend = blend;
	self.alpha = alpha;
	
	w = surface_get_width_safe(surface);
	h = surface_get_height_safe(surface);
	
	oriSurf = noone;
	oriSurf_w = w;
	oriSurf_h = h;
	
	static set = function(surface, _x = 0, _y = 0, rot = 0, sx = 1, sy = 1, blend = c_white, alpha = 1) {
		INLINE
		
		self.surface  = new Surface(surface);
		self.x = _x;
		self.y = _y;
		self.rotation = rot;
		self.sx = sx;
		self.sy = sy;
		self.blend = blend;
		self.alpha = alpha;
		
		w = surface_get_width_safe(surface);
		h = surface_get_height_safe(surface);
		
		return self;
	}
	
	static setOrginalSurface = function(surf) {
		INLINE
		
		oriSurf   = surf;
		oriSurf_w = surface_get_width_safe(surf);
		oriSurf_h = surface_get_height_safe(surf);
		return self;
	}
	
	static getSurface = function() {
		INLINE
		
		return surface.get();
	}
	
	static setSurface = function(surface) {
		INLINE
		
		self.surface.set(surface);
		
		w = surface_get_width_safe(surface);
		h = surface_get_height_safe(surface);
	}
	
	static draw = function() {
		INLINE
		
		draw_surface_ext_safe(surface.get(), x, y, sx, sy, rotation, blend, alpha);
		return self;
	}
	
	static clone = function(_surface = false) {
		INLINE
		
		var _surf = getSurface();
		if(_surface) _surf = surface_clone(_surf);
		
		return new SurfaceAtlas(_surf, x, y, rotation, sx, sy, blend, alpha);
	}
}

function Surface(surface) constructor {
	static set = function(surface) {
		INLINE
		
		self.surface = surface;
		w = surface_get_width_safe(surface);
		h = surface_get_height_safe(surface);
		format = surface_get_format(surface);
	}
	set(surface);
	
	static get = function() { INLINE return surface; }
	
	static isValid = function() { INLINE return is_surface(surface); }
	
	static resize = function(w, h) { 
		INLINE
		
		surface_resize(surface, w, h);
		self.w = w;
		self.h = h;
		return self;
	}
	
	static draw = function(x, y, xs = 1, ys = 1, rot = 0, col = c_white, alpha = 1) { 
		INLINE
		
		draw_surface_ext_safe(surface, x, y, xs, ys, rot, col, alpha);
		return self; 
	}
	
	static drawStretch = function(x, y, w = 1, h = 1, rot = 0, col = c_white, alpha = 1) { 
		INLINE
		
		draw_surface_stretched_ext(surface, x, y, w, h, col, alpha);
		return self; 
	}
	
	static destroy = function() {
		INLINE
		
		if(!isValid()) return;
		surface_free(surface);
	}
}

function Surface_get(surface) {
	INLINE
		
	if(is_real(surface)) 
		return surface;
	if(is_struct(surface) && struct_has(surface, "surface")) 
		return surface.surface;
	return noone;
}