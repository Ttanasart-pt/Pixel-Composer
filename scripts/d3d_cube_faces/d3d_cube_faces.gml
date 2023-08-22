function __3dCubeFaces() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	object_counts = 6;
	
	static initModel = function(size) {
		size /= 2;
		
		vertex = [
		    [
				V3(-size, -size, size), V3(size, -size, size), V3(size, size, size),
			    V3(-size, -size, size), V3(size, size, size), V3(-size, size, size),
			], 
			[
			    V3(-size, -size, -size), V3(size, -size, -size), V3(size, size, -size),
			    V3(-size, -size, -size), V3(size, size, -size), V3(-size, size, -size),
			],
			[
			    V3(-size, -size, size), V3(-size, size, size), V3(-size, size, -size),
			    V3(-size, -size, size), V3(-size, size, -size), V3(-size, -size, -size),
			],
			[
			    V3(size, -size, size), V3(size, size, size), V3(size, size, -size),
			    V3(size, -size, size), V3(size, size, -size), V3(size, -size, -size),
			],
			[
			    V3(-size, size, size), V3(size, size, size), V3(size, size, -size),
			    V3(-size, size, size), V3(size, size, -size), V3(-size, size, -size),
			],
			[
			    V3(-size, -size, size), V3(size, -size, size), V3(size, -size, -size),
			    V3(-size, -size, size), V3(size, -size, -size), V3(-size, -size, -size)
			]
		];
	
		normals = [
			[
			    [0, 0, 1], [0, 0, 1], [0, 0, 1],
			    [0, 0, 1], [0, 0, 1], [0, 0, 1],
			],
			[
			    [0, 0, -1], [0, 0, -1], [0, 0, -1],
			    [0, 0, -1], [0, 0, -1], [0, 0, -1],
			],
			[
			    [-1, 0, 0], [-1, 0, 0], [-1, 0, 0],
			    [-1, 0, 0], [-1, 0, 0], [-1, 0, 0],
			],
			[
			    [1, 0, 0], [1, 0, 0], [1, 0, 0],
			    [1, 0, 0], [1, 0, 0], [1, 0, 0],
			],
			[
			    [0, 1, 0], [0, 1, 0], [0, 1, 0],
			    [0, 1, 0], [0, 1, 0], [0, 1, 0],
			],
			[
			    [0, -1, 0], [0, -1, 0], [0, -1, 0],
			    [0, -1, 0], [0, -1, 0], [0, -1, 0]
			]
		];
		
		uv = [
			[
				[0, 0], [1, 0], [1, 1],
			    [0, 0], [1, 1], [0, 1],
			],
			[
			    [0, 0], [1, 0], [1, 1],
			    [0, 0], [1, 1], [0, 1],
			],
			[
			    [0, 0], [1, 0], [1, 1],
			    [0, 0], [1, 1], [0, 1],
			],
			[
			    [0, 0], [1, 0], [1, 1],
			    [0, 0], [1, 1], [0, 1],
			],
			[
			    [0, 0], [1, 0], [1, 1],
			    [0, 0], [1, 1], [0, 1],
			],
			[
			    [0, 0], [1, 0], [1, 1],
			    [0, 0], [1, 1], [0, 1]
			]
		];
		
		array_foreach(vertex[0], function(val, ind) { val.normal.set(normals[0][ind]); val.uv.set(uv[0][ind]); })
		array_foreach(vertex[1], function(val, ind) { val.normal.set(normals[1][ind]); val.uv.set(uv[1][ind]); })
		array_foreach(vertex[2], function(val, ind) { val.normal.set(normals[2][ind]); val.uv.set(uv[2][ind]); })
		array_foreach(vertex[3], function(val, ind) { val.normal.set(normals[3][ind]); val.uv.set(uv[3][ind]); })
		array_foreach(vertex[4], function(val, ind) { val.normal.set(normals[4][ind]); val.uv.set(uv[4][ind]); })
		array_foreach(vertex[5], function(val, ind) { val.normal.set(normals[5][ind]); val.uv.set(uv[5][ind]); })
	
		VB = build();
	} initModel(1);
}