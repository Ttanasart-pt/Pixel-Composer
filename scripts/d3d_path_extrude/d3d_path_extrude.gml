function __3dPathExtrude(_radius = 0.5, _sides = 8, _smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 3;
	
	radius  = _radius;
	sides   = _sides;
	smooth  = _smooth;
	
	pathAmount = 0;
	invert  = false;
	loop    = false;
	endCap  = true;
	points  = [];
	uvProg  = [];
	uvScale = [ 1, 1 ];
	radiusOverPath = [];
	
	vertex_side = [];
	vertex_caps = [];
	vertex_cape = [];
	
	yaw = 0;
	_ind = 0;
	_in0 = 0;
	_in1 = 0;
	
	static extrudePath = function(_index) {
		
		var _points = points[_index];
		var _uvProg = uvProg[_index];
		
		var o = new __vec3();
		var n = new __vec3();
		var v = new __vec3();
		var u = new __vec3();
		var w = new __vec3();
		
		var prevp = array_create((sides + 1) * 3);
		var prevn = array_create((sides + 1) * 3);
		var _subd = array_length(_points) / 3;
		
		if(_subd < 2) return;
		
		var _ux = new __vec3(1, 0, 0);
		var _uy = new __vec3(0, 1, 0);
		var _uz = new __vec3(0, 0, 1);
		
		var eid = 0;
		
		o.x = _points[0];
		o.y = _points[1];
		o.z = _points[2];
		
		var _us = uvScale[0];
		var _vs = uvScale[1];
		
		var firstLoop = array_create(sides * 3);
		var _iside = 360 / sides;
		
		#region cap start
			v.x = _points[3 + 0] - _points[0];
			v.y = _points[3 + 1] - _points[1];
			v.z = _points[3 + 2] - _points[2];
			
			if(loop) {
				v.x = _points[3 + 0] - _points[(_subd - 2) * 3 + 0];
				v.y = _points[3 + 1] - _points[(_subd - 2) * 3 + 1];
				v.z = _points[3 + 2] - _points[(_subd - 2) * 3 + 2];
			}
			
			v._normalize();
			
			     if(v.equal(_ux)) u = v.cross(_uz);
			else if(v.equal(_uz)) u = v.cross(_uy); 
			else                  u = v.cross(_uz); 
			
			u._normalize();
			w = v.cross(u);
			
			var _rr = radius * radiusOverPath[0];
			
			for(var j = 0; j <= sides; j++) {
		    	var a0 = yaw + j * _iside;
		    	
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
				
				var a0 = yaw + (j + 0) * _iside;
				var a1 = yaw + (j + 1) * _iside;
		
				var __u0 = 0.5 + lengthdir_x(0.5, a0);
				var __v0 = 0.5 + lengthdir_y(0.5, a0);
				var __u1 = 0.5 + lengthdir_x(0.5, a1);
				var __v1 = 0.5 + lengthdir_y(0.5, a1);
				
		    	vertex_caps[_in0++] = new __vertex(o.x, o.y, o.z).setNormal(-v.x, -v.y, -v.z).setUV(0.5, 0.5);
				vertex_caps[_in0++] = new __vertex(cx0, cy0, cz0).setNormal(-v.x, -v.y, -v.z).setUV(__u0, __v0);
				vertex_caps[_in0++] = new __vertex(cx1, cy1, cz1).setNormal(-v.x, -v.y, -v.z).setUV(__u1, __v1);
				
				edges[eid++] = new __3dObject_Edge([cx0, cy0, cz0], [cx1, cy1, cz1]);
		    }
		    
		    for (var j = 0, m = array_length(prevn); j < m; j++)
	    		firstLoop[j] = prevp[j];
		#endregion
			
		for(var i = 1; i < _subd; i++) {
			n.x = _points[i * 3 + 0];
			n.y = _points[i * 3 + 1];
			n.z = _points[i * 3 + 2];
			
			if(i < _subd - 1) {
				v.x = _points[(i + 1) * 3 + 0] - o.x;
				v.y = _points[(i + 1) * 3 + 1] - o.y;
				v.z = _points[(i + 1) * 3 + 2] - o.z;
			} else {
				v.x = n.x - o.x;
				v.y = n.y - o.y;
				v.z = n.z - o.z;
			}
			
			v._normalize();
			
				 if(v.equal(_ux)) u = v.cross(_uz);
			else if(v.equal(_uz)) u = v.cross(_uy); 
			else                  u = v.cross(_uz);
			
			u._normalize();
			w = v.cross(u);
			
			var _rr  = radius * radiusOverPath[i];
			var __v0 = 1. - _uvProg[i-1];
			var __v1 = 1. - _uvProg[i  ];
			
			for(var j = 0; j <= sides; j++) {
		    	var a0 = yaw + j * _iside;
		    	
		    	var _u  = u.multiply(dcos(a0));
		    	var _w  = w.multiply(dsin(a0));
		    	var _pp = _u.add(_w);
				
				prevn[j * 3 + 0] = n.x + _pp.x * _rr;
				prevn[j * 3 + 1] = n.y + _pp.y * _rr;
				prevn[j * 3 + 2] = n.z + _pp.z * _rr;
				
				var prenn = loop && i == _subd - 1? firstLoop : prevn;
				
				if(j) {
					var x0 = prevp[ (j - 1) * 3 + 0 ];
					var y0 = prevp[ (j - 1) * 3 + 1 ];
					var z0 = prevp[ (j - 1) * 3 + 2 ];
					
					var x1 = prevp[ (j    ) * 3 + 0 ];
					var y1 = prevp[ (j    ) * 3 + 1 ];
					var z1 = prevp[ (j    ) * 3 + 2 ];
					
					var x2 = prenn[ (j - 1) * 3 + 0 ];
					var y2 = prenn[ (j - 1) * 3 + 1 ];
					var z2 = prenn[ (j - 1) * 3 + 2 ];
					
					var x3 = prenn[ (j    ) * 3 + 0 ];
					var y3 = prenn[ (j    ) * 3 + 1 ];
					var z3 = prenn[ (j    ) * 3 + 2 ];
					
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
					
					if(invert) {
						vertex_side[_ind++] = new __vertex(x0, y0, z0).setNormal(_n0.x, _n0.y, _n0.z).setUV(__v0 * _vs, 1 - __u0 * _us);
						vertex_side[_ind++] = new __vertex(x1, y1, z1).setNormal(_n1.x, _n1.y, _n1.z).setUV(__v0 * _vs, 1 - __u1 * _us);
						vertex_side[_ind++] = new __vertex(x2, y2, z2).setNormal(_n2.x, _n2.y, _n2.z).setUV(__v1 * _vs, 1 - __u0 * _us);
						
						vertex_side[_ind++] = new __vertex(x1, y1, z1).setNormal(_n1.x, _n1.y, _n1.z).setUV(__v0 * _vs, 1 - __u1 * _us);
						vertex_side[_ind++] = new __vertex(x3, y3, z3).setNormal(_n3.x, _n3.y, _n3.z).setUV(__v1 * _vs, 1 - __u1 * _us);	
						vertex_side[_ind++] = new __vertex(x2, y2, z2).setNormal(_n2.x, _n2.y, _n2.z).setUV(__v1 * _vs, 1 - __u0 * _us);
						
					} else {
						vertex_side[_ind++] = new __vertex(x0, y0, z0).setNormal(_n0.x, _n0.y, _n0.z).setUV(__v0 * _vs, 1 - __u0 * _us);
						vertex_side[_ind++] = new __vertex(x2, y2, z2).setNormal(_n2.x, _n2.y, _n2.z).setUV(__v1 * _vs, 1 - __u0 * _us);
						vertex_side[_ind++] = new __vertex(x1, y1, z1).setNormal(_n1.x, _n1.y, _n1.z).setUV(__v0 * _vs, 1 - __u1 * _us);
						
						vertex_side[_ind++] = new __vertex(x1, y1, z1).setNormal(_n1.x, _n1.y, _n1.z).setUV(__v0 * _vs, 1 - __u1 * _us);
						vertex_side[_ind++] = new __vertex(x2, y2, z2).setNormal(_n2.x, _n2.y, _n2.z).setUV(__v1 * _vs, 1 - __u0 * _us);
						vertex_side[_ind++] = new __vertex(x3, y3, z3).setNormal(_n3.x, _n3.y, _n3.z).setUV(__v1 * _vs, 1 - __u1 * _us);
					}
					
					edges[eid++] = new __3dObject_Edge([x0, y0, z0], [x1, y1, z1]);
					edges[eid++] = new __3dObject_Edge([x1, y1, z1], [x3, y3, z3]);
					edges[eid++] = new __3dObject_Edge([x3, y3, z3], [x2, y2, z2]);
					edges[eid++] = new __3dObject_Edge([x2, y2, z2], [x0, y0, z0]);
				
				}
		    }
		    
		    for (var j = 0, m = array_length(prevn); j < m; j++)
		    	prevp[j] = prevn[j];
			
			o.x = n.x;
			o.y = n.y;
			o.z = n.z;
		} // side
		
		#region cap end
			for(var j = 0; j < sides; j++) {
		    	var cx0 = prevp[j * 3 + 0];
		    	var cy0 = prevp[j * 3 + 1];
		    	var cz0 = prevp[j * 3 + 2];
		    	
		    	var cx1 = prevp[j * 3 + 0 + 3];
				var cy1 = prevp[j * 3 + 1 + 3];
				var cz1 = prevp[j * 3 + 2 + 3];
				
				var a0 = yaw + (j + 0) * _iside;
				var a1 = yaw + (j + 1) * _iside;
		
				var __u0 = 0.5 + lengthdir_x(0.5, a0);
				var __v0 = 0.5 + lengthdir_y(0.5, a0);
				var __u1 = 0.5 + lengthdir_x(0.5, a1);
				var __v1 = 0.5 + lengthdir_y(0.5, a1);
				
		    	vertex_cape[_in1++] = new __vertex(n.x, n.y, n.z).setNormal(-v.x, -v.y, -v.z).setUV(0.5, 0.5);
				vertex_cape[_in1++] = new __vertex(cx1, cy1, cz1).setNormal(-v.x, -v.y, -v.z).setUV(__u1, __v1);
				vertex_cape[_in1++] = new __vertex(cx0, cy0, cz0).setNormal(-v.x, -v.y, -v.z).setUV(__u0, __v0);
				
				edges[eid++] = new __3dObject_Edge([cx0, cy0, cz0], [cx1, cy1, cz1]);
		    }
	    #endregion
			    
	}
	
	static initModel = function() {
		vertex_side = [];
		vertex_caps = [];
		vertex_cape = [];
		edges       = [];
		
		_ind = 0;
		_in0 = 0;
		_in1 = 0;
		
		for( var i = 0; i < pathAmount; i++ )
			extrudePath(i);
		
		edges          = [ edges ];
		vertex         = endCap? [ vertex_side, vertex_caps, vertex_cape ] : [ vertex_side ];
		material_index = endCap? [  0,  1,  1 ] : [  0 ];
		object_counts  = array_length(vertex);
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}