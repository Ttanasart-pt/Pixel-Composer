function __3dCube() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	separate_faces = false;
	taper_amount = 0;
	taper_axis   = 0;
	
	subdivision  = [ 1, 1, 1 ];
	__p = array_create(8);
	for( var i = 0, n = array_length(__p); i < n; i++ ) __p[i] = [ 0, 0, 0 ];
	
	static __default_cube = function() {
		var p = [[ -1, -1, -1 ], // 0
	             [  1, -1, -1 ], // 1
	             [ -1,  1, -1 ], // 2
	             [  1,  1, -1 ], // 3
	         
	             [ -1, -1,  1 ], // 4
	             [  1, -1,  1 ], // 5
	             [ -1,  1,  1 ], // 6
	             [  1,  1,  1 ]] // 7
		
		if(taper_amount != 0)
		for( var i = 0, n = array_length(p); i < n; i++ ) {
			var _p = p[i];
			var _t = _p[taper_axis] * taper_amount;
			
			_p[(taper_axis + 1) % 3] += sign(_p[(taper_axis + 1) % 3]) * _t;
			_p[(taper_axis + 2) % 3] += sign(_p[(taper_axis + 2) % 3]) * _t;
		}
		
		for( var i = 0, n = array_length(p); i < n; i++ ) { p[i][0] /= 2; p[i][1] /= 2; p[i][2] /= 2; }
		
		var _subx = subdivision[0];
		var _suby = subdivision[1];
		var _subz = subdivision[2];
		
		if(separate_faces) {
			var _f2 = array_create(_suby * _subz * 6);
			var _f3 = array_create(_suby * _subz * 6);
			
			var _f4 = array_create(_subx * _subz * 6);
			var _f5 = array_create(_subx * _subz * 6);
			
			var _f0 = array_create(_subx * _suby * 6);
			var _f1 = array_create(_subx * _suby * 6);
			
		} else {
			var _ff = array_create(_subx * _suby * 6 * 2 + 
			                       _suby * _subz * 6 * 2 + 
			                       _subz * _subx * 6 * 2);
			
			var _f2 = _ff;
			var _f3 = _ff;
			
			var _f4 = _ff;
			var _f5 = _ff;
			
			var _f0 = _ff;
			var _f1 = _ff;
			
		}
		
		var _i = 0;
		for( var i = 0; i < _suby; i++ ) {
			var ly0 =  i      / _suby;
			var ly1 = (i + 1) / _suby;
			
			var _00 = p[6];
			var _01 = p[2];
			var _10 = p[4];
			var _11 = p[0];
			
			var p00 = lerp_d3(_00, _10, ly0, __p[0]);
			var p01 = lerp_d3(_01, _11, ly0, __p[1]);
			var p10 = lerp_d3(_00, _10, ly1, __p[2]);
			var p11 = lerp_d3(_01, _11, ly1, __p[3]);
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
    			var pp00 = lerp_d3(p00, p01, lz0, __p[4]);
    			var pp01 = lerp_d3(p00, p01, lz1, __p[5]);
    			var pp10 = lerp_d3(p10, p11, lz0, __p[6]);
    			var pp11 = lerp_d3(p10, p11, lz1, __p[7]);
    			
				_f2[_i++] = __vertexA(pp10).setNormal(-1, 0, 0).setUV(ly1, lz0);
				_f2[_i++] = __vertexA(pp01).setNormal(-1, 0, 0).setUV(ly0, lz1);
				_f2[_i++] = __vertexA(pp00).setNormal(-1, 0, 0).setUV(ly0, lz0);
				
				_f2[_i++] = __vertexA(pp10).setNormal(-1, 0, 0).setUV(ly1, lz0);
				_f2[_i++] = __vertexA(pp11).setNormal(-1, 0, 0).setUV(ly1, lz1);
				_f2[_i++] = __vertexA(pp01).setNormal(-1, 0, 0).setUV(ly0, lz1);
			}
		}
		
		if(separate_faces) _i = 0;
		for( var i = 0; i < _suby; i++ ) {
			var ly0 =  i      / _suby;
			var ly1 = (i + 1) / _suby;
			
			var _00 = p[5];
			var _01 = p[1];
			var _10 = p[7];
			var _11 = p[3];
			
			var p00 = lerp_d3(_00, _10, ly0, __p[0]);
			var p01 = lerp_d3(_01, _11, ly0, __p[1]);
			var p10 = lerp_d3(_00, _10, ly1, __p[2]);
			var p11 = lerp_d3(_01, _11, ly1, __p[3]);
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
    			var pp00 = lerp_d3(p00, p01, lz0, __p[4]);
    			var pp01 = lerp_d3(p00, p01, lz1, __p[5]);
    			var pp10 = lerp_d3(p10, p11, lz0, __p[6]);
    			var pp11 = lerp_d3(p10, p11, lz1, __p[7]);
    			
				_f3[_i++] = __vertexA(pp00).setNormal( 1, 0, 0).setUV(ly0, lz0);
				_f3[_i++] = __vertexA(pp10).setNormal( 1, 0, 0).setUV(ly1, lz0);
				_f3[_i++] = __vertexA(pp11).setNormal( 1, 0, 0).setUV(ly1, lz1);
				
				_f3[_i++] = __vertexA(pp00).setNormal( 1, 0, 0).setUV(ly0, lz0);
				_f3[_i++] = __vertexA(pp11).setNormal( 1, 0, 0).setUV(ly1, lz1);
				_f3[_i++] = __vertexA(pp01).setNormal( 1, 0, 0).setUV(ly0, lz1);
			}
		}
		
		if(separate_faces) _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var _00 = p[7];
			var _01 = p[3];
			var _10 = p[6];
			var _11 = p[2];
			
			var p00 = lerp_d3(_00, _10, lx0, __p[0]);
			var p01 = lerp_d3(_01, _11, lx0, __p[1]);
			var p10 = lerp_d3(_00, _10, lx1, __p[2]);
			var p11 = lerp_d3(_01, _11, lx1, __p[3]);
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
    			var pp00 = lerp_d3(p00, p01, lz0, __p[4]);
    			var pp01 = lerp_d3(p00, p01, lz1, __p[5]);
    			var pp10 = lerp_d3(p10, p11, lz0, __p[6]);
    			var pp11 = lerp_d3(p10, p11, lz1, __p[7]);
    			
				_f4[_i++] = __vertexA(pp10).setNormal(0,  1, 0).setUV(lx1, lz0);
				_f4[_i++] = __vertexA(pp01).setNormal(0,  1, 0).setUV(lx0, lz1);
				_f4[_i++] = __vertexA(pp00).setNormal(0,  1, 0).setUV(lx0, lz0);
				
				_f4[_i++] = __vertexA(pp10).setNormal(0,  1, 0).setUV(lx1, lz0);
				_f4[_i++] = __vertexA(pp11).setNormal(0,  1, 0).setUV(lx1, lz1);
				_f4[_i++] = __vertexA(pp01).setNormal(0,  1, 0).setUV(lx0, lz1);
			}
		}
		
		if(separate_faces) _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var _00 = p[4];
			var _01 = p[0];
			var _10 = p[5];
			var _11 = p[1];
			
			var p00 = lerp_d3(_00, _10, lx0, __p[0]);
			var p01 = lerp_d3(_01, _11, lx0, __p[1]);
			var p10 = lerp_d3(_00, _10, lx1, __p[2]);
			var p11 = lerp_d3(_01, _11, lx1, __p[3]);
			
			for( var j = 0; j < _subz; j++ ) {
				var lz0 =  j      / _subz;
				var lz1 = (j + 1) / _subz;
				
    			var pp00 = lerp_d3(p00, p01, lz0, __p[4]);
    			var pp01 = lerp_d3(p00, p01, lz1, __p[5]);
    			var pp10 = lerp_d3(p10, p11, lz0, __p[6]);
    			var pp11 = lerp_d3(p10, p11, lz1, __p[7]);
    			
				_f5[_i++] = __vertexA(pp00).setNormal(0, -1, 0).setUV(lx0, lz0);
				_f5[_i++] = __vertexA(pp10).setNormal(0, -1, 0).setUV(lx1, lz0);
				_f5[_i++] = __vertexA(pp11).setNormal(0, -1, 0).setUV(lx1, lz1);
				
				_f5[_i++] = __vertexA(pp00).setNormal(0, -1, 0).setUV(lx0, lz0);
				_f5[_i++] = __vertexA(pp11).setNormal(0, -1, 0).setUV(lx1, lz1);
				_f5[_i++] = __vertexA(pp01).setNormal(0, -1, 0).setUV(lx0, lz1);
			}
		}
		
		if(separate_faces) _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var _00 = p[7];
			var _01 = p[5];
			var _10 = p[6];
			var _11 = p[4];
			
			var p00 = lerp_d3(_00, _10, lx0, __p[0]);
			var p01 = lerp_d3(_01, _11, lx0, __p[1]);
			var p10 = lerp_d3(_00, _10, lx1, __p[2]);
			var p11 = lerp_d3(_01, _11, lx1, __p[3]);
			
			for( var j = 0; j < _suby; j++ ) {
				var ly0 =  j      / _suby;
				var ly1 = (j + 1) / _suby;
				
    			var pp00 = lerp_d3(p00, p01, ly0, __p[4]);
    			var pp01 = lerp_d3(p00, p01, ly1, __p[5]);
    			var pp10 = lerp_d3(p10, p11, ly0, __p[6]);
    			var pp11 = lerp_d3(p10, p11, ly1, __p[7]);
    			
				_f0[_i++] = __vertexA(pp11).setNormal(0, 0,  1).setUV(lx1, ly1);
				_f0[_i++] = __vertexA(pp00).setNormal(0, 0,  1).setUV(lx0, ly0);
				_f0[_i++] = __vertexA(pp01).setNormal(0, 0,  1).setUV(lx0, ly1);
				
				_f0[_i++] = __vertexA(pp11).setNormal(0, 0,  1).setUV(lx1, ly1);
				_f0[_i++] = __vertexA(pp10).setNormal(0, 0,  1).setUV(lx1, ly0);
				_f0[_i++] = __vertexA(pp00).setNormal(0, 0,  1).setUV(lx0, ly0);
			}
		}
		
		if(separate_faces) _i = 0;
		for( var i = 0; i < _subx; i++ ) {
			var lx0 =  i      / _subx;
			var lx1 = (i + 1) / _subx;
			
			var _00 = p[3];
			var _01 = p[1];
			var _10 = p[2];
			var _11 = p[0];
			
			var p00 = lerp_d3(_00, _10, lx0, __p[0]);
			var p01 = lerp_d3(_01, _11, lx0, __p[1]);
			var p10 = lerp_d3(_00, _10, lx1, __p[2]);
			var p11 = lerp_d3(_01, _11, lx1, __p[3]);
			
			for( var j = 0; j < _suby; j++ ) {
				var ly0 =  j      / _suby;
				var ly1 = (j + 1) / _suby;
				
    			var pp00 = lerp_d3(p00, p01, ly0, __p[4]);
    			var pp01 = lerp_d3(p00, p01, ly1, __p[5]);
    			var pp10 = lerp_d3(p10, p11, ly0, __p[6]);
    			var pp11 = lerp_d3(p10, p11, ly1, __p[7]);
    			
				_f1[_i++] = __vertexA(pp11).setNormal(0, 0, -1).setUV(lx1, ly1);
				_f1[_i++] = __vertexA(pp01).setNormal(0, 0, -1).setUV(lx0, ly1);
				_f1[_i++] = __vertexA(pp00).setNormal(0, 0, -1).setUV(lx0, ly0);
				
				_f1[_i++] = __vertexA(pp11).setNormal(0, 0, -1).setUV(lx1, ly1);
				_f1[_i++] = __vertexA(pp00).setNormal(0, 0, -1).setUV(lx0, ly0);
				_f1[_i++] = __vertexA(pp10).setNormal(0, 0, -1).setUV(lx1, ly0);
			}
		}
		
		return separate_faces? [ _f0, _f1, _f2, _f3, _f4, _f5 ] : [ _ff ];
	}
	
	static initModel = function() {
		
		vertex        = __default_cube();
		object_counts = array_length(vertex);
		
		VB = build();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}