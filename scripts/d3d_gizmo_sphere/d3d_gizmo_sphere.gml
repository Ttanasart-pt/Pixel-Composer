function __3dGizmoSphere(radius = 0.5, color = c_white, alpha = 1) : __3dObject() constructor {
	vertex = array_create(33 * 3);
	
	var _i = 0;
	for( var i = 0; i <= 32; i++ ) {
		var a0 = (i + 0) / 32 * 360;
		var a1 = (i + 1) / 32 * 360;
		var x0 = lengthdir_x(radius, a0);
		var y0 = lengthdir_y(radius, a0);
		var x1 = lengthdir_x(radius, a1);
		var y1 = lengthdir_y(radius, a1);
		
		vertex[_i++] = [ 0, x0, y0, color, alpha ];
		vertex[_i++] = [ 0, x1, y1, color, alpha ];
		vertex[_i++] = [ x0, 0, y0, color, alpha ];
		vertex[_i++] = [ x1, 0, y1, color, alpha ];
		vertex[_i++] = [ x0, y0, 0, color, alpha ];
		vertex[_i++] = [ x1, y1, 0, color, alpha ];
	}
		
	VF = global.VF_POS_COL;
	render_type = pr_linelist;
	VB = build();
	
	static submitSel = function(params = {}) { 
		shader_set(sh_d3d_wireframe);
		submitVertex(params); 
		shader_reset();
	}
}