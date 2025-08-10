function __3dUVSphere(radius = 0.5, hori = 16, vert = 8, smt = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.radius = radius;
	self.hori   = hori;
	self.vert   = vert;
	self.smooth = smt;
	projection  = 0;
	
	static initModel = function() { // swap H, V because fuck me
		var amo = 0;
		var eid = 0;
		
		var vt  = array_create(vert * hori * 2 * 3);
		vertex  = [ vt ];
		edges   = [];
		
	    for (var i = 0; i < vert; i++)
	    for (var j = 0; j < hori; j++) {
			var ha0 = (i + 0) / vert * 360;
			var ha1 = (i + 1) / vert * 360;
			var va0 = 90 - (j + 0) / hori * 180;
			var va1 = 90 - (j + 1) / hori * 180;
			
			var h0 = dsin(va0) * 0.5;
			var h1 = dsin(va1) * 0.5;
			var r0 = dcos(va0) * 0.5;
			var r1 = dcos(va1) * 0.5;
			
			var hx0 = dcos(ha0) * r0;
			var hy0 = dsin(ha0) * r0;
			var hz0 = h0;
			
			var hx1 = dcos(ha1) * r0;
			var hy1 = dsin(ha1) * r0;
			var hz1 = h0;
			
			var hx2 = dcos(ha0) * r1;
			var hy2 = dsin(ha0) * r1;
			var hz2 = h1;
			
			var hx3 = dcos(ha1) * r1;
			var hy3 = dsin(ha1) * r1;
			var hz3 = h1;
			
			var u0 = ha0 / 360, v0;
			var u1 = ha1 / 360, v1;
			var u2 = ha0 / 360, v2;
			var u3 = ha1 / 360, v3;
			
			var ind = (i * hori + j) * 6;
			
			vt[ind + 0] = new __vertex(hx0, hy0, hz0);
			vt[ind + 1] = new __vertex(hx1, hy1, hz1);
			vt[ind + 2] = new __vertex(hx2, hy2, hz2);
									   
			vt[ind + 3] = new __vertex(hx1, hy1, hz1);
			vt[ind + 4] = new __vertex(hx3, hy3, hz3);
			vt[ind + 5] = new __vertex(hx2, hy2, hz2);
			
			edges[eid++] = new __3dObject_Edge([hx0, hy0, hz0], [hx1, hy1, hz1]);
			edges[eid++] = new __3dObject_Edge([hx0, hy0, hz0], [hx2, hy2, hz2]);
			
			if(smooth) {
				vt[ind + 0].setNormal(hx0, hy0, hz0);
				vt[ind + 1].setNormal(hx1, hy1, hz1);
				vt[ind + 2].setNormal(hx2, hy2, hz2);
											 
				vt[ind + 3].setNormal(hx1, hy1, hz1);
				vt[ind + 4].setNormal(hx3, hy3, hz3);
				vt[ind + 5].setNormal(hx2, hy2, hz2);
				
			} else {
				var nor = d3_cross_product([hx2 - hx0, hy2 - hy0, hz2 - hz0], [hx1 - hx0, hy1 - hy0, hz1 - hz0]);
				nor = d3_normalize(nor);
				
				vt[ind + 0].setNormal(nor[0], nor[1], nor[2]);
				vt[ind + 1].setNormal(nor[0], nor[1], nor[2]);
				vt[ind + 2].setNormal(nor[0], nor[1], nor[2]);
											 
				vt[ind + 3].setNormal(nor[0], nor[1], nor[2]);
				vt[ind + 4].setNormal(nor[0], nor[1], nor[2]);
				vt[ind + 5].setNormal(nor[0], nor[1], nor[2]);
			}
			
			switch(projection) {
				case 0 :
					v0 = dsin(va0);
					v2 = dsin(va1);
					break;
					
				case 1 :
					v0 = va0 / 90;
					v2 = va1 / 90;
					break;
					
				case 2 :
					v0 = (2 * arctan(exp(degtorad(va0))) - pi / 2) / (pi / 2); 
					v2 = (2 * arctan(exp(degtorad(va1))) - pi / 2) / (pi / 2); 
					break;
			}
			
			v0 = 0.5 - 0.5 * v0;
			v2 = 0.5 - 0.5 * v2;
			
			v1 = v0;
			v3 = v2;
			
			vt[ind + 0].setUV(u0, v0);
			vt[ind + 1].setUV(u1, v1);
			vt[ind + 2].setUV(u2, v2);
											
			vt[ind + 3].setUV(u1, v1);
			vt[ind + 4].setUV(u3, v3);
			vt[ind + 5].setUV(u2, v2);
	    }
		
		edges = [ edges ];
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}