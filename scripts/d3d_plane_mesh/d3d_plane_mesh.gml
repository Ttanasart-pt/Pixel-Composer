function __3dPlane() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.side   = 0.5;
	self.normal = 0;
	
	static initModel = function() {
		var _nor = [ 0, 0, 1 ];
		switch(normal) {
			case 0 : 
				vertex = [[
					new __vertex(0, -side, -side).setNormal(1, 0, 0).setUV(0, 0), 
					new __vertex(0,  side,  side).setNormal(1, 0, 0).setUV(1, 1), 
					new __vertex(0,  side, -side).setNormal(1, 0, 0).setUV(1, 0),
					   	  
					new __vertex(0, -side, -side).setNormal(1, 0, 0).setUV(0, 0), 
					new __vertex(0, -side,  side).setNormal(1, 0, 0).setUV(0, 1), 
					new __vertex(0,  side,  side).setNormal(1, 0, 0).setUV(1, 1),
				]];
				break;	
			case 1 : 
				vertex = [[
					new __vertex(-side, 0, -side).setNormal(0, 1, 0).setUV(0, 0), 
					new __vertex( side, 0, -side).setNormal(0, 1, 0).setUV(1, 0),
					new __vertex( side, 0,  side).setNormal(0, 1, 0).setUV(1, 1), 
							
					new __vertex(-side, 0, -side).setNormal(0, 1, 0).setUV(0, 0), 
					new __vertex( side, 0,  side).setNormal(0, 1, 0).setUV(1, 1), 
					new __vertex(-side, 0,  side).setNormal(0, 1, 0).setUV(0, 1),
				]];
				break;	
			case 2 : 
				vertex = [[
					new __vertex(-side, -side, 0).setNormal(0, 0, 1).setUV(0, 0), 
					new __vertex( side,  side, 0).setNormal(0, 0, 1).setUV(1, 1), 
					new __vertex( side, -side, 0).setNormal(0, 0, 1).setUV(1, 0),
					
					new __vertex(-side, -side, 0).setNormal(0, 0, 1).setUV(0, 0), 
					new __vertex(-side,  side, 0).setNormal(0, 0, 1).setUV(0, 1), 
					new __vertex( side,  side, 0).setNormal(0, 0, 1).setUV(1, 1),
				]];
				break;	
		}
		
		VB = build();
	} initModel();
	
	onParameterUpdate = initModel;
}