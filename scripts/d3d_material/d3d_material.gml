function __d3dMaterial(surface = noone) constructor {
	self.surface   = surface;
	self.diffuse   = 1;
	self.specular  = 0;
	self.metalic   = false;
	self.shine     = 1;
	
	static getTexture = function() {
		if(!is_surface(surface)) return -1;
		return surface_get_texture(surface);
	}
}