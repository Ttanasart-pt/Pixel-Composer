function __d3dMaterial(surface = noone) constructor {
	self.surface   = surface;
	
	self.diffuse   = 1;
	self.specular  = 0;
	self.metalic   = false;
	self.shine     = 1;
	
	self.normal    = noone;
	self.normalStr = 1;
	
	self.reflective = 0;
	
	static getTexture = function() {
		if(!is_surface(surface)) return -1;
		return surface_get_texture(surface);
	}
	
	static submitShader = function() {
		shader_set_f("mat_diffuse",  diffuse  );
		shader_set_f("mat_specular", specular );
		shader_set_f("mat_shine",    shine    );
		shader_set_i("mat_metalic",  metalic  );
		
		shader_set_i("mat_use_normal", is_surface(normal));
		shader_set_surface("mat_normal_map", normal);
		shader_set_f("mat_normal_strength", normalStr);
		
		shader_set_f("mat_reflective", reflective);
	}
}