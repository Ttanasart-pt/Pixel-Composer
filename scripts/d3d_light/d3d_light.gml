function __3dLight() : __3dObject() constructor {
	UI_vertex = [ array_create(33) ];
	for( var i = 0; i <= 32; i++ ) 
		UI_vertex[0][i] = new __vertex(0, lengthdir_x(0.5, i / 32 * 360), lengthdir_y(0.5, i / 32 * 360), c_white);
	VB_UI = build(noone, UI_vertex);
	
	color = c_white;
	intensity = 1;
	
	shadow_mapper = sh_d3d_shadow_depth;
	shadow_active = false;
	shadow_map    = noone;
	shadow_map_size   = 1024;
	shadow_map_scale  = 4;
	shadow_map_camera = camera_create();
	shadow_map_view   = array_create(16, 0);
	shadow_map_proj   = array_create(16, 0);
	shadow_bias	  = 0.001;
	
	static getCenter = function() /*=>*/ {return new __vec3(transform.position.x, transform.position.y, transform.position.z)};
	static getBBOX   = function() /*=>*/ {return new __bbox3D(new __vec3(-1,-1,-1), new __vec3(1,1,1))};
	
	////- Submit
	
	static submitVertex = function(_sc = noone, _sh = noone, _selection = false) {
		preSubmitVertex(_sc);
		
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		draw_set_color_alpha(c_white, 1);
		
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			if(VB[i] == noone) continue;
			
			shader_set_c("obj_color", color );
			
			var _mat = array_safe_get_fast(VBM, i, undefined);
			if(is_array(_mat)) { matrix_stack_push(_mat); matrix_set(matrix_world, matrix_stack_top()); }
			vertex_submit(VB[i], render_type, -1);
			if(is_array(_mat)) { matrix_stack_pop();      matrix_set(matrix_world, matrix_stack_top()); }
		}
		
		gpu_set_tex_filter(false);
		gpu_set_tex_repeat(false);
		
		if(!is_undefined(_sh)) shader_reset();
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		postSubmitVertex(_sc);
	}
	
	////- Shadow
	
	static setShadow = function(active, shadowMapSize, shadowMapScale = shadow_map_scale) {
		shadow_active    = active;
		shadow_map_size  = shadowMapSize;
		shadow_map_scale = shadowMapScale;
		return self;
	}
	
	static shadowProjectBegin = function() {}
	
	static shadowProjectEnd = function() {} 
	
	static submitShadow = function(scene, objects) {
		if(!shadow_active) return;
		
		shadowProjectBegin();
		objects.submit(scene, shadow_mapper);
		shadowProjectEnd();
	}
}