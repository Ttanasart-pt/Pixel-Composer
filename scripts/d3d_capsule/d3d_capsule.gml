function __3dCapsule(_radius = 0.5, _height = 1, _sides = 8, _smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	radius = _radius;
	height = _height;
	sides  = _sides;
	smooth = _smooth;
	
	segment  = 1;
	profiles = [ 1, 1 ];
	
	uvScale_side = 1;
	
	static initModel = function() {
		edges   = [];
		var eid = 0;
		
		var v0 = array_create(3 * sides);
		var v1 = array_create(3 * sides);
		var _h = height / 2;
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		for( var i = 0; i < sides; i++ ) 
		for( var j = 0; j < sides; j++ ) { // round caps
			var ha0 = (i + 0) / sides * 360;
			var ha1 = (i + 1) / sides * 360;
			var va0 = (j + 0) / sides * 90;
			var va1 = (j + 1) / sides * 90;
			
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
			
			var _u0 = ha0 / 360 * uvScale_side, _v0;
			var _u1 = ha1 / 360 * uvScale_side, _v1;
			var _u2 = ha0 / 360 * uvScale_side, _v2;
			var _u3 = ha1 / 360 * uvScale_side, _v3;
			
			var ind = (i * sides + j) * 6;
			
			v0[ind + 0] = new __vertex(hx0, hy0,  hz0 + _h);
			v0[ind + 1] = new __vertex(hx2, hy2,  hz2 + _h);
			v0[ind + 2] = new __vertex(hx1, hy1,  hz1 + _h);
									   
			v0[ind + 3] = new __vertex(hx1, hy1,  hz1 + _h);
			v0[ind + 4] = new __vertex(hx2, hy2,  hz2 + _h);
			v0[ind + 5] = new __vertex(hx3, hy3,  hz3 + _h);
			
			v1[ind + 0] = new __vertex(hx0, hy0, -hz0 - _h);
			v1[ind + 1] = new __vertex(hx1, hy1, -hz1 - _h);
			v1[ind + 2] = new __vertex(hx2, hy2, -hz2 - _h);
									   
			v1[ind + 3] = new __vertex(hx1, hy1, -hz1 - _h);
			v1[ind + 4] = new __vertex(hx3, hy3, -hz3 - _h);
			v1[ind + 5] = new __vertex(hx2, hy2, -hz2 - _h);
			
			if(smooth) {
				v0[ind + 0].setNormal(hx0, hy0, hz0);
				v0[ind + 1].setNormal(hx2, hy2, hz2);
				v0[ind + 2].setNormal(hx1, hy1, hz1);
											 
				v0[ind + 3].setNormal(hx1, hy1, hz1);
				v0[ind + 3].setNormal(hx2, hy2, hz2);
				v0[ind + 4].setNormal(hx3, hy3, hz3);
				
				v1[ind + 0].setNormal(hx0, hy0, -hz0);
				v1[ind + 1].setNormal(hx1, hy1, -hz1);
				v1[ind + 2].setNormal(hx2, hy2, -hz2);
											 
				v1[ind + 3].setNormal(hx1, hy1, -hz1);
				v1[ind + 4].setNormal(hx3, hy3, -hz3);
				v1[ind + 5].setNormal(hx2, hy2, -hz2);
				
			} else {
				var nor = d3_cross_product([hx2 - hx0, hy2 - hy0, hz2 - hz0], [hx1 - hx0, hy1 - hy0, hz1 - hz0]);
				nor = d3_normalize(nor);
				
				v0[ind + 0].setNormal(nor[0], nor[1], nor[2]);
				v0[ind + 1].setNormal(nor[0], nor[1], nor[2]);
				v0[ind + 2].setNormal(nor[0], nor[1], nor[2]);
											 
				v0[ind + 3].setNormal(nor[0], nor[1], nor[2]);
				v0[ind + 4].setNormal(nor[0], nor[1], nor[2]);
				v0[ind + 5].setNormal(nor[0], nor[1], nor[2]);
				
				v1[ind + 0].setNormal(nor[0], nor[1], -nor[2]);
				v1[ind + 1].setNormal(nor[0], nor[1], -nor[2]);
				v1[ind + 2].setNormal(nor[0], nor[1], -nor[2]);
											 
				v1[ind + 3].setNormal(nor[0], nor[1], -nor[2]);
				v1[ind + 4].setNormal(nor[0], nor[1], -nor[2]);
				v1[ind + 5].setNormal(nor[0], nor[1], -nor[2]);
			}
			
			_v0 = dsin(va0);
			_v2 = dsin(va1);
					
			_v0 = 0.5 - 0.5 * _v0;
			_v2 = 0.5 - 0.5 * _v2;
			
			_v1 = _v0;
			_v3 = _v2;
			
			v0[ind + 0].setUV(_u0, _v0);
			v0[ind + 1].setUV(_u2, _v2);
			v0[ind + 2].setUV(_u1, _v1);
											
			v0[ind + 3].setUV(_u1, _v1);
			v0[ind + 4].setUV(_u2, _v2);
			v0[ind + 5].setUV(_u3, _v3);
			
			v1[ind + 0].setUV(_u0, _v0);
			v1[ind + 1].setUV(_u1, _v1);
			v1[ind + 2].setUV(_u2, _v2);
			
			v1[ind + 3].setUV(_u1, _v1);
			v1[ind + 4].setUV(_u3, _v3);
			v1[ind + 5].setUV(_u2, _v2);
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var vs = array_create(3 * sides * 2 * segment);
		var _sg = 1 / segment;
		var _ix = 0;
		
		for( var i = 0; i < sides; i++ ) { // sides
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var _x0 = lengthdir_x(1, a0);
			var _y0 = lengthdir_y(1, a0);
			var _x1 = lengthdir_x(1, a1);
			var _y1 = lengthdir_y(1, a1);
			
			var nx0 = smooth? _x0 : lengthdir_x(1, (a0 + a1) / 2);
			var ny0 = smooth? _y0 : lengthdir_y(1, (a0 + a1) / 2);
			
			var nx1 = smooth? _x1 : lengthdir_x(1, (a0 + a1) / 2);
			var ny1 = smooth? _y1 : lengthdir_y(1, (a0 + a1) / 2);
			
			var ux0 = (i + 0) / sides * uvScale_side;
			var ux1 = (i + 1) / sides * uvScale_side;
			
			for( var j = 0; j < segment; j++ ) {
				var _j0 = j * _sg;
				var _j1 = _j0 + _sg;
				
				var _r0 = radius * profiles[j    ];
				var _r1 = radius * profiles[j + 1];
				
				var x0 = _x0 * _r0, y0 = _y0 * _r0;
				var x1 = _x1 * _r0, y1 = _y1 * _r0;
				var x2 = _x0 * _r1, y2 = _y0 * _r1;
				var x3 = _x1 * _r1, y3 = _y1 * _r1;
				
				var _h0 = -_h + _j0 * _h * 2;
				var _h1 = -_h + _j1 * _h * 2;
				
				var _dr = _r1 - _r0;
				var _dh = _h;
				
				var nz0 = _dr / _dh;
				var nz1 = _dr / _dh;
				
				if(smooth) {
					var nz00 = j > 0?           (radius * profiles[j  ] - radius * profiles[j-1]) / _dh : nz0;
					var nz11 = j < segment - 1? (radius * profiles[j+2] - radius * profiles[j+1]) / _dh : nz1;
					
					nz0 = (nz0 + nz00) / 2;
					nz1 = (nz1 + nz11) / 2;
				}
				
				var len  = sqrt(nx0 * nx0 + ny0 * ny0 + nz0 * nz0);
				var nnx0 = nx0 / len;
				var nny0 = ny0 / len;
				var nnz0 = nz0 / len;
			
				var len  = sqrt(nx1 * nx1 + ny1 * ny1 + nz1 * nz1);
				var nnx1 = nx1 / len;
				var nny1 = ny1 / len;
				var nnz1 = nz1 / len;
			
				vs[_ix++] = new __vertex(x2, y2, _h1).setNormal(nnx0, nny0, nnz1).setUV(ux0, _j1);
				vs[_ix++] = new __vertex(x0, y0, _h0).setNormal(nnx0, nny0, nnz0).setUV(ux0, _j0);
				vs[_ix++] = new __vertex(x3, y3, _h1).setNormal(nnx1, nny1, nnz1).setUV(ux1, _j1);
															  					  
				vs[_ix++] = new __vertex(x0, y0, _h0).setNormal(nnx0, nny0, nnz0).setUV(ux0, _j0);
				vs[_ix++] = new __vertex(x1, y1, _h0).setNormal(nnx1, nny1, nnz0).setUV(ux1, _j0);
				vs[_ix++] = new __vertex(x3, y3, _h1).setNormal(nnx1, nny1, nnz1).setUV(ux1, _j1);
				
				edges[eid++] = new __3dObject_Edge([x0, y0, _h0], [x2, y2, _h1]);
				edges[eid++] = new __3dObject_Edge([x1, y1, _h0], [x3, y3, _h1]);
			}
		}
		
		edges  = [ edges ];
		vertex = [ vs, v0, v1 ];
		object_counts = array_length(vertex);
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}