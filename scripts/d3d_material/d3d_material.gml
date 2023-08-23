function __d3dMaterial(surface = noone, roughness = 0) constructor {
	self.roughness = roughness;
	self.surface = surface;
	
	static getTexture = function() {
		if(!is_surface(surface)) return -1;
		return surface_get_texture(surface);
	}
}