function SurfaceAtlas(surface, position = [ 0, 0 ], rotation = 0, scale = [ 1, 1 ], blend = c_white, alpha = 1) constructor {
	self.surface  = new Surface(surface);
	self.position = position;
	self.rotation = rotation;
	self.scale = scale;
	self.blend = blend;
	self.alpha = alpha;
	
	static draw = function() {
		draw_surface_ext_safe(surface.get(), position[0], position[1], scale[0], scale[1], rotation, blend, alpha);
	}
	
	static clone = function() {
		return new SurfaceAtlas(surface.get(), position, rotation, scale, blend, alpha);
	}
}

function Surface(surface) constructor {
	static set = function(surface) {
		self.surface = surface;
		w = surface_get_width_safe(surface);
		h = surface_get_height_safe(surface);
		format = surface_get_format(surface);
	}
	set(surface);
	
	static get = function() { return surface; }
	
	static isValid = function() { return is_surface(surface); }
	
	static resize = function(w, h) { 
		surface_resize(surface, w, h);
		self.w = w;
		self.h = h;
		return self;
	}
	
	static draw = function(x, y, xs = 1, ys = 1, rot = 0, col = c_white, alpha = 1) { 
		draw_surface_ext_safe(surface, x, y, xs, ys, rot, col, alpha);
		return self; 
	}
	
	static drawStretch = function(x, y, w = 1, h = 1, rot = 0, col = c_white, alpha = 1) { 
		draw_surface_stretched_ext(surface, x, y, w, h, col, alpha);
		return self; 
	}
	
	static destroy = function() {
		if(!isValid()) return;
		surface_free(surface);
	}
}

function Surface_get(surface) {
	if(is_real(surface)) 
		return surface;
	if(is_struct(surface) && struct_has(surface, "surface")) 
		return surface.surface;
	return noone;
}