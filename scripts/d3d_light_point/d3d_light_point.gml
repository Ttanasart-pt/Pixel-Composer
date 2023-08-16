function __3dLightPoint() : __3dLight() constructor {
	color     = c_white;
	intensity = 1;
	radius    = 10;
	
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		preSubmitVertex(params); 
		shader_reset();
	}
	
	static submitShader = function(params = {}) { params.addLightPoint(self); }
	
	static preSubmitVertex = function(params = {}) {
		var _rot = new __rot3(0, 0, 0).lookAt(position, params.camera.position);
		
		var rot = matrix_build(0, 0, 0, 
							   _rot.x, _rot.y, _rot.z, 
							   1, 1, 1);
		var sca = matrix_build(0, 0, 0, 
							   0, 0, 0, 
							   0.6, 0.6, 0.6);
		var ran = matrix_build(0, 0, 0, 
							   0, 0, 0, 
							   radius * 2, radius * 2, radius * 2);
		var pos = matrix_build(position.x, position.y, position.z, 
							   0, 0, 0, 
							   1, 1, 1);
		
		matrix_stack_clear();
		matrix_stack_push(pos);
		matrix_stack_push(rot);
		
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI, pr_linestrip, -1);
		
		matrix_stack_push(sca);
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI, pr_linestrip, -1);
		matrix_stack_pop();
		
		matrix_stack_push(ran);
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI, pr_linestrip, -1);
		matrix_stack_pop();
		
		matrix_stack_clear();
		matrix_set(matrix_world, matrix_build_identity());
	}
}