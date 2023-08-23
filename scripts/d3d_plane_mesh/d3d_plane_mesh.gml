function __3dPlane() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.side   = 0.5;
	self.normal = 0;
	
	static initModel = function() {
		var _nor = [ 0, 0, 1 ];
		switch(normal) {
			case 0 : 
				_nor = [ 1, 0, 0 ]; 
				vertex = [[
					V3(0, -side, -side).setNormal(_nor).setUV(0, 0), 
					V3(0,  side,  side).setNormal(_nor).setUV(1, 1), 
					V3(0,  side, -side).setNormal(_nor).setUV(1, 0),
					   	  
					V3(0, -side, -side).setNormal(_nor).setUV(0, 0), 
					V3(0, -side,  side).setNormal(_nor).setUV(0, 1), 
					V3(0,  side,  side).setNormal(_nor).setUV(1, 1),
				]];
				break;	
			case 1 : 
				_nor = [ 0, 1, 0 ]; 
				vertex = [[
					V3(-side, 0, -side).setNormal(_nor).setUV(0, 0), 
					V3( side, 0, -side).setNormal(_nor).setUV(1, 0),
					V3( side, 0,  side).setNormal(_nor).setUV(1, 1), 
							
					V3(-side, 0, -side).setNormal(_nor).setUV(0, 0), 
					V3( side, 0,  side).setNormal(_nor).setUV(1, 1), 
					V3(-side, 0,  side).setNormal(_nor).setUV(0, 1),
				]];
				break;	
			case 2 : 
				_nor = [ 0, 0, 1 ]; 
				vertex = [[
					V3(-side, -side, 0).setNormal(_nor).setUV(0, 0), 
					V3( side,  side, 0).setNormal(_nor).setUV(1, 1), 
					V3( side, -side, 0).setNormal(_nor).setUV(1, 0),
					
					V3(-side, -side, 0).setNormal(_nor).setUV(0, 0), 
					V3(-side,  side, 0).setNormal(_nor).setUV(0, 1), 
					V3( side,  side, 0).setNormal(_nor).setUV(1, 1),
				]];
				break;	
		}
		
		VB = build();
		generateNormal();
	} initModel();
	
	onParameterUpdate = initModel;
}