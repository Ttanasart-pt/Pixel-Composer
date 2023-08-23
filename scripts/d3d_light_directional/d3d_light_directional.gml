function __3dLightDirectional() : __3dLight() constructor {
	vertex		= [[ V3(1, 0, 0, c_yellow, 0.8), V3(3, 0, 0, c_yellow, 0.8) ]];
	VF		    = global.VF_POS_COL;
	render_type = pr_linelist;
	VB			= build();
	
	color     = c_white;
	intensity = 1;
	position.set(4, 0, 0);
	
	shadow_mapper = sh_d3d_shadow_depth;
	
	static submitSel = function(params = {}) { #region
		shader_set(sh_d3d_wireframe);
		preSubmitVertex(params); 
		shader_reset();
	} #endregion
	
	static submitShader = function(params = {}) { params.addLightDirectional(self); }
	
	static preSubmitVertex = function(params = {}) { #region
		var _rot = new __rot3(0, 0, 0).lookAt(position, params.camera.position);
		
		var rot = matrix_build(0, 0, 0, 
							   _rot.x, _rot.y, _rot.z, 
							   1, 1, 1);
		var sca = matrix_build(0, 0, 0, 
							   0, 0, 0, 
							   0.6, 0.6, 0.6);
		var pos = matrix_build(position.x, position.y, position.z, 
							   0, 0, 0, 
							   1, 1, 1);
		
		matrix_stack_clear();
		matrix_stack_push(pos);
		matrix_stack_push(rot);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI[0], pr_linestrip, -1);
		
		matrix_stack_push(sca);
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI[0], pr_linestrip, -1);
		
		matrix_stack_clear();
		matrix_set(matrix_world, matrix_build_identity());
	} #endregion
	
	static shadowProjectBegin = function() { #region
		shadow_map = surface_verify(shadow_map, shadow_map_size, shadow_map_size, surface_r32float);
		
		shadow_map_view = matrix_build_lookat(position.x, position.y, position.z, 0, 0, 0, 0, 0, -1);
		shadow_map_proj = matrix_build_projection_ortho(shadow_map_scale, shadow_map_scale, .01, 100);
		
		surface_set_target(shadow_map);
		draw_clear(c_black);
		shader_set(shadow_mapper);
		gpu_set_ztestenable(true);
		
		camera_set_view_mat(shadow_map_camera, shadow_map_view);
		camera_set_proj_mat(shadow_map_camera, shadow_map_proj);
		camera_apply(shadow_map_camera);
	} #endregion
	
	static shadowProjectEnd = function() { #region
		shader_reset();
		surface_reset_target();
		camera_apply(0);
		gpu_set_ztestenable(false);
	} #endregion
}