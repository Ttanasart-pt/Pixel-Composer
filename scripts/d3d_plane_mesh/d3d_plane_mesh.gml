function __3dPlane() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	normal   = 0;
	two_side = false;
	
	static initModel = function() {
		var _nor = [ 0, 0, 1 ];
		vertex   = [];
		object_counts = 1 + two_side;
		
		switch(normal) {
			case 0 : 
				vertex[0] = [
					new __vertex(0, -.5, -.5).setNormal(1, 0, 0).setUV(0, 1), 
					new __vertex(0,  .5,  .5).setNormal(1, 0, 0).setUV(1, 0), 
					new __vertex(0,  .5, -.5).setNormal(1, 0, 0).setUV(1, 1),
					   	  
					new __vertex(0, -.5, -.5).setNormal(1, 0, 0).setUV(0, 1), 
					new __vertex(0, -.5,  .5).setNormal(1, 0, 0).setUV(0, 0), 
					new __vertex(0,  .5,  .5).setNormal(1, 0, 0).setUV(1, 0),
				];
				break;	
				
			case 1 : 
				vertex[0] = [
					new __vertex(-.5, 0, -.5).setNormal(0, 1, 0).setUV(1, 1), 
					new __vertex( .5, 0, -.5).setNormal(0, 1, 0).setUV(0, 1), 
					new __vertex( .5, 0,  .5).setNormal(0, 1, 0).setUV(0, 0), 
							
					new __vertex(-.5, 0, -.5).setNormal(0, 1, 0).setUV(1, 1), 
					new __vertex( .5, 0,  .5).setNormal(0, 1, 0).setUV(0, 0),
					new __vertex(-.5, 0,  .5).setNormal(0, 1, 0).setUV(1, 0),
				];
				break;	
				
			case 2 : 
				vertex[0] = [
					new __vertex(-.5, -.5, 0).setNormal(0, 0, 1).setUV(0, 0), 
					new __vertex( .5,  .5, 0).setNormal(0, 0, 1).setUV(1, 1), 
					new __vertex( .5, -.5, 0).setNormal(0, 0, 1).setUV(0, 1),
																			  
					new __vertex(-.5, -.5, 0).setNormal(0, 0, 1).setUV(0, 0), 
					new __vertex(-.5,  .5, 0).setNormal(0, 0, 1).setUV(1, 0), 
					new __vertex( .5,  .5, 0).setNormal(0, 0, 1).setUV(1, 1),
				];
				break;	
		}
		
		if(two_side) {
			vertex[1] = array_create(6);
			for( var i = 0; i < 6; i++ ) {
				var _v0 = vertex[0][5 - i];
				vertex[1][i] = new __vertex(_v0.x, _v0.y, _v0.z).setNormal(-_v0.nx, -_v0.ny, -_v0.nz).setUV(_v0.u, _v0.v);
			}
		}
		
		VB = build();
	} initModel();
	
	onParameterUpdate = initModel;
}