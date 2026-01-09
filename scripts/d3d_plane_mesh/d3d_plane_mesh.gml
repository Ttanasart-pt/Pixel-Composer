function __3dPlane(_normal = 0) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	normal   = _normal;
	two_side = false;
	
	static initModel = function() {
		edges   = [];
		var eid = 0;
		
		var _nor = [ 0, 0, 1 ];
		var _vt  = [];
		object_counts = 1 + two_side;
		
		switch(normal) {
			case 0 : 
				_vt = [
					new __vertex(0, -.5, -.5).setNormal(1, 0, 0).setUV(0, 1), 
					new __vertex(0,  .5,  .5).setNormal(1, 0, 0).setUV(1, 0), 
					new __vertex(0,  .5, -.5).setNormal(1, 0, 0).setUV(1, 1),
					   	  
					new __vertex(0, -.5, -.5).setNormal(1, 0, 0).setUV(0, 1), 
					new __vertex(0, -.5,  .5).setNormal(1, 0, 0).setUV(0, 0), 
					new __vertex(0,  .5,  .5).setNormal(1, 0, 0).setUV(1, 0),
				];
				
				edges[0] = new __3dObject_Edge([0, -.5, -.5], [0,  .5, -.5]);
				edges[1] = new __3dObject_Edge([0,  .5, -.5], [0,  .5,  .5]);
				edges[2] = new __3dObject_Edge([0,  .5,  .5], [0, -.5,  .5]);
				edges[3] = new __3dObject_Edge([0, -.5,  .5], [0, -.5, -.5]);
				break;	
				
			case 1 : 
				_vt = [
					new __vertex(-.5, 0, -.5).setNormal(0, 1, 0).setUV(1, 1), 
					new __vertex( .5, 0, -.5).setNormal(0, 1, 0).setUV(0, 1), 
					new __vertex( .5, 0,  .5).setNormal(0, 1, 0).setUV(0, 0), 
							
					new __vertex(-.5, 0, -.5).setNormal(0, 1, 0).setUV(1, 1), 
					new __vertex( .5, 0,  .5).setNormal(0, 1, 0).setUV(0, 0),
					new __vertex(-.5, 0,  .5).setNormal(0, 1, 0).setUV(1, 0),
				];
				
				edges[0] = new __3dObject_Edge([-.5, 0, -.5], [ .5, 0, -.5]);
				edges[1] = new __3dObject_Edge([ .5, 0, -.5], [ .5, 0,  .5]);
				edges[2] = new __3dObject_Edge([ .5, 0,  .5], [-.5, 0,  .5]);
				edges[3] = new __3dObject_Edge([-.5, 0,  .5], [-.5, 0, -.5]);
				break;	
				
			case 2 : 
				_vt = [
					new __vertex(-.5, -.5, 0).setNormal(0, 0, 1).setUV(0, 0), 
					new __vertex( .5,  .5, 0).setNormal(0, 0, 1).setUV(1, 1), 
					new __vertex( .5, -.5, 0).setNormal(0, 0, 1).setUV(0, 1),
																			  
					new __vertex(-.5, -.5, 0).setNormal(0, 0, 1).setUV(0, 0), 
					new __vertex(-.5,  .5, 0).setNormal(0, 0, 1).setUV(1, 0), 
					new __vertex( .5,  .5, 0).setNormal(0, 0, 1).setUV(1, 1),
				];
				
				edges[0] = new __3dObject_Edge([-.5, -.5, 0], [ .5, -.5, 0]);
				edges[1] = new __3dObject_Edge([ .5, -.5, 0], [ .5,  .5, 0]);
				edges[2] = new __3dObject_Edge([ .5,  .5, 0], [-.5,  .5, 0]);
				edges[3] = new __3dObject_Edge([-.5,  .5, 0], [-.5, -.5, 0]);
				break;	
		}
		
		vertex   = [ _vt ];
		
		if(two_side) {
			vertex[1] = array_create(6);
			for( var i = 0; i < 6; i++ ) {
				var _v0 = vertex[0][5 - i];
				vertex[1][i] = new __vertex(_v0.x, _v0.y, _v0.z).setNormal(-_v0.nx, -_v0.ny, -_v0.nz).setUV(_v0.u, _v0.v);
			}
		}
		
		edges = [ edges ];
		VB = build();
	} initModel();
	
	onParameterUpdate = initModel;
}