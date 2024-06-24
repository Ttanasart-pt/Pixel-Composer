function __3dPathExtrude(radius = 0.5, sides = 8, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	object_counts = 3;
	
	self.radius = radius;
	self.sides  = sides;
	self.smooth = smooth;
	
	endCap = true;
	points = [];
	uvProg = [];
	radiusOverPath = [];
	uvScale = [ 1, 1 ];
	
	static initModel = function() {
		var vs = [];
		var v0 = [];
		var v1 = [];
		var o = new __vec3();
		var n = new __vec3();
		var v = new __vec3();
		var u = new __vec3();
		var w = new __vec3();
		var len;
		
		var prevp = array_create((sides + 1) * 3);
		var prevn = array_create((sides + 1) * 3);
		var _subd = array_length(points) / 3;
		var _ind = 0;
		var _in0 = 0;
		var _in1 = 0;
		
		var _u0 = new __vec3(0, 1, 0);
		var _u1 = new __vec3(0, 0, 1);
		
		if(_subd < 2) return;
		
		o.x = points[0];
		o.y = points[1];
		o.z = points[2];
		
		var _us = uvScale[0];
		var _vs = uvScale[1];
		
		for(var i = 1; i < _subd; i++) {
			n.x = points[i * 3 + 0];
			n.y = points[i * 3 + 1];
			n.z = points[i * 3 + 2];
			
			if(i == 1) {
				v.x = n.x - o.x;
				v.y = n.y - o.y;
				v.z = n.z - o.z;
				v._normalize();
				
				if(v.z == v.z) u = v.cross(_u0);
				else           u = v.cross(_u1); 
				
				u._normalize();
				w = v.cross(u);
				
				var _rr = radius * radiusOverPath[0];
				
				for(var j = 0; j <= sides; j++) {
			    	var a0 = j / sides * 360;
			    	
			    	var _u  = u.multiply(dcos(a0));
			    	var _w  = w.multiply(dsin(a0));
			    	var _pp = _u.add(_w);
					
					prevp[j * 3 + 0] = o.x + _pp.x * _rr;
					prevp[j * 3 + 1] = o.y + _pp.y * _rr;
					prevp[j * 3 + 2] = o.z + _pp.z * _rr;
			    }
			    
			    for(var j = 0; j < sides; j++) {
			    	var cx0 = prevp[j * 3 + 0];
			    	var cy0 = prevp[j * 3 + 1];
			    	var cz0 = prevp[j * 3 + 2];
			    	
			    	var cx1 = prevp[j * 3 + 0 + 3];
					var cy1 = prevp[j * 3 + 1 + 3];
					var cz1 = prevp[j * 3 + 2 + 3];
					
					var a0 = (j + 0) / sides * 360;
					var a1 = (j + 1) / sides * 360;
			
					var __u0 = 0.5 + lengthdir_x(0.5, a0);
					var __v0 = 0.5 + lengthdir_y(0.5, a0);
					var __u1 = 0.5 + lengthdir_x(0.5, a1);
					var __v1 = 0.5 + lengthdir_y(0.5, a1);
					
			    	v0[_in0++] = new __vertex(o.x, o.y, o.z).setNormal(-v.x, -v.y, -v.z).setUV(0.5, 0.5);
					v0[_in0++] = new __vertex(cx0, cy0, cz0).setNormal(-v.x, -v.y, -v.z).setUV(__u0, __v0);
					v0[_in0++] = new __vertex(cx1, cy1, cz1).setNormal(-v.x, -v.y, -v.z).setUV(__u1, __v1);
			    }
			}
			
			if(i) {
				if(i < _subd - 1) {
					v.x = points[(i + 1) * 3 + 0] - o.x;
					v.y = points[(i + 1) * 3 + 1] - o.y;
					v.z = points[(i + 1) * 3 + 2] - o.z;
				} else {
					v.x = n.x - o.x;
					v.y = n.y - o.y;
					v.z = n.z - o.z;
				}
				
				v._normalize();
				
				if(v.z == v.z) u = v.cross(_u0);
				else           u = v.cross(_u1); 
				
				u._normalize();
				w = v.cross(u);
				
				var _rr  = radius * radiusOverPath[i];
				var __v0 = 1. - uvProg[i-1];
				var __v1 = 1. - uvProg[i  ];
				// print($"{i}: {__v0} - {__v1}")
				
				for(var j = 0; j <= sides; j++) {
			    	var a0 = j / sides * 360;
			    	
			    	var _u  = u.multiply(dcos(a0));
			    	var _w  = w.multiply(dsin(a0));
			    	var _pp = _u.add(_w);
					
					prevn[j * 3 + 0] = n.x + _pp.x * _rr;
					prevn[j * 3 + 1] = n.y + _pp.y * _rr;
					prevn[j * 3 + 2] = n.z + _pp.z * _rr;
					
					if(j) {
						var x0 = prevp[(j - 1) * 3 + 0];
						var y0 = prevp[(j - 1) * 3 + 1];
						var z0 = prevp[(j - 1) * 3 + 2];
						
						var x1 = prevp[j * 3 + 0];
						var y1 = prevp[j * 3 + 1];
						var z1 = prevp[j * 3 + 2];
						
						var x2 = prevn[(j - 1) * 3 + 0];
						var y2 = prevn[(j - 1) * 3 + 1];
						var z2 = prevn[(j - 1) * 3 + 2];
						
						var x3 = prevn[j * 3 + 0];
						var y3 = prevn[j * 3 + 1];
						var z3 = prevn[j * 3 + 2];
						
						var _n0, _n1, _n2, _n3;
						
						if(smooth) {
							_n0 = new __vec3(x0 - o.x, y0 - o.y, z0 - o.z).normalize();
							_n1 = new __vec3(x1 - o.x, y1 - o.y, z1 - o.z).normalize();
							_n2 = new __vec3(x2 - n.x, y2 - n.y, z2 - n.z).normalize();
							_n3 = new __vec3(x3 - n.x, y3 - n.y, z3 - n.z).normalize();
							
						} else {
							_n0 = _pp.normalize();
							_n1 = _n0;
							_n2 = _n0;
							_n3 = _n0;
						}
						
						var __u0 = (j-1) / sides;
						var __u1 = (j  ) / sides;
						
						vs[_ind++] = new __vertex(x0, y0, z0).setNormal(_n0.x, _n0.y, _n0.z).setUV(__u0 * _us, __v0 * _vs);
						vs[_ind++] = new __vertex(x2, y2, z2).setNormal(_n2.x, _n2.y, _n2.z).setUV(__u0 * _us, __v1 * _vs);
						vs[_ind++] = new __vertex(x1, y1, z1).setNormal(_n1.x, _n1.y, _n1.z).setUV(__u1 * _us, __v0 * _vs);
						
						vs[_ind++] = new __vertex(x1, y1, z1).setNormal(_n1.x, _n1.y, _n1.z).setUV(__u1 * _us, __v0 * _vs);
						vs[_ind++] = new __vertex(x2, y2, z2).setNormal(_n2.x, _n2.y, _n2.z).setUV(__u0 * _us, __v1 * _vs);
						vs[_ind++] = new __vertex(x3, y3, z3).setNormal(_n3.x, _n3.y, _n3.z).setUV(__u1 * _us, __v1 * _vs);	
					}
			    }
			    
			    for (var j = 0, m = array_length(prevn); j < m; j++)
			    	prevp[j] = prevn[j];
			}
			
			if(i == _subd - 1) {
				for(var j = 0; j < sides; j++) {
			    	var cx0 = prevp[j * 3 + 0];
			    	var cy0 = prevp[j * 3 + 1];
			    	var cz0 = prevp[j * 3 + 2];
			    	
			    	var cx1 = prevp[j * 3 + 0 + 3];
					var cy1 = prevp[j * 3 + 1 + 3];
					var cz1 = prevp[j * 3 + 2 + 3];
					
					var a0 = (j + 0) / sides * 360;
					var a1 = (j + 1) / sides * 360;
			
					var __u0 = 0.5 + lengthdir_x(0.5, a0);
					var __v0 = 0.5 + lengthdir_y(0.5, a0);
					var __u1 = 0.5 + lengthdir_x(0.5, a1);
					var __v1 = 0.5 + lengthdir_y(0.5, a1);
					
			    	v1[_in1++] = new __vertex(n.x, n.y, n.z).setNormal(-v.x, -v.y, -v.z).setUV(0.5, 0.5);
					v1[_in1++] = new __vertex(cx0, cy0, cz0).setNormal(-v.x, -v.y, -v.z).setUV(__u0, __v0);
					v1[_in1++] = new __vertex(cx1, cy1, cz1).setNormal(-v.x, -v.y, -v.z).setUV(__u1, __v1);
			    }
			}
			
			o.x = n.x;
			o.y = n.y;
			o.z = n.z;
		}
		
		vertex = endCap? [ vs, v0, v1 ] : [ vs ];
		object_counts = array_length(vertex);
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}