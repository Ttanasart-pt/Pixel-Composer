function __3dUVSphere(radius = 0.5, hori = 16, vert = 8, smt = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.radius = radius;
	self.hori   = hori;
	self.vert   = vert;
	self.smooth = smt;
	
	static initModel = function() { // swap H, V because fuck me
		vertex  = array_create(vert * hori * 2 * 3);
		normals = array_create(vert * hori * 2 * 3);
		uv      = array_create(vert * hori * 2 * 3);
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
			
			vertex[ind + 0] = [hx0, hy0, hz0];
			vertex[ind + 1] = [hx1, hy1, hz1];
			vertex[ind + 2] = [hx2, hy2, hz2];
									   
			vertex[ind + 3] = [hx1, hy1, hz1];
			vertex[ind + 4] = [hx2, hy2, hz2];
			vertex[ind + 5] = [hx3, hy3, hz3];
			
			if(smooth) {
				normals[ind + 0] = d3_normalize([hx0, hy0, hz0]);
				normals[ind + 1] = d3_normalize([hx1, hy1, hz1]);
				normals[ind + 2] = d3_normalize([hx2, hy2, hz2]);
														 
				normals[ind + 3] = d3_normalize([hx1, hy1, hz1]);
				normals[ind + 4] = d3_normalize([hx2, hy2, hz2]);
				normals[ind + 5] = d3_normalize([hx3, hy3, hz3]);
			} else {
				var nor = d3_cross_product([hx2 - hx0, hy2 - hy0, hz2 - hz0], [hx1 - hx0, hy1 - hy0, hz1 - hz0]);
				nor = d3_normalize(nor);
				
				normals[ind + 0] = nor;
				normals[ind + 1] = nor;
				normals[ind + 2] = nor;
				
				normals[ind + 3] = nor;
				normals[ind + 4] = nor;
				normals[ind + 5] = nor;
			}
			
			uv[ind + 0] = [u0, v0];
			uv[ind + 1] = [u1, v1];
			uv[ind + 2] = [u2, v2];
										
			uv[ind + 3] = [u1, v1];
			uv[ind + 4] = [u2, v2];
			uv[ind + 5] = [u3, v3];
	    }
		
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}