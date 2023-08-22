function __3dCube() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	static initModel = function(size) {
		size /= 2;
		
		vertex = [
		    V3(-size, -size, size), V3(size, -size, size), V3(size, size, size),
		    V3(-size, -size, size), V3(size, size, size), V3(-size, size, size),
			
		    V3(-size, -size, -size), V3(size, -size, -size), V3(size, size, -size),
		    V3(-size, -size, -size), V3(size, size, -size), V3(-size, size, -size),
    
		    V3(-size, -size, size), V3(-size, size, size), V3(-size, size, -size),
		    V3(-size, -size, size), V3(-size, size, -size), V3(-size, -size, -size),
    
		    V3(size, -size, size), V3(size, size, size), V3(size, size, -size),
		    V3(size, -size, size), V3(size, size, -size), V3(size, -size, -size),
    
		    V3(-size, size, size), V3(size, size, size), V3(size, size, -size),
		    V3(-size, size, size), V3(size, size, -size), V3(-size, size, -size),
    
		    V3(-size, -size, size), V3(size, -size, size), V3(size, -size, -size),
		    V3(-size, -size, size), V3(size, -size, -size), V3(-size, -size, -size)
		];
	
		normals = [
		    [0, 0, 1], [0, 0, 1], [0, 0, 1],
		    [0, 0, 1], [0, 0, 1], [0, 0, 1],
    
		    [0, 0, -1], [0, 0, -1], [0, 0, -1],
		    [0, 0, -1], [0, 0, -1], [0, 0, -1],
    
		    [-1, 0, 0], [-1, 0, 0], [-1, 0, 0],
		    [-1, 0, 0], [-1, 0, 0], [-1, 0, 0],
    
		    [1, 0, 0], [1, 0, 0], [1, 0, 0],
		    [1, 0, 0], [1, 0, 0], [1, 0, 0],
    
		    [0, 1, 0], [0, 1, 0], [0, 1, 0],
		    [0, 1, 0], [0, 1, 0], [0, 1, 0],
    
		    [0, -1, 0], [0, -1, 0], [0, -1, 0],
		    [0, -1, 0], [0, -1, 0], [0, -1, 0]
		];
		
		uv = [
			[0, 0], [1, 0], [1, 1],
		    [0, 0], [1, 1], [0, 1],

		    [0, 0], [1, 0], [1, 1],
		    [0, 0], [1, 1], [0, 1],

		    [0, 0], [1, 0], [1, 1],
		    [0, 0], [1, 1], [0, 1],

		    [0, 0], [1, 0], [1, 1],
		    [0, 0], [1, 1], [0, 1],

		    [0, 0], [1, 0], [1, 1],
		    [0, 0], [1, 1], [0, 1],

		    [0, 0], [1, 0], [1, 1],
		    [0, 0], [1, 1], [0, 1]
		];
		
		array_foreach(vertex, function(val, ind) { val.setNormal(normals[ind]); val.setUV(uv[ind]); })
	
		VB = build();
	} initModel(1);
}