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
	
	static clone = function(replaceSurface = surface) {
		var _mat = new __d3dMaterial(replaceSurface);
		
		_mat.diffuse   = diffuse;
		_mat.specular  = specular;
		_mat.metalic   = metalic;
		_mat.shine     = shine;
	
		_mat.normal    = normal;
		_mat.normalStr = normalStr;
	
		_mat.reflective = reflective;
		_mat.texFilter  = texFilter;
		
		return _mat;
	}
	
	static serialize = function() {
		var s = { 
			diffuse,
			specular,  
			metalic,   
			shine,     
			
			normalStr, 
			
			reflective,
			texFilter, 
		};
			
		return json_stringify(s, false);
	}
	
	static deserialize = function(str) {
		var s = json_try_parse(str, noone);
		if(s == noone) return;
		
		diffuse   = s.diffuse;
		specular  = s.specular;
		metalic   = s.metalic;
		shine     = s.shine;
		
		normalStr = s.normalStr;
		
		reflective = s.reflective;
		texFilter  = s.texFilter;
	}
}