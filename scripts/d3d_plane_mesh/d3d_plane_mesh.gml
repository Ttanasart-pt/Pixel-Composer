function __3dPlane() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	static initModel = function(size) {
		size /= 2;
		
		vertex = [
			V3(-size, -size, 0), V3(size, -size, 0), V3(size, size,  0),
			V3(-size, -size, 0), V3(size,  size, 0), V3(-size, size, 0),
		];
	
		normals = [
			[0, 0, 1], [0, 0, 1], [0, 0, 1],
			[0, 0, 1], [0, 0, 1], [0, 0, 1],
		];
		
		uv = [
			[0, 0], [1, 0], [1, 1],
			[0, 0], [1, 1], [0, 1],
		];
		
		array_foreach(vertex, function(val, ind) { val.normal.set(normals[ind]); val.uv.set(uv[ind]); })
	
		VB = build();
	} initModel(1);
}