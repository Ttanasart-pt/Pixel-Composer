function __3dGizmo() : __3dObject() constructor {
	vertex = [];
	
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		shader_set_color("blend", c_white);
		submitVertex(params); 
		shader_reset();
	}
}