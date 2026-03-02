function __3dOctahedron(_sepFace = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	sepFace = _sepFace;
	radius  = .5;
	
	static initModel = function() {
		edges   = [];
		var eid = 0;
		
		var v0 = [];
		var r  = radius;
		var i  = 0;
		
		v0[i++] = new __vertex(  0,  0,  r).setUV( .5,  1);
		v0[i++] = new __vertex(  0,  r,  0).setUV(.25, .5);
		v0[i++] = new __vertex(  r,  0,  0).setUV(  0, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		v0[i++] = new __vertex(  0,  0,  r).setUV( .5,  1);
		v0[i++] = new __vertex( -r,  0,  0).setUV( .5, .5);
		v0[i++] = new __vertex(  0,  r,  0).setUV(.25, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		v0[i++] = new __vertex(  0,  0,  r).setUV( .5,  1);
		v0[i++] = new __vertex(  0, -r,  0).setUV(.75, .5);
		v0[i++] = new __vertex( -r,  0,  0).setUV( .5, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		v0[i++] = new __vertex(  0,  0,  r).setUV( .5,  1);
		v0[i++] = new __vertex(  r,  0,  0).setUV(  1, .5);
		v0[i++] = new __vertex(  0, -r,  0).setUV(.75, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		////
		
		v0[i++] = new __vertex(  0,  0, -r).setUV( .5,  0);
		v0[i++] = new __vertex(  r,  0,  0).setUV(  0, .5);
		v0[i++] = new __vertex(  0,  r,  0).setUV(.25, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		v0[i++] = new __vertex(  0,  0, -r).setUV( .5,  0);
		v0[i++] = new __vertex(  0,  r,  0).setUV(.25, .5);
		v0[i++] = new __vertex( -r,  0,  0).setUV( .5, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		v0[i++] = new __vertex(  0,  0, -r).setUV( .5,  0);
		v0[i++] = new __vertex( -r,  0,  0).setUV( .5, .5);
		v0[i++] = new __vertex(  0, -r,  0).setUV(.75, .5);
		
		if(sepFace) { array_push(vertex, v0); v0 = []; i = 0; }
		
		v0[i++] = new __vertex(  0,  0, -r).setUV( .5,  0);
		v0[i++] = new __vertex(  0, -r,  0).setUV(.75, .5);
		v0[i++] = new __vertex(  r,  0,  0).setUV(  1, .5);
		
		array_push(vertex, v0);
		object_counts = array_length(vertex);
		
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}