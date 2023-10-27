function __3dTerrain() : __3dObject() constructor {
	VB = [ noone ];
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.subdivision = 4;
	
	heights = array_create((subdivision + 1) * (subdivision + 1));
	
	static initModel = function() {
		var _hs = 1 / 2;
		var _vt = array_create(3 * 2 * subdivision * subdivision);
		var _in = 0;
		
		var amo_ch = (subdivision + 1) * (subdivision + 1);
		var hs = array_length(heights) == amo_ch;
		
		for( var i = 0; i < subdivision; i++ ) 
		for( var j = 0; j < subdivision; j++ ) {
			var u0 = (i + 0) / subdivision;
			var u1 = (i + 1) / subdivision;
			var v0 = (j + 0) / subdivision;
			var v1 = (j + 1) / subdivision;
			
			var x0 = -0.5 + u0;
			var x1 = -0.5 + u1;
			var y0 = -0.5 + v0;
			var y1 = -0.5 + v1;
			
			var _i0 =  j      * (subdivision + 1) + i;
			var _i1 =  j      * (subdivision + 1) + i + 1;
			var _i2 = (j + 1) * (subdivision + 1) + i;
			var _i3 = (j + 1) * (subdivision + 1) + i + 1;
			
			var _h0 = hs? heights[_i0] : 0;
			var _h1 = hs? heights[_i1] : 0;
			var _h2 = hs? heights[_i2] : 0;
			var _h3 = hs? heights[_i3] : 0;
			
			var _n =   new __vec3(x1 - x0, y0 - y0, _h1 - _h0)
				.cross(new __vec3(x0 - x0, y1 - y0, _h2 - _h0))
				.normalize();
			
			_vt[_in + 0] = new __vertex(x0, y0, _h0).setNormal(_n.x, _n.y, _n.z).setUV(u0, v0); 
			_vt[_in + 1] = new __vertex(x1, y1, _h3).setNormal(_n.x, _n.y, _n.z).setUV(u1, v1); 
			_vt[_in + 2] = new __vertex(x1, y0, _h1).setNormal(_n.x, _n.y, _n.z).setUV(u1, v0); 
			
			_vt[_in + 3] = new __vertex(x0, y0, _h0).setNormal(_n.x, _n.y, _n.z).setUV(u0, v0); 
			_vt[_in + 4] = new __vertex(x0, y1, _h2).setNormal(_n.x, _n.y, _n.z).setUV(u0, v1); 
			_vt[_in + 5] = new __vertex(x1, y1, _h3).setNormal(_n.x, _n.y, _n.z).setUV(u1, v1);
			
			_in += 6;
		}
		
		vertex = [ _vt ];
		VB = build();
	} initModel();
	
	static updateHeight = function(_h) {
		heights = _h;
		var _in = 0;
		var _vt = vertex[0];
		
		if(VB[0]) vertex_delete_buffer(VB[0]);
		VB[0] = vertex_create_buffer();
		vertex_begin(VB[0], VF);
		
		for( var i = 0; i < subdivision; i++ ) 
		for( var j = 0; j < subdivision; j++ ) {
			var u0 = (i + 0) / subdivision;
			var u1 = (i + 1) / subdivision;
			var v0 = (j + 0) / subdivision;
			var v1 = (j + 1) / subdivision;
			
			var x0 = -0.5 + u0;
			var x1 = -0.5 + u1;
			var y0 = -0.5 + v0;
			var y1 = -0.5 + v1;
			
			var _i0 =  j      * (subdivision + 1) + i;
			var _i1 =  j      * (subdivision + 1) + i + 1;
			var _i2 = (j + 1) * (subdivision + 1) + i;
			var _i3 = (j + 1) * (subdivision + 1) + i + 1;
			
			var _h0 = heights[_i0];
			var _h1 = heights[_i1];
			var _h2 = heights[_i2];
			var _h3 = heights[_i3];
			
			var _n =   new __vec3(x1 - x0, y0 - y0, _h1 - _h0)
				.cross(new __vec3(x0 - x0, y1 - y0, _h2 - _h0))
				.normalize();
			
			_vt[_in + 0].z = _h0; _vt[_in + 0].nx = _n.x; _vt[_in + 0].ny = _n.y; _vt[_in + 0].nz = _n.z;
			_vt[_in + 1].z = _h3; _vt[_in + 1].nx = _n.x; _vt[_in + 1].ny = _n.y; _vt[_in + 1].nz = _n.z;
			_vt[_in + 2].z = _h1; _vt[_in + 2].nx = _n.x; _vt[_in + 2].ny = _n.y; _vt[_in + 2].nz = _n.z;
																							
			_vt[_in + 3].z = _h0; _vt[_in + 3].nx = _n.x; _vt[_in + 3].ny = _n.y; _vt[_in + 3].nz = _n.z;
			_vt[_in + 4].z = _h2; _vt[_in + 4].nx = _n.x; _vt[_in + 4].ny = _n.y; _vt[_in + 4].nz = _n.z;
			_vt[_in + 5].z = _h3; _vt[_in + 5].nx = _n.x; _vt[_in + 5].ny = _n.y; _vt[_in + 5].nz = _n.z;
			
			vertex_add_vntc(VB[0], _vt[_in + 0]);
			vertex_add_vntc(VB[0], _vt[_in + 1]);
			vertex_add_vntc(VB[0], _vt[_in + 2]);
			
			vertex_add_vntc(VB[0], _vt[_in + 3]);
			vertex_add_vntc(VB[0], _vt[_in + 4]);
			vertex_add_vntc(VB[0], _vt[_in + 5]);
			
			_in += 6;
		}
		
		vertex_end(VB[0]);
	}
	
	onParameterUpdate = initModel;
}