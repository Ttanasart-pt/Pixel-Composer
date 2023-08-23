function __3dCube() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	static initModel = function(size) {
		size /= 2;
		
		vertex = [[
			V3(-size, -size,  size).setNormal(0, 0, 1).setUV(0, 0), 
			V3( size,  size,  size).setNormal(0, 0, 1).setUV(1, 0), 
			V3( size, -size,  size).setNormal(0, 0, 1).setUV(1, 1),
		    
			V3(-size, -size,  size).setNormal(0, 0, 1).setUV(0, 0), 
			V3(-size,  size,  size).setNormal(0, 0, 1).setUV(1, 1), 
			V3( size,  size,  size).setNormal(0, 0, 1).setUV(0, 1),
			
		    
			V3(-size, -size, -size).setNormal(0, 0, -1).setUV(0, 0), 
			V3( size, -size, -size).setNormal(0, 0, -1).setUV(1, 0), 
			V3( size,  size, -size).setNormal(0, 0, -1).setUV(1, 1),
		    
			V3(-size, -size, -size).setNormal(0, 0, -1).setUV(0, 0), 
			V3( size,  size, -size).setNormal(0, 0, -1).setUV(1, 1), 
			V3(-size,  size, -size).setNormal(0, 0, -1).setUV(0, 1),
			
		    
			V3(-size, -size,  size).setNormal(-1, 0, 0).setUV(0, 0), 
			V3(-size,  size, -size).setNormal(-1, 0, 0).setUV(1, 0), 
			V3(-size,  size,  size).setNormal(-1, 0, 0).setUV(1, 1),
		    
			V3(-size, -size,  size).setNormal(-1, 0, 0).setUV(0, 0), 
			V3(-size, -size, -size).setNormal(-1, 0, 0).setUV(1, 1), 
			V3(-size,  size, -size).setNormal(-1, 0, 0).setUV(0, 1),
			
		    
			V3( size, -size,  size).setNormal(1, 0, 0).setUV(0, 0), 
			V3( size,  size,  size).setNormal(1, 0, 0).setUV(1, 0), 
			V3( size,  size, -size).setNormal(1, 0, 0).setUV(1, 1),
		    
			V3( size, -size,  size).setNormal(1, 0, 0).setUV(0, 0), 
			V3( size,  size, -size).setNormal(1, 0, 0).setUV(1, 1), 
			V3( size, -size, -size).setNormal(1, 0, 0).setUV(0, 1),
			
		    
			V3(-size,  size,  size).setNormal(0, 1, 0).setUV(0, 0), 
			V3( size,  size, -size).setNormal(0, 1, 0).setUV(1, 0), 
			V3( size,  size,  size).setNormal(0, 1, 0).setUV(1, 1),
		    
			V3(-size,  size,  size).setNormal(0, 1, 0).setUV(0, 0), 
			V3(-size,  size, -size).setNormal(0, 1, 0).setUV(1, 1), 
			V3( size,  size, -size).setNormal(0, 1, 0).setUV(0, 1),
    
		    
			V3(-size, -size,  size).setNormal(0, -1, 0).setUV(0, 0), 
			V3( size, -size,  size).setNormal(0, -1, 0).setUV(1, 0), 
			V3( size, -size, -size).setNormal(0, -1, 0).setUV(1, 1),
		    
			V3(-size, -size,  size).setNormal(0, -1, 0).setUV(0, 0), 
			V3( size, -size, -size).setNormal(0, -1, 0).setUV(1, 1), 
			V3(-size, -size, -size).setNormal(0, -1, 0).setUV(0, 1), 
		]];
	
		VB = build();
		generateNormal();
	} initModel(1);
}