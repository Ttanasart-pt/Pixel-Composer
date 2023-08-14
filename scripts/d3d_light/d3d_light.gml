function __3dLight() : __3dObject() constructor {
	UI_vertex = [];
	for( var i = 0; i <= 32; i++ ) 
		UI_vertex[i] = [ 0, lengthdir_x(0.5, i / 32 * 360), lengthdir_y(0.5, i / 32 * 360), c_yellow, 0.8 ];
	VB_UI = build(noone, UI_vertex);
	
	color = c_white;
	intensity = 1;
	
	static presubmit = function(params = {}) {
		var _rot = new __rot3(0, 0, 0).lookAt(position, params.cameraPosition);
		
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
		vertex_submit(VB_UI, pr_linestrip, -1);
		
		matrix_stack_push(sca);
		matrix_set(matrix_world, matrix_stack_top());
		vertex_submit(VB_UI, pr_linestrip, -1);
		
		matrix_stack_clear();
		matrix_set(matrix_world, matrix_build_identity());
	}
	
	static shine = function(params = {}) {}
}