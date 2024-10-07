function __3dLightPoint() : __3dLight() constructor {
	color     = c_white;
	intensity = 1;
	radius    = 10;
	
	shadow_mapper	= sh_d3d_shadow_depth;
	shadow_map_size = 512;
	
	shadow_map_views = array_create(6);
	shadow_maps      = array_create(6);
	
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		shader_set_color("blend", color);
		preSubmitVertex(params); 
		shader_reset();
	}
	
	static submitShader = function(params = {}) { params.addLightPoint(self); }
	
	static preSubmitVertex = function(params = {}) {
		var _rot = new __rot3(0, 0, 0).lookAt(transform.position, params.camera.position);
		
		var rot = matrix_build(0, 0, 0, 
							   _rot.x, _rot.y, _rot.z, 
							   1, 1, 1);
		var sca = matrix_build(0, 0, 0, 
							   0, 0, 0, 
							   0.6, 0.6, 0.6);
		var ran = matrix_build(0, 0, 0, 
							   0, 0, 0, 
							   radius * 2, radius * 2, radius * 2);
		var pos = matrix_build(transform.position.x, transform.position.y, transform.position.z, 
							   0, 0, 0, 
							   1, 1, 1);
		
		matrix_stack_push(pos);
		matrix_stack_push(rot);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI[0], pr_linestrip, -1);
		
		matrix_stack_push(sca);
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI[0], pr_linestrip, -1);
		matrix_stack_pop();
		
		matrix_stack_push(ran);
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI[0], pr_linestrip, -1);
		matrix_stack_pop();
		
		matrix_stack_pop();
		matrix_stack_pop();
		
		matrix_set(matrix_world, matrix_build_identity());
	}
	
	static shadowProjectBegin = function(index = 0) {
		//print($"Projecting cube face {index} to {shadow_maps[index]} with view {shadow_map_views[index]}")
		surface_set_target(shadow_maps[index]);
		
		draw_clear(c_black);
		shader_set(shadow_mapper);
		shader_set_i("use_8bit",  OS == os_macosx);
		
		gpu_set_ztestenable(true);
		gpu_set_cullmode(cull_counterclockwise);
		
		camera_set_view_mat(shadow_map_camera, shadow_map_views[index]);
		camera_set_proj_mat(shadow_map_camera, shadow_map_proj);
		camera_apply(shadow_map_camera);
		BLEND_OVERRIDE
	}
	
	static shadowProjectEnd = function() {
		BLEND_NORMAL
		camera_apply(0);
		shader_reset();
		surface_reset_target();
		
		gpu_set_ztestenable(false);
	}
	
	static submitShadow = function(scene, objects) {
		if(!shadow_active) return;
		
		for( var i = 0; i < 6; i++ ) 
			shadow_maps[i] = surface_verify(shadow_maps[i], shadow_map_size, shadow_map_size, surface_r32float);
		
		var position = transform.position;
		var _x = position.x;
		var _y = position.y;
		var _z = position.z;
		
		shadow_map_views    = array_verify(shadow_map_views, 6);
		shadow_map_views[0] = matrix_build_lookat(_x, _y, _z, _x + 1, _y, _z, 0, 0, -1);
		shadow_map_views[1] = matrix_build_lookat(_x, _y, _z, _x - 1, _y, _z, 0, 0, -1);
		shadow_map_views[2] = matrix_build_lookat(_x, _y, _z, _x, _y + 1, _z, 0, 0, -1);
		shadow_map_views[3] = matrix_build_lookat(_x, _y, _z, _x, _y - 1, _z, 0, 0, -1);
		shadow_map_views[4] = matrix_build_lookat(_x, _y, _z, _x, _y, _z + 1, 0,  1, 0);
		shadow_map_views[5] = matrix_build_lookat(_x, _y, _z, _x, _y, _z - 1, 0, -1, 0);
		
		shadow_map_view = array_merge( shadow_map_views[0], shadow_map_views[1], shadow_map_views[2], shadow_map_views[3], shadow_map_views[4], shadow_map_views[5] );
		shadow_map_proj = matrix_build_projection_perspective_fov(90, 1, .01, radius);
		
		for( var j = 0; j < 6; j++ ) {
			shadowProjectBegin(j);
			objects.submit(scene, shadow_mapper);
			shadowProjectEnd();
		}
		
		shadow_map = surface_verify(shadow_map, shadow_map_size * 2, shadow_map_size, surface_rgba32float);
		
		surface_set_target(shadow_map);
			draw_clear_alpha(c_black, 1.);
			gpu_set_blendmode_ext(bm_one, bm_one);
			
			shader_set(sh_channel_R2R);
			draw_surface(shadow_maps[0], 0, 0);
			draw_surface(shadow_maps[3], shadow_map_size, 0);
			shader_reset();
			
			shader_set(sh_channel_R2G);
			draw_surface(shadow_maps[1], 0, 0);
			draw_surface(shadow_maps[4], shadow_map_size, 0);
			shader_reset();
			
			shader_set(sh_channel_R2B);
			draw_surface(shadow_maps[2], 0, 0);
			draw_surface(shadow_maps[5], shadow_map_size, 0);
			shader_reset();
			
			BLEND_NORMAL
		__surface_reset_target();
	}
}