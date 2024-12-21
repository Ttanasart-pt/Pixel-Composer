function __3dPlaneBend() : __3dObject() constructor {
	VB = [ noone ];
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	smooth      = false;
	
	subdivision = 4;
	bendAxis    = 0;
	bendRadius  = 1;
	
	static initModel = function() {
		var _hs = 1 / 2;
		var _vt = array_create(3 * 2 * subdivision * subdivision);
		var _in = 0;
		
		var amo_ch = (subdivision + 1) * (subdivision + 1);
		var hs  = array_length(heights) == amo_ch;
		var st  = 1 / subdivision;
		var st2 = st * 2;
		
		for( var i = 0; i < subdivision; i++ ) 
		for( var j = 0; j < subdivision; j++ ) {
			var u0 =  i * st;
			var u1 = u0 + st;
			var v0 =  j * st;
			var v1 = v0 + st;
			
			var x0 = u0 - 0.5;
			var x1 = u1 - 0.5;
			var y0 = v0 - 0.5;
			var y1 = v1 - 0.5;
			
			_vt[_in + 0] = new __vertex(x0, y0, 0).setNormal(0., 0., 1.).setUV(u0, v0); 
			_vt[_in + 1] = new __vertex(x1, y1, 0).setNormal(0., 0., 1.).setUV(u1, v1); 
			_vt[_in + 2] = new __vertex(x1, y0, 0).setNormal(0., 0., 1.).setUV(u1, v0); 
			
			_vt[_in + 3] = new __vertex(x0, y0, 0).setNormal(0., 0., 1.).setUV(u0, v0); 
			_vt[_in + 4] = new __vertex(x0, y1, 0).setNormal(0., 0., 1.).setUV(u0, v1); 
			_vt[_in + 5] = new __vertex(x1, y1, 0).setNormal(0., 0., 1.).setUV(u1, v1);
				
			_in += 6;
		}
		
		vertex = [ _vt ];
		updateBend();
	} initModel();
	
	static updateBend = function() {
		var _in  = 0;
		var _vt  = vertex[0];
		var sub  = subdivision;
		var sub1 = sub + 1;
		var st   = 1 / subdivision;
		var st2  = st * 2;
		
		if(VB[0]) vertex_delete_buffer(VB[0]);
		VB[0] = vertex_create_buffer();
		vertex_begin(VB[0], VF);
		
		var vb = VB[0];
		var n = 0, i = 0, j = 0;
		
		repeat( sub * sub ) {
			i = floor(n / sub);
			j = n % sub;
			
			var _v0 = _vt[_in + 0];
			var _v1 = _vt[_in + 1];
			var _v2 = _vt[_in + 2];
			var _v3 = _vt[_in + 3];
			var _v4 = _vt[_in + 4];
			var _v5 = _vt[_in + 5];
			
			////////////////////////////////////////////////////////////////////////////////
			
			var _x0 =  i * st - .5;
			var _x1 = u0 + st - .5;
			var _y0 =  j * st - .5;
			var _y1 = v0 + st - .5;
			
			var x0 = _x0; 
			var y0 = _y0; 
			var z0 = 0;
			
			var x1 = _x1; 
			var y1 = _y1;
			var z1 = 0;
			
			_v0.x = x0; _v0.y = y0;
			_v1.x = x1; _v1.y = y1;
			_v2.x = x1; _v2.y = y0;
			
			_v3.x = x0; _v3.y = y0;
			_v4.x = x0; _v4.y = y1;
			_v5.x = x1; _v5.y = y1;
			
			////////////////////////////////////////////////////////////////////////////////
			
			vertex_pos3(vb, _v0.x,     _v0.y,   _v0.z);
			vertex_norm(vb, _v0.nx,    _v0.ny,  _v0.nz);
			vertex_texc(vb, _v0.u,     _v0.v);
			vertex_colr(vb, _v0.color, _v0.alpha);
			vertex_vec3(vb, 255, 0, 0);
			
			vertex_pos3(vb, _v1.x,     _v1.y,   _v1.z);
			vertex_norm(vb, _v1.nx,    _v1.ny,  _v1.nz);
			vertex_texc(vb, _v1.u,     _v1.v);
			vertex_colr(vb, _v1.color, _v1.alpha);
			vertex_vec3(vb,  0, 255, 0);
			
			vertex_pos3(vb, _v2.x,     _v2.y,   _v2.z);
			vertex_norm(vb, _v2.nx,    _v2.ny,  _v2.nz);
			vertex_texc(vb, _v2.u,     _v2.v);
			vertex_colr(vb, _v2.color, _v2.alpha);
			vertex_vec3(vb, 0, 0, 255);
			
			
			vertex_pos3(vb, _v3.x,     _v3.y,   _v3.z);
			vertex_norm(vb, _v3.nx,    _v3.ny,  _v3.nz);
			vertex_texc(vb, _v3.u,     _v3.v);
			vertex_colr(vb, _v3.color, _v3.alpha);
			vertex_vec3(vb, 255, 0, 0);
			
			vertex_pos3(vb, _v4.x,     _v4.y,   _v4.z);
			vertex_norm(vb, _v4.nx,    _v4.ny,  _v4.nz);
			vertex_texc(vb, _v4.u,     _v4.v);
			vertex_colr(vb, _v4.color, _v4.alpha);
			vertex_vec3(vb, 0, 255, 0);
			
			vertex_pos3(vb, _v5.x,     _v5.y,   _v5.z);
			vertex_norm(vb, _v5.nx,    _v5.ny,  _v5.nz);
			vertex_texc(vb, _v5.u,     _v5.v);
			vertex_colr(vb, _v5.color, _v5.alpha);
			vertex_vec3(vb, 0, 0, 255);
			
			_in += 6;
			
			n++;
		}
		
		vertex_end(VB[0]);
	}
	
	onParameterUpdate = initModel;
}