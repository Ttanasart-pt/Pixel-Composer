function __3dLightDirectional() : __3dLight() constructor {
	vertex		= [[ new __vertex(1, 0, 0, c_white), new __vertex(3, 0, 0, c_white) ]];
	VF		    = global.VF_POS_COL;
	render_type = pr_linelist;
	VB			= build();
	
	color     = c_white;
	intensity = 1;
	transform.position.set(4, 0, 0);
	transform.scale.set(0.6);
	transform.applyMatrix();
	
	shadow_mapper = sh_d3d_shadow_depth;
	
	static submitSel = function(params = {}) {
		shader_set(sh_d3d_wireframe);
		shader_set_color("blend", color);
		
		preSubmitVertex(params); 
		shader_reset();
	}
	
	static submitShader = function(params = {}) { params.addLightDirectional(self); }
	
	static preSubmitVertex = function(params = {}) {
		var _rot = new __rot3(0, 0, 0).lookAt(transform.position, params.camera.position);
		
		var rot = matrix_build(0, 0, 0, 
							   _rot.x, _rot.y, _rot.z, 
							   1, 1, 1);
		var sca = matrix_build(0, 0, 0, 
							   0, 0, 0, 
							   transform.scale.x, transform.scale.y, transform.scale.z);
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
		matrix_stack_pop();
		matrix_stack_pop();
		
		matrix_set(matrix_world, matrix_build_identity());
	}
	
	static shadowProjectBegin = function() {
		shadow_map = surface_verify(shadow_map, shadow_map_size, shadow_map_size, OS == os_macosx? surface_rgba8unorm : surface_r32float);
		
		shadow_map_view = matrix_build_lookat(transform.position.x, transform.position.y, transform.position.z, 0, 0, 0, 0, 0, -1);
		shadow_map_proj = matrix_build_projection_ortho(shadow_map_scale, shadow_map_scale, .01, 100);
		
		surface_set_target(shadow_map);
		draw_clear(c_black);
		shader_set(shadow_mapper);
		shader_set_i("use_8bit",  OS == os_macosx);
		
		gpu_set_ztestenable(true);
		gpu_set_cullmode(cull_counterclockwise);
		
		camera_set_view_mat(shadow_map_camera, shadow_map_view);
		camera_set_proj_mat(shadow_map_camera, shadow_map_proj);
		camera_apply(shadow_map_camera);
	}
	
	static shadowProjectEnd = function() {
		shader_reset();
		surface_reset_target();
		camera_apply(0);
		
		gpu_set_ztestenable(false);
	}
}