function __3dCubeFaces() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	static initModel = function(size) {
		size /= 2;
		
		vertex = [
		    [
				[-size, -size, size], [size, -size, size], [size, size, size],
			    [-size, -size, size], [size, size, size], [-size, size, size],
			], 
			[
			    [-size, -size, -size], [size, -size, -size], [size, size, -size],
			    [-size, -size, -size], [size, size, -size], [-size, size, -size],
			],
			[
			    [-size, -size, size], [-size, size, size], [-size, size, -size],
			    [-size, -size, size], [-size, size, -size], [-size, -size, -size],
			],
			[
			    [size, -size, size], [size, size, size], [size, size, -size],
			    [size, -size, size], [size, size, -size], [size, -size, -size],
			],
			[
			    [-size, size, size], [size, size, size], [size, size, -size],
			    [-size, size, size], [size, size, -size], [-size, size, -size],
			],
			[
			    [-size, -size, size], [size, -size, size], [size, -size, -size],
			    [-size, -size, size], [size, -size, -size], [-size, -size, -size]
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
	
		VB = build();
	} initModel(1);
}