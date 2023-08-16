function __3dScene(camera) constructor {
	self.camera = camera;
	name = "New scene";
	
	lightAmbient = c_black;
	lightDir_count     = 0;
	lightDir_direction = [];
	lightDir_color     = [];
	lightDir_intensity = [];
	
	lightPnt_count     = 0;
	lightPnt_position  = [];
	lightPnt_color     = [];
	lightPnt_intensity = [];
	lightPnt_radius    = [];
	
	static reset = function() {
		lightDir_count     = 0;
		lightDir_direction = [];
		lightDir_color     = [];
		lightDir_intensity = [];
	
		lightPnt_count     = 0;
		lightPnt_position  = [];
		lightPnt_color     = [];
		lightPnt_intensity = [];
		lightPnt_radius    = [];
	}
	
	static apply = function() {
		shader_set(sh_d3d_default);
			shader_set_f("light_ambient", colToVec4(lightAmbient));
			
			shader_set_i("light_dir_count",		lightDir_count);
			shader_set_f("light_dir_direction", lightDir_direction);
			shader_set_f("light_dir_color",		lightDir_color);
			shader_set_f("light_dir_intensity", lightDir_intensity);
			
			shader_set_i("light_pnt_count",		lightPnt_count);
			shader_set_f("light_pnt_position",  lightPnt_position);
			shader_set_f("light_pnt_color",		lightPnt_color);
			shader_set_f("light_pnt_intensity", lightPnt_intensity);
			shader_set_f("light_pnt_radius",    lightPnt_radius);
			
			//print($"Scene {name} submit {lightPnt_position} point lights");
		shader_reset();
	}
	
	static addLightDirectional = function(light) {
		array_append(lightDir_direction, [ light.position.x, light.position.y, light.position.z ]);
		array_append(lightDir_color,     colToVec4(light.color));
		array_append(lightDir_intensity, [ light.intensity ]);
		lightDir_count++;
		
		return self;
	}
	
	static addLightPoint = function(light) {
		array_append(lightPnt_position,  [ light.position.x, light.position.y, light.position.z ]);
		array_append(lightPnt_color,     colToVec4(light.color));
		array_append(lightPnt_intensity, [ light.intensity ]);
		array_append(lightPnt_radius,    [ light.radius ]);
		lightPnt_count++;
		
		return self;
	}
}