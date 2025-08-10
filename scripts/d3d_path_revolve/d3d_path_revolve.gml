function __3dPathRevolve() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	object_counts = 3;
	
	origin = new __vec2();
	points = [];
	sides  = 8;
	caps   = 0;
	
	smooth = false;
	
	static initModel = function() {
		
		edges   = [];
		var eid = 0;
		
		var _astp = 360 / sides;
		var _ustp = 1 / sides;
		var _vstp = 1 / array_length(points);
		var _in0  = 0;
		
		var vside = [];
		for( var i = 0; i < sides; i++ ) {
			var a0 =  i * _astp;
			var a1 = a0 + _astp;
			
			var _u0 =   i * _ustp;
			var _u1 = _u0 + _ustp;
			
			for( var j = 0, m = array_length(points) - 1; j < m; j++ ) {
				var _p0 = points[j + 0];
				var _p1 = points[j + 1];
				
				var x0 = lengthdir_x(_p0[0], a0);
				var y0 = lengthdir_y(_p0[0], a0);
				var z0 = -_p0[1];
				
				var x1 = lengthdir_x(_p1[0], a0);
				var y1 = lengthdir_y(_p1[0], a0);
				var z1 = -_p1[1];
				
				var x2 = lengthdir_x(_p1[0], a1);
				var y2 = lengthdir_y(_p1[0], a1);
				var z2 = -_p1[1];
				
				var x3 = lengthdir_x(_p0[0], a1);
				var y3 = lengthdir_y(_p0[0], a1);
				var z3 = -_p0[1];
				
				var _v0 =   j * _vstp;
				var _v1 = _v0 + _vstp;
				
				if(smooth) {
					var nx0 = x0 / _p0[0];
					var ny0 = y0 / _p0[0];
					var nz0 = 0;
					
					var nx1 = x1 / _p1[0];
					var ny1 = y1 / _p1[0];
					var nz1 = 0;
					
					var nx2 = x2 / _p1[0];
					var ny2 = y2 / _p1[0];
					var nz2 = 0;
					
					var nx3 = x3 / _p0[0];
					var ny3 = y3 / _p0[0];
					var nz3 = 0;
					
				} else {
					var _n1 = new __vec3(x0 - x1, y0 - y1, z0 - z1);
					var _n2 = new __vec3(x3 - x0, y3 - y0, z3 - z0);
					var _nc = _n1.cross(_n2)._normalize();
					
					var nx0 = _nc.x;
					var ny0 = _nc.y;
					var nz0 = _nc.z;
					
					var nx1 = _nc.x;
					var ny1 = _nc.y;
					var nz1 = _nc.z;
					
					var nx2 = _nc.x;
					var ny2 = _nc.y;
					var nz2 = _nc.z;
					
					var nx3 = _nc.x;
					var ny3 = _nc.y;
					var nz3 = _nc.z;
					
				}
				
				vside[_in0++] = new __vertex(x0, y0, z0).setNormal(nx0, ny0, nz0).setUV(_u0, _v0);
				vside[_in0++] = new __vertex(x1, y1, z1).setNormal(nx1, ny1, nz1).setUV(_u0, _v1);
				vside[_in0++] = new __vertex(x2, y2, z2).setNormal(nx2, ny2, nz2).setUV(_u1, _v1);
				
				vside[_in0++] = new __vertex(x2, y2, z2).setNormal(nx2, ny2, nz2).setUV(_u1, _v1);
				vside[_in0++] = new __vertex(x3, y3, z3).setNormal(nx3, ny3, nz3).setUV(_u1, _v0);
				vside[_in0++] = new __vertex(x0, y0, z0).setNormal(nx0, ny0, nz0).setUV(_u0, _v0);
				
				edges[eid++] = new __3dObject_Edge([x0, y0, z0], [x1, y1, z1]);
				edges[eid++] = new __3dObject_Edge([x1, y1, z1], [x2, y2, z2]);
				edges[eid++] = new __3dObject_Edge([x2, y2, z2], [x3, y3, z3]);
				edges[eid++] = new __3dObject_Edge([x3, y3, z3], [x0, y0, z0]);
			}
		}
		
		vertex = [ vside ];
		
		if(caps & 0b01) {
			var vcaps = [];
			var _p0   = points[0];
			_in0 = 0;
			
			for( var i = 0; i < sides; i++ ) {
				var a0 =  i * _astp;
				var a1 = a0 + _astp;
				
				var zz = -_p0[1];
				
				var x0 = lengthdir_x(1, a0);
				var y0 = lengthdir_y(1, a0);
				
				var x1 = lengthdir_x(1, a1);
				var y1 = lengthdir_y(1, a1);
				
				vcaps[_in0++] = new __vertex( 0,  0, zz).setNormal(0, 0, 1).setUV(0.5, 0.5);
				vcaps[_in0++] = new __vertex(x0 * _p0[0], y0 * _p0[0], zz).setNormal(0, 0, 1).setUV(.5 + x0 * .5, .5 + y0 * .5);
				vcaps[_in0++] = new __vertex(x1 * _p0[0], y1 * _p0[0], zz).setNormal(0, 0, 1).setUV(.5 + x1 * .5, .5 + y1 * .5);
				
			}
			
			array_push(vertex, vcaps);
		}
		
		if(caps & 0b10) {
			var vcape = [];
			var _p0   = array_last(points);
			_in0 = 0;
			
			for( var i = 0; i < sides; i++ ) {
				var a0 =  i * _astp;
				var a1 = a0 + _astp;
				
				var zz = -_p0[1];
				
				var x0 = lengthdir_x(1, a0);
				var y0 = lengthdir_y(1, a0);
				
				var x1 = lengthdir_x(1, a1);
				var y1 = lengthdir_y(1, a1);
				
				vcape[_in0++] = new __vertex( 0,  0, zz).setNormal(0, 0, -1).setUV(0.5, 0.5);
				vcape[_in0++] = new __vertex(x1 * _p0[0], y1 * _p0[0], zz).setNormal(0, 0, -1).setUV(.5 + x1 * .5, .5 + y1 * .5);
				vcape[_in0++] = new __vertex(x0 * _p0[0], y0 * _p0[0], zz).setNormal(0, 0, -1).setUV(.5 + x0 * .5, .5 + y0 * .5);
				
			}
			
			array_push(vertex, vcape);
		}
		
		object_counts = array_length(vertex);
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}