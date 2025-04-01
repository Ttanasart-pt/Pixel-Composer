function __3dCube() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	separate_faces = false;
	taper_amount = 0;
	taper_axis   = 0;
	
	subdivision  = [ 1, 1, 1 ];
	
	static __default_cube = function() {
		var p = [[ -1, -1, -1 ], // 0
	             [  1, -1, -1 ], // 1
	             [ -1,  1, -1 ], // 2
	             [  1,  1, -1 ], // 3
	         
	             [ -1, -1,  1 ], // 4
	             [  1, -1,  1 ], // 5
	             [ -1,  1,  1 ], // 6
	             [  1,  1,  1 ]] // 7
		
		if(taper_amount != 0) {
			for( var i = 0, n = array_length(p); i < n; i++ ) {
				var _p = p[i];
				var _t = _p[taper_axis] * taper_amount;
				
				_p[(taper_axis + 1) % 3] += sign(_p[(taper_axis + 1) % 3]) * _t;
				_p[(taper_axis + 2) % 3] += sign(_p[(taper_axis + 2) % 3]) * _t;
			}
		}
		
		for( var i = 0, n = array_length(p); i < n; i++ ) { p[i][0] /= 2; p[i][1] /= 2; p[i][2] /= 2; }
		
		var _subx = subdivision[0];
		var _suby = subdivision[1];
		var _subz = subdivision[2];
		
		var _f2 = array_create(_suby * _subz * 6);
		var _f3 = array_create(_suby * _subz * 6);
		
		var _f4 = array_create(_subx * _subz * 6);
		var _f5 = array_create(_subx * _subz * 6);
		
		var _f0 = array_create(_subx * _suby * 6);
		var _f1 = array_create(_subx * _suby * 6);
		
		var _i = 0;
		for( var i = 0; i < _suby; i++ ) {
			var ly0 =  i      / _suby;
			var ly1 = (i + 1) / _suby;
			
			var p00 = p[6];
			var p01 = p[2];
			var p10 = p[4];
			var p11 = p[0];
			
			var _x0 = p00[0];
			var _x1 = p01[0];
			var _x2 = p10[0];
			var _x3 = p11[0];
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
				var _y0 = lerp(p00[1], p10[1], ly0);
				var _z0 = lerp(p00[2], p01[2], lz0);
				
				var _y1 = lerp(p01[1], p11[1], ly0);
				var _z1 = lerp(p00[2], p01[2], lz1);
				
				var _y2 = lerp(p00[1], p10[1], ly1);
				var _z2 = lerp(p10[2], p11[2], lz0);
				
				var _y3 = lerp(p01[1], p11[1], ly1);
				var _z3 = lerp(p10[2], p11[2], lz1);
				
				_f2[_i++] = new __vertex(_x2, _y2, _z2).setNormal(-1, 0, 0).setUV(ly1, lz0);
				_f2[_i++] = new __vertex(_x1, _y1, _z1).setNormal(-1, 0, 0).setUV(ly0, lz1);
				_f2[_i++] = new __vertex(_x0, _y0, _z0).setNormal(-1, 0, 0).setUV(ly0, lz0);
				
				_f2[_i++] = new __vertex(_x2, _y2, _z2).setNormal(-1, 0, 0).setUV(ly1, lz0);
				_f2[_i++] = new __vertex(_x3, _y3, _z3).setNormal(-1, 0, 0).setUV(ly1, lz1);
				_f2[_i++] = new __vertex(_x1, _y1, _z1).setNormal(-1, 0, 0).setUV(ly0, lz1);
			}
		}
		
		var _i = 0;
		for( var i = 0; i < _suby; i++ ) {
			var ly0 =  i      / _suby;
			var ly1 = (i + 1) / _suby;
			
			var p00 = p[5];
			var p01 = p[1];
			var p10 = p[7];
			var p11 = p[3];
			
			var _x0 = p00[0];
			var _x1 = p01[0];
			var _x2 = p10[0];
			var _x3 = p11[0];
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
				var _y0 = lerp(p00[1], p10[1], ly0);
				var _z0 = lerp(p00[2], p01[2], lz0);
				
				var _y1 = lerp(p01[1], p11[1], ly0);
				var _z1 = lerp(p00[2], p01[2], lz1);
				
				var _y2 = lerp(p00[1], p10[1], ly1);
				var _z2 = lerp(p10[2], p11[2], lz0);
				
				var _y3 = lerp(p01[1], p11[1], ly1);
				var _z3 = lerp(p10[2], p11[2], lz1);
				
				_f3[_i++] = new __vertex(_x0, _y0, _z0).setNormal( 1, 0, 0).setUV(ly0, lz0);
				_f3[_i++] = new __vertex(_x2, _y2, _z2).setNormal( 1, 0, 0).setUV(ly1, lz0);
				_f3[_i++] = new __vertex(_x3, _y3, _z3).setNormal( 1, 0, 0).setUV(ly1, lz1);
				
				_f3[_i++] = new __vertex(_x0, _y0, _z0).setNormal( 1, 0, 0).setUV(ly0, lz0);
				_f3[_i++] = new __vertex(_x3, _y3, _z3).setNormal( 1, 0, 0).setUV(ly1, lz1);
				_f3[_i++] = new __vertex(_x1, _y1, _z1).setNormal( 1, 0, 0).setUV(ly0, lz1);
			}
		}
		
		var _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var p00 = p[7];
			var p01 = p[3];
			var p10 = p[6];
			var p11 = p[2];
			
			var _y0 = p00[1];
			var _y1 = p01[1];
			var _y2 = p10[1];
			var _y3 = p11[1];
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
				var _x0 = lerp(p00[0], p10[0], lx0);
				var _z0 = lerp(p00[2], p01[2], lz0);
				
				var _x1 = lerp(p01[0], p11[0], lx0);
				var _z1 = lerp(p00[2], p01[2], lz1);
				
				var _x2 = lerp(p00[0], p10[0], lx1);
				var _z2 = lerp(p10[2], p11[2], lz0);
				
				var _x3 = lerp(p01[0], p11[0], lx1);
				var _z3 = lerp(p10[2], p11[2], lz1);
				
				_f4[_i++] = new __vertex(_x2, _y2, _z2).setNormal(0,  1, 0).setUV(lx1, lz0);
				_f4[_i++] = new __vertex(_x1, _y1, _z1).setNormal(0,  1, 0).setUV(lx0, lz1);
				_f4[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0,  1, 0).setUV(lx0, lz0);
				
				_f4[_i++] = new __vertex(_x2, _y2, _z2).setNormal(0,  1, 0).setUV(lx1, lz0);
				_f4[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0,  1, 0).setUV(lx1, lz1);
				_f4[_i++] = new __vertex(_x1, _y1, _z1).setNormal(0,  1, 0).setUV(lx0, lz1);
			}
		}
		
		var _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var p00 = p[4];
			var p01 = p[0];
			var p10 = p[5];
			var p11 = p[1];
			
			var _y0 = p00[1];
			var _y1 = p01[1];
			var _y2 = p10[1];
			var _y3 = p11[1];
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
				var _x0 = lerp(p00[0], p10[0], lx0);
				var _z0 = lerp(p00[2], p01[2], lz0);
				
				var _x1 = lerp(p01[0], p11[0], lx0);
				var _z1 = lerp(p00[2], p01[2], lz1);
				
				var _x2 = lerp(p00[0], p10[0], lx1);
				var _z2 = lerp(p10[2], p11[2], lz0);
				
				var _x3 = lerp(p01[0], p11[0], lx1);
				var _z3 = lerp(p10[2], p11[2], lz1);
				
				_f5[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0, -1, 0).setUV(lx0, lz0);
				_f5[_i++] = new __vertex(_x2, _y2, _z2).setNormal(0, -1, 0).setUV(lx1, lz0);
				_f5[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0, -1, 0).setUV(lx1, lz1);
				
				_f5[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0, -1, 0).setUV(lx0, lz0);
				_f5[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0, -1, 0).setUV(lx1, lz1);
				_f5[_i++] = new __vertex(_x1, _y1, _z1).setNormal(0, -1, 0).setUV(lx0, lz1);
			}
		}
		
		var _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var p00 = p[7];
			var p01 = p[5];
			var p10 = p[6];
			var p11 = p[4];
			
			var _z0 = p00[2];
			var _z1 = p01[2];
			var _z2 = p10[2];
			var _z3 = p11[2];
			
			for( var j = 0; j < _suby; j++ ) {
				var ly0 =  j      / _suby;
				var ly1 = (j + 1) / _suby;
				
				var _x0 = lerp(p00[0], p10[0], lx0);
				var _y0 = lerp(p00[1], p01[1], ly0);
				
				var _x1 = lerp(p01[0], p11[0], lx0);
				var _y1 = lerp(p00[1], p01[1], ly1);
				
				var _x2 = lerp(p00[0], p10[0], lx1);
				var _y2 = lerp(p10[1], p11[1], ly0);
				
				var _x3 = lerp(p01[0], p11[0], lx1);
				var _y3 = lerp(p10[1], p11[1], ly1);
				
				_f0[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0, 0,  1).setUV(lx1, ly1);
				_f0[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0, 0,  1).setUV(lx0, ly0);
				_f0[_i++] = new __vertex(_x1, _y1, _z1).setNormal(0, 0,  1).setUV(lx0, ly1);
				
				_f0[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0, 0,  1).setUV(lx1, ly1);
				_f0[_i++] = new __vertex(_x2, _y2, _z2).setNormal(0, 0,  1).setUV(lx1, ly0);
				_f0[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0, 0,  1).setUV(lx0, ly0);
			}
		}
		
		var _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var p00 = p[3];
			var p01 = p[1];
			var p10 = p[2];
			var p11 = p[0];
			
			var _z0 = p00[2];
			var _z1 = p01[2];
			var _z2 = p10[2];
			var _z3 = p11[2];
			
			for( var j = 0; j < _suby; j++ ) {
				var ly0 =  j      / _suby;
				var ly1 = (j + 1) / _suby;
				
				var _x0 = lerp(p00[0], p10[0], lx0);
				var _y0 = lerp(p00[1], p01[1], ly0);
				
				var _x1 = lerp(p01[0], p11[0], lx0);
				var _y1 = lerp(p00[1], p01[1], ly1);
				
				var _x2 = lerp(p00[0], p10[0], lx1);
				var _y2 = lerp(p10[1], p11[1], ly0);
				
				var _x3 = lerp(p01[0], p11[0], lx1);
				var _y3 = lerp(p10[1], p11[1], ly1);
				
				_f1[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0, 0, -1).setUV(lx1, ly1);
				_f1[_i++] = new __vertex(_x1, _y1, _z1).setNormal(0, 0, -1).setUV(lx0, ly1);
				_f1[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0, 0, -1).setUV(lx0, ly0);
				
				_f1[_i++] = new __vertex(_x3, _y3, _z3).setNormal(0, 0, -1).setUV(lx1, ly1);
				_f1[_i++] = new __vertex(_x0, _y0, _z0).setNormal(0, 0, -1).setUV(lx0, ly0);
				_f1[_i++] = new __vertex(_x2, _y2, _z2).setNormal(0, 0, -1).setUV(lx1, ly0);
			}
		}
		
		return [ _f0, _f1, _f2, _f3, _f4, _f5 ];
	}
	
	static initModel = function() {
		
		vertex = __default_cube();
		if(!separate_faces) vertex = [ array_merge_array(vertex) ];
		object_counts = separate_faces? 6 : 1;
		
		VB = build();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}