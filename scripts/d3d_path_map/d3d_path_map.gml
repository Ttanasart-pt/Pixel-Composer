function __3dPathMap() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 1;
	
	points     = [];
	pathCount  = 0;
	pathSubd   = 0;
	subdivide  = 0;
	
	invertNorm = false;
	smooth     = false;
	
	static initModel = function() {
		var _verts = [];
		var _edges = [];
		var _ind   = 0;
		
		var vst = 1 / pathCount;
		var ust = 1 / pathSubd;
		var sub = 1 / subdivide;
		
		for( var p = 0; p < pathCount - 1; p++ ) {
			var ip0 = p * pathSubd;
			var ip1 = p * pathSubd + pathSubd;
			
			var v0  = p * vst; 
			var v1  = p * vst + vst; 
			
			for( var i = 0; i < pathSubd - 1; i++ ) {
				var i00 = ip0 + i;
				var i01 = ip0 + i + 1;
				var i10 = ip1 + i;
				var i11 = ip1 + i + 1;
				
				var u0  = i * ust; 
				var u1  = i * ust + ust; 
			
				var p00 = points[i00];
				var p01 = points[i01];
				var p10 = points[i10];
				var p11 = points[i11];
				
				for( var f = 0; f < subdivide; f++ ) {
					var i0 = _ind;
					
					var t0 = f * sub;
					var t1 = f * sub + sub;
					
					var p00x = lerp(p00[0], p10[0], t0);
					var p00y = lerp(p00[1], p10[1], t0);
					var p00z = lerp(p00[2], p10[2], t0);
					
					var p01x = lerp(p01[0], p11[0], t0);
					var p01y = lerp(p01[1], p11[1], t0);
					var p01z = lerp(p01[2], p11[2], t0);
					
					var p10x = lerp(p00[0], p10[0], t1);
					var p10y = lerp(p00[1], p10[1], t1);
					var p10z = lerp(p00[2], p10[2], t1);
					
					var p11x = lerp(p01[0], p11[0], t1);
					var p11y = lerp(p01[1], p11[1], t1);
					var p11z = lerp(p01[2], p11[2], t1);
					
					var vv0 = lerp(v0, v1, t0);
					var vv1 = lerp(v0, v1, t1);
					
					if(invertNorm) {
						_verts[i0+0] = new __vertex(p00x, p00y, p00z).setUV(u0, vv0);
						_verts[i0+1] = new __vertex(p01x, p01y, p01z).setUV(u1, vv0);
						_verts[i0+2] = new __vertex(p10x, p10y, p10z).setUV(u0, vv1);
						
						_verts[i0+3] = new __vertex(p10x, p10y, p10z).setUV(u0, vv1);
						_verts[i0+4] = new __vertex(p01x, p01y, p01z).setUV(u1, vv0);
						_verts[i0+5] = new __vertex(p11x, p11y, p11z).setUV(u1, vv1);
							
					} else {
						_verts[i0+0] = new __vertex(p00x, p00y, p00z).setUV(u0, vv0);
						_verts[i0+1] = new __vertex(p10x, p10y, p10z).setUV(u0, vv1);
						_verts[i0+2] = new __vertex(p01x, p01y, p01z).setUV(u1, vv0);
						
						_verts[i0+3] = new __vertex(p01x, p01y, p01z).setUV(u1, vv0);
						_verts[i0+4] = new __vertex(p10x, p10y, p10z).setUV(u0, vv1);
						_verts[i0+5] = new __vertex(p11x, p11y, p11z).setUV(u1, vv1);
					}
					
					vertex_face_normal(_verts[i0+0], _verts[i0+1], _verts[i0+2]);
					vertex_face_normal(_verts[i0+3], _verts[i0+4], _verts[i0+5]);
					
					_ind = i0+6;
				}
			}
		}
		
		vertex = [ _verts ];
		edges  = [ _edges ];
		VB     = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}