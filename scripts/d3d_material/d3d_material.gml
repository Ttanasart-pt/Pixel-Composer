function __d3dMaterial(s = noone) constructor {
	surface   = s;
	
	texScale  = [ 1, 1 ];
	texShift  = [ 0, 0 ];
	texFilter = false;
	
	diffuse    = 1;
	specular   = 0;
	metalic    = false;
	shine      = 1;
	reflective = 0;
	
	pbr_metalic   = [0,0]; pbr_metalic_map   = false;
	pbr_roughness = [1,1]; pbr_roughness_map = false;
	pbr_properties_map = undefined;
	
	normal    = noone;
	normalStr = 1;
	
	static getSurface = function() /*=>*/ {return surface};
	static getTexture = function() /*=>*/ {return is_surface(surface)? surface_get_texture(surface) : -1};
	
	static setSurface = function(s) { surface = s; return self; }
	
	static submitGeometry = function() {
		shader_set_i("use_normal", is_surface(normal));
		
		shader_set_surface("normal_map", normal    );
		shader_set_f("normal_strength",  normalStr );
		shader_set_f("mat_texScale",     texScale  );
		shader_set_f("mat_texShift",     texShift  );
	}
	
	static submitShader = function() {
		shader_set_f("mat_texScale",   texScale   );
		shader_set_f("mat_texShift",   texShift   );
		gpu_set_tex_filter(texFilter);
		
		//// =Phong
		shader_set_f("mat_diffuse",    diffuse    );
		shader_set_f("mat_specular",   specular   );
		shader_set_f("mat_shine",      shine      );
		shader_set_i("mat_metalic",    metalic    );
		shader_set_f("mat_reflective", reflective );
		
		//// =PBR
		shader_set_f("mat_pbr_metalic",           pbr_metalic        );
		shader_set_f("mat_pbr_roughness",         pbr_roughness      );
		
		shader_set_i("mat_pbr_metalic_use_map",   pbr_metalic_map    );
		shader_set_i("mat_pbr_roughness_use_map", pbr_roughness_map  );
	
		shader_set_s("mat_pbr_properties_map",    pbr_properties_map );
	}
	
	static clone = function(_surf = surface) { 
		var mat = variable_clone(self, 1); 
		mat.surface = _surf;
		
		return mat;
	}
	
	static serialize = function() {
		var s = { 
			texScale,
			texShift,
			texFilter, 
			
			diffuse,
			specular,  
			metalic,   
			shine,     
			reflective,
			
			pbr_metalic,   pbr_metalic_map, 
			pbr_roughness, pbr_roughness_map, 
			
			normalStr, 
		};
			
		return json_stringify(s, false);
	}
	
	static deserialize = function(str) {
		var s = json_try_parse(str, noone);
		if(s == noone) return;
		
		// struct_override(self, s);
		
		texScale   = s[$ "texScale"]   ?? texScale;
		texShift   = s[$ "texShift"]   ?? texShift;
		texFilter  = s[$ "texFilter"]  ?? texFilter;
		
		diffuse    = s[$ "diffuse"]    ?? diffuse;
		specular   = s[$ "specular"]   ?? specular;
		metalic    = s[$ "metalic"]    ?? metalic;
		shine      = s[$ "shine"]      ?? shine;
		reflective = s[$ "reflective"] ?? reflective;
		
		pbr_metalic       = s[$ "pbr_metalic"]       ?? pbr_metalic;
		pbr_metalic_map   = s[$ "pbr_metalic_map"]   ?? pbr_metalic_map;
		pbr_roughness     = s[$ "pbr_roughness"]     ?? pbr_roughness;
		pbr_roughness_map = s[$ "pbr_roughness_map"] ?? pbr_roughness_map;
		
		normalStr  = s[$ "normalStr"]  ?? normalStr;
	}
}