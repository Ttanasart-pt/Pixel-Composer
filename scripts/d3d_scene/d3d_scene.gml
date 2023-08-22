#region global preview camera
	globalvar D3D_GLOBAL_PREVIEW;
	
	function set3DGlobalPreview() {
		var d3_view_camera = new __3dCamera();
		d3_view_camera.setViewSize(2, 2);
		d3_view_camera.setFocusAngle(135, 45, 8);
		d3_view_camera.position.set(calculate_3d_position(0, 0, 0, d3_view_camera.focus_angle_x, d3_view_camera.focus_angle_y, d3_view_camera.focus_dist));
		
		d3_view_camera.projection = CAMERA_PROJECTION.orthograph;
		d3_view_camera.setMatrix();
		
		D3D_GLOBAL_PREVIEW = new __3dScene(d3_view_camera);
		D3D_GLOBAL_PREVIEW.apply_transform = false;
	
		var d3_scene_light0 = new __3dLightDirectional();
		d3_scene_light0.position.set(-1, -2, 3);
		d3_scene_light0.color  = $AAAAAA;
		
		var d3_scene_light1 = new __3dLightDirectional();
		d3_scene_light1.position.set(1, 2, 3);
		d3_scene_light1.color  = $FFFFFF;
	
		D3D_GLOBAL_PREVIEW.lightAmbient = $404040;
		D3D_GLOBAL_PREVIEW.addLightDirectional(d3_scene_light0);
		D3D_GLOBAL_PREVIEW.addLightDirectional(d3_scene_light1);
	}
#endregion

function __3dScene(camera) constructor {
	self.camera = camera;
	name = "New scene";
	
	apply_transform  = true;
	custom_transform = new __vec3();
	custom_scale     = new __vec3(1, 1, 1);
	
	lightAmbient = c_black;
	
	lightDir_max = 16;
	lightDir_shadow_max = 4;
	
	lightPnt_max = 16;
	lightPnt_shadow_max = 4;
	
	gammaCorrection = true;
	
	static reset = function() {
		lightDir_count     = 0;
		lightDir_direction = [];
		lightDir_color     = [];
		lightDir_intensity = [];
		
		lightDir_shadow_count = 0;
		lightDir_shadow    = [];
		lightDir_shadowMap = [];
		lightDir_viewMat   = [];
		lightDir_projMat   = [];
		lightDir_shadowBias = .001;
	
		lightPnt_count     = 0;
		lightPnt_position  = [];
		lightPnt_color     = [];
		lightPnt_intensity = [];
		lightPnt_radius    = [];
		
		lightPnt_shadow_count = 0;
		lightPnt_shadow    = [];
		lightPnt_shadowMap = [];
		lightPnt_viewMat   = [];
		lightPnt_projMat   = [];
	} reset();
	
	static applyCamera = function() { camera.applyCamera(); }
	static resetCamera = function() { camera.resetCamera(); }
	
	static apply = function() {
		shader_set(sh_d3d_default);
			shader_set_f("light_ambient", colToVec4(lightAmbient));
			
			shader_set_i("light_dir_count",		lightDir_count);
			if(lightDir_count) {
				shader_set_f("light_dir_direction", lightDir_direction);
				shader_set_f("light_dir_color",		lightDir_color);
				shader_set_f("light_dir_intensity", lightDir_intensity);
				shader_set_i("light_dir_shadow_active", lightDir_shadow);
				for( var i = 0, n = array_length(lightDir_shadowMap); i < n; i++ )
					shader_set_surface($"light_dir_shadowmap_{i}", lightDir_shadowMap[i], true);
				shader_set_f("light_dir_view",		lightDir_viewMat);
				shader_set_f("light_dir_proj",		lightDir_projMat);
				shader_set_f("shadowBias",			lightDir_shadowBias);
			}
			
			shader_set_i("light_pnt_count",		lightPnt_count);
			if(lightPnt_count) {
				shader_set_f("light_pnt_position",  lightPnt_position);
				shader_set_f("light_pnt_color",		lightPnt_color);
				shader_set_f("light_pnt_intensity", lightPnt_intensity);
				shader_set_f("light_pnt_radius",    lightPnt_radius);
				shader_set_i("light_pnt_shadow_active", lightPnt_shadow);
				for( var i = 0, n = array_length(lightPnt_shadowMap); i < n; i++ ) 
					shader_set_surface($"light_pnt_shadowmap_{i}", lightPnt_shadowMap[i], true, true);
				shader_set_f("light_pnt_view",		lightPnt_viewMat);
				shader_set_f("light_pnt_proj",		lightPnt_projMat);
			}
			
			shader_set_i("gammaCorrection",		gammaCorrection);
		shader_reset();
	}
	
	static addLightDirectional = function(light) {
		if(lightDir_count >= lightDir_max) {
			noti_warning("Direction light limit exceeded");
			return self;
		}
		
		array_append(lightDir_direction, [ light.position.x, light.position.y, light.position.z ]);
		array_append(lightDir_color,     colToVec4(light.color));
		
		array_push(lightDir_intensity, light.intensity);
		array_push(lightDir_shadow, light.shadow_active);
		
		if(light.shadow_active) {
			if(lightDir_shadow_count < lightDir_shadow_max) {
				array_push(lightDir_shadowMap, light.shadow_map);
				lightDir_shadow_count++;
			} else 
				noti_warning("Direction light shadow caster limit exceeded");
		}
		array_append(lightDir_viewMat, light.shadow_map_view);
		array_append(lightDir_projMat, light.shadow_map_proj);
		lightDir_count++;
		
		return self;
	}
	
	static addLightPoint = function(light) {
		if(lightPnt_count >= lightPnt_max) {
			noti_warning("Point light limit exceeded");
			return self;
		}
		
		array_append(lightPnt_position,  [ light.position.x, light.position.y, light.position.z ]);
		array_append(lightPnt_color,     colToVec4(light.color));
		
		array_push(lightPnt_intensity, light.intensity);
		array_push(lightPnt_radius,    light.radius);
		array_push(lightPnt_shadow,    light.shadow_active);
		
		if(light.shadow_active) {
			if(lightPnt_shadow_count < lightPnt_shadow_max) {
				array_push(lightPnt_shadowMap, light.shadow_map);
				lightPnt_shadow_count++;
			} else 
				noti_warning("Point light shadow caster limit exceeded");
		}
		array_append(lightPnt_viewMat, light.shadow_map_view);
		array_append(lightPnt_projMat, light.shadow_map_proj);
		lightPnt_count++;
		
		return self;
	}
}