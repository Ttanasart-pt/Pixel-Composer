function __3dCubeFaces() : __3dCube() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 6;
	
	static initModel = function() {
		
		vertex = __default_cube();
		VB = build();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}