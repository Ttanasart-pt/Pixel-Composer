function __3dLightDirectional() : __3dLight() constructor {
	vertex = [
		[ 1, 0, 0, c_yellow, 0.8 ], [ 3, 0, 0, c_yellow, 0.8 ]
	];
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	VB = build();
	
	color = c_white;
	intensity = 1;
	position.set(1, 0, 0);
	
	static submit    = function(params = {}, shader = noone) { shine(params); }
	static submitUI  = function(params = {}, shader = noone) { shine(params); submitVertex(params, shader); }
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		presubmit(params); 
		shader_reset();
	}
	
	static shine = function(params = {}) {
		shader_set(sh_d3d_default);
		
		shader_set_f("light_dir_direction", position.x, position.y, position.z);
		shader_set_f("light_dir_color", colToVec4(color));
		shader_set_f("light_dir_intensity", intensity);
		
		shader_reset();
	}
}