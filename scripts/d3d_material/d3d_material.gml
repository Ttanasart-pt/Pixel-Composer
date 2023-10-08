function __d3dMaterial(surface = noone) constructor {
	self.surface   = surface;
	
	diffuse   = 1;
	specular  = 0;
	metalic   = false;
	shine     = 1;
	
	normal    = noone;
	normalStr = 1;
	
	reflective = 0;
	texFilter  = false;
	
	static getTexture = function() {
		if(!is_surface(surface)) return -1;
		return surface_get_texture(surface);
	}
	
	static submitGeometry = function() {
		shader_set_i("use_normal", is_surface(normal));
		shader_set_surface("normal_map", normal);
		shader_set_f("normal_strength", normalStr);
	}
	
	static submitShader = function() {
		shader_set_f("mat_diffuse",  diffuse  );
		shader_set_f("mat_specular", specular );
		shader_set_f("mat_shine",    shine    );
		shader_set_i("mat_metalic",  metalic  );
		
		shader_set_f("mat_reflective", reflective);
		gpu_set_tex_filter(texFilter);
	}
	
	static clone = function() {
		var _mat = new __d3dMaterial();
		
		_mat.surface   = surface;
	
		_mat.diffuse   = diffuse;
		_mat.specular  = specular;
		_mat.metalic   = metalic;
		_mat.shine     = shine;
	
		_mat.normal    = normal;
		_mat.normalStr = normalStr;
	
		_mat.reflective = reflective;
		
		return _mat;
	}
}