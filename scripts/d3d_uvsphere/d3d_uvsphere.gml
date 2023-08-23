function __3dUVSphere(radius = 0.5, hori = 16, vert = 8, smt = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.radius = radius;
	self.hori   = hori;
	self.vert   = vert;
	self.smooth = smt;
	
	static initModel = function() { // swap H, V because fuck me
		vertex  = [ array_create(vert * hori * 2 * 3) ];
		var amo = 0;
		
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
			
			var u0 = ha0 / 360;
			var v0 = 0.5 - 0.5 * dsin(va0);
			
			var u1 = ha1 / 360;
			var v1 = 0.5 - 0.5 * dsin(va0);
			
			var u2 = ha0 / 360;
			var v2 = 0.5 - 0.5 * dsin(va1);
			
			var u3 = ha1 / 360;
			var v3 = 0.5 - 0.5 * dsin(va1);
			
			var ind = (i * hori + j) * 6;
			
			vertex[0][ind + 0] = V3(hx0, hy0, hz0);
			vertex[0][ind + 1] = V3(hx1, hy1, hz1);
			vertex[0][ind + 2] = V3(hx2, hy2, hz2);
									   
			vertex[0][ind + 3] = V3(hx1, hy1, hz1);
			vertex[0][ind + 4] = V3(hx3, hy3, hz3);
			vertex[0][ind + 5] = V3(hx2, hy2, hz2);
			
			if(smooth) {
				vertex[0][ind + 0].setNormal(hx0, hy0, hz0);
				vertex[0][ind + 1].setNormal(hx1, hy1, hz1);
				vertex[0][ind + 2].setNormal(hx2, hy2, hz2);
											 
				vertex[0][ind + 3].setNormal(hx1, hy1, hz1);
				vertex[0][ind + 4].setNormal(hx3, hy3, hz3);
				vertex[0][ind + 5].setNormal(hx2, hy2, hz2);
			} else {
				var nor = d3_cross_product([hx2 - hx0, hy2 - hy0, hz2 - hz0], [hx1 - hx0, hy1 - hy0, hz1 - hz0]);
				nor = d3_normalize(nor);
				
				vertex[0][ind + 0].setNormal(nor);
				vertex[0][ind + 1].setNormal(nor);
				vertex[0][ind + 2].setNormal(nor);
											 
				vertex[0][ind + 3].setNormal(nor);
				vertex[0][ind + 4].setNormal(nor);
				vertex[0][ind + 5].setNormal(nor);
			}
			
			vertex[0][ind + 0].setUV(u0, v0);
			vertex[0][ind + 1].setUV(u1, v1);
			vertex[0][ind + 2].setUV(u2, v2);
											
			vertex[0][ind + 3].setUV(u1, v1);
			vertex[0][ind + 4].setUV(u3, v3);
			vertex[0][ind + 5].setUV(u2, v2);
	    }
		
		VB = build();
		generateNormal();
	} initModel();
	
	static onParameterUpdate = initModel;
}