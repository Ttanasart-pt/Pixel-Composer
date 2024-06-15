function __3dTerrain() : __3dObject() constructor {
	VB = [ noone ];
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	smooth      = false;
	
	self.subdivision = 4;
	
	heights = array_create((subdivision + 1) * (subdivision + 1));
	
	static initModel = function() {
		print("Init")
		
		var _hs = 1 / 2;
		var _vt = array_create(3 * 2 * subdivision * subdivision);
		var _in = 0;
		
		var amo_ch = (subdivision + 1) * (subdivision + 1);
		var hs  = array_length(heights) == amo_ch;
		var st  = 1 / subdivision;
		var st2 = st * 2;
		
		if(!hs) {
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
			
		} else {
		
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
				
				var _h0 = heights[ j      * (subdivision + 1) + i    ];
				var _h1 = heights[ j      * (subdivision + 1) + i + 1];
				var _h2 = heights[(j + 1) * (subdivision + 1) + i    ];
				var _h3 = heights[(j + 1) * (subdivision + 1) + i + 1];
				
				if(smooth) {
					
					var _h4  = heights[clamp(j    , 0, subdivision) * (subdivision + 1) + clamp(i - 1, 0, subdivision)];
					var _h5  = heights[clamp(j - 1, 0, subdivision) * (subdivision + 1) + clamp(i    , 0, subdivision)];
					var _h6  = heights[clamp(j - 1, 0, subdivision) * (subdivision + 1) + clamp(i + 1, 0, subdivision)];
					var _h7  = heights[clamp(j    , 0, subdivision) * (subdivision + 1) + clamp(i + 2, 0, subdivision)];
					var _h8  = heights[clamp(j + 1, 0, subdivision) * (subdivision + 1) + clamp(i + 2, 0, subdivision)];
					var _h9  = heights[clamp(j + 2, 0, subdivision) * (subdivision + 1) + clamp(i + 1, 0, subdivision)];
					var _h10 = heights[clamp(j + 2, 0, subdivision) * (subdivision + 1) + clamp(i    , 0, subdivision)];
					var _h11 = heights[clamp(j + 1, 0, subdivision) * (subdivision + 1) + clamp(i - 1, 0, subdivision)];
					
					////////////////////////////////////////////////////////////////////////////////
					
					var _nx0 = st2, _ny0 = 0,  _nz0 = _h1 - _h4;
					var _nx1 = 0,  _ny1 = st2, _nz1 = _h2 - _h5;
					
					var _cx = _ny0 * _nz1 - _nz0 * _ny1;
				    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
				    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
				    
				    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
				    
				    var _n0x = _cx / len;
					var _n0y = _cy / len;
					var _n0z = _cz / len;
					
					////////////////////////////////////////////////////////////////////////////////
					
					var _nx0 = st2, _ny0 = 0,  _nz0 = _h7 - _h0;
					var _nx1 = 0,  _ny1 = st2, _nz1 = _h3 - _h6;
					
					var _cx = _ny0 * _nz1 - _nz0 * _ny1;
				    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
				    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
				    
				    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
				    
				    var _n1x = _cx / len;
					var _n1y = _cy / len;
					var _n1z = _cz / len;
					
					////////////////////////////////////////////////////////////////////////////////
					
					var _nx0 = st2, _ny0 = 0,  _nz0 = _h3 - _h11;
					var _nx1 = 0,  _ny1 = st2, _nz1 = _h10 - _h0;
					
					var _cx = _ny0 * _nz1 - _nz0 * _ny1;
				    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
				    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
				    
				    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
				    
				    var _n2x = _cx / len;
					var _n2y = _cy / len;
					var _n2z = _cz / len;
					
					////////////////////////////////////////////////////////////////////////////////
					
					var _nx0 = st2, _ny0 = 0,  _nz0 = _h8 - _h2;
					var _nx1 = 0,  _ny1 = st2, _nz1 = _h9 - _h1;
					
					var _cx = _ny0 * _nz1 - _nz0 * _ny1;
				    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
				    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
				    
				    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
				    
				    var _n3x = _cx / len;
					var _n3y = _cy / len;
					var _n3z = _cz / len;
					
					////////////////////////////////////////////////////////////////////////////////
					
					_vt[_in + 0] = new __vertex(x0, y0, _h0).setNormal(_n0x, _n0y, _n0z).setUV(u0, v0); 
					_vt[_in + 1] = new __vertex(x1, y1, _h3).setNormal(_n3x, _n3y, _n3z).setUV(u1, v1); 
					_vt[_in + 2] = new __vertex(x1, y0, _h1).setNormal(_n1x, _n1y, _n1z).setUV(u1, v0); 
					
					_vt[_in + 3] = new __vertex(x0, y0, _h0).setNormal(_n0x, _n0y, _n0z).setUV(u0, v0); 
					_vt[_in + 4] = new __vertex(x0, y1, _h2).setNormal(_n2x, _n2y, _n2z).setUV(u0, v1); 
					_vt[_in + 5] = new __vertex(x1, y1, _h3).setNormal(_n3x, _n3y, _n3z).setUV(u1, v1);
					
				} else {
					var _nx0 = st;
					var _ny0 = 0;
					var _nz0 = _h1 - _h0;
					var _nx1 = 0;
					var _ny1 = st;
					var _nz1 = _h2 - _h0;
					
					var _cx = _ny0 * _nz1 - _nz0 * _ny1;
				    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
				    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
				    
				    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
				    
				    var _nx = _cx / len;
					var _ny = _cy / len;
					var _nz = _cz / len;
					
					_vt[_in + 0] = new __vertex(x0, y0, _h0).setNormal(_nx, _ny, _nz).setUV(u0, v0); 
					_vt[_in + 1] = new __vertex(x1, y1, _h3).setNormal(_nx, _ny, _nz).setUV(u1, v1); 
					_vt[_in + 2] = new __vertex(x1, y0, _h1).setNormal(_nx, _ny, _nz).setUV(u1, v0); 
					
					_vt[_in + 3] = new __vertex(x0, y0, _h0).setNormal(_nx, _ny, _nz).setUV(u0, v0); 
					_vt[_in + 4] = new __vertex(x0, y1, _h2).setNormal(_nx, _ny, _nz).setUV(u0, v1); 
					_vt[_in + 5] = new __vertex(x1, y1, _h3).setNormal(_nx, _ny, _nz).setUV(u1, v1);
					
				}
					
				_in += 6;
			}
		}
		
		vertex = [ _vt ];
		VB = build();
	} initModel();
	
	static updateHeight = function(_h) {
		heights = _h;
		var _in = 0;
		var _vt = vertex[0];
		
		var sub  = subdivision;
		var sub1 = sub + 1;
		var st   = 1 / subdivision;
		var st2  = st * 2;
		
		if(VB[0]) vertex_delete_buffer(VB[0]);
		VB[0] = vertex_create_buffer();
		vertex_begin(VB[0], VF);
		
		var vb = VB[0];
		var n = 0, i = 0, j = 0;
		
		if(smooth) {
			repeat( sub * sub ) {
				
				var _h0 = _h[ j      * sub1 + i    ];
				var _h1 = _h[ j      * sub1 + i + 1];
				var _h2 = _h[(j + 1) * sub1 + i    ];
				var _h3 = _h[(j + 1) * sub1 + i + 1];
				
				var _v0 = _vt[_in + 0];
				var _v1 = _vt[_in + 1];
				var _v2 = _vt[_in + 2];
				var _v3 = _vt[_in + 3];
				var _v4 = _vt[_in + 4];
				var _v5 = _vt[_in + 5];
		
				var _h4  = _h[     j           * sub1 + max(i - 1, 0)   ];
				var _h5  = _h[ max(j - 1, 0)   * sub1 + i               ];
				var _h6  = _h[ max(j - 1, 0)   * sub1 + min(i + 1, sub) ];
				var _h7  = _h[     j           * sub1 + min(i + 2, sub) ];
				var _h8  = _h[ min(j + 1, sub) * sub1 + min(i + 2, sub) ];
				var _h9  = _h[ min(j + 2, sub) * sub1 + min(i + 1, sub) ];
				var _h10 = _h[ min(j + 2, sub) * sub1 + i               ];
				var _h11 = _h[ min(j + 1, sub) * sub1 + max(i - 1, 0)   ];
				
				////////////////////////////////////////////////////////////////////////////////
				
				var _nx0 = st2, _ny0 = 0,  _nz0 = _h1 - _h4;
				var _nx1 = 0,  _ny1 = st2, _nz1 = _h2 - _h5;
				
				var _cx = _ny0 * _nz1 - _nz0 * _ny1;
			    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
			    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
			    
			    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
			    
			    var _n0x = _cx / len;
				var _n0y = _cy / len;
				var _n0z = _cz / len;
				
				////////////////////////////////////////////////////////////////////////////////
				
				var _nx0 = st2, _ny0 = 0,  _nz0 = _h7 - _h0;
				var _nx1 = 0,  _ny1 = st2, _nz1 = _h3 - _h6;
				
				var _cx = _ny0 * _nz1 - _nz0 * _ny1;
			    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
			    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
			    
			    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
			    
			    var _n1x = _cx / len;
				var _n1y = _cy / len;
				var _n1z = _cz / len;
				
				////////////////////////////////////////////////////////////////////////////////
				
				var _nx0 = st2, _ny0 = 0,  _nz0 = _h3 - _h11;
				var _nx1 = 0,  _ny1 = st2, _nz1 = _h10 - _h0;
				
				var _cx = _ny0 * _nz1 - _nz0 * _ny1;
			    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
			    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
			    
			    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
			    
			    var _n2x = _cx / len;
				var _n2y = _cy / len;
				var _n2z = _cz / len;
				
				////////////////////////////////////////////////////////////////////////////////
				
				var _nx0 = st2, _ny0 = 0,  _nz0 = _h8 - _h2;
				var _nx1 = 0,  _ny1 = st2, _nz1 = _h9 - _h1;
				
				var _cx = _ny0 * _nz1 - _nz0 * _ny1;
			    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
			    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
			    
			    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
			    
			    var _n3x = _cx / len;
				var _n3y = _cy / len;
				var _n3z = _cz / len;
				
				////////////////////////////////////////////////////////////////////////////////
				
				_v0.z = _h0; _v0.nx = _n0x; _v0.ny = _n0y; _v0.nz = _n0z;
				_v1.z = _h3; _v1.nx = _n3x; _v1.ny = _n3y; _v1.nz = _n3z;
				_v2.z = _h1; _v2.nx = _n1x; _v2.ny = _n1y; _v2.nz = _n1z;
																								
				_v3.z = _h0; _v3.nx = _n0x; _v3.ny = _n0y; _v3.nz = _n0z;
				_v4.z = _h2; _v4.nx = _n2x; _v4.ny = _n2y; _v4.nz = _n2z;
				_v5.z = _h3; _v5.nx = _n3x; _v5.ny = _n3y; _v5.nz = _n3z;
			
				vertex_position_3d(vb, _v0.x,     _v0.y,   _v0.z);
				vertex_normal(     vb, _v0.nx,    _v0.ny,  _v0.nz);
				vertex_texcoord(   vb, _v0.u,     _v0.v);
				vertex_color(      vb, _v0.color, _v0.alpha);
				
				vertex_position_3d(vb, _v1.x,     _v1.y,   _v1.z);
				vertex_normal(     vb, _v1.nx,    _v1.ny,  _v1.nz);
				vertex_texcoord(   vb, _v1.u,     _v1.v);
				vertex_color(      vb, _v1.color, _v1.alpha);
				
				vertex_position_3d(vb, _v2.x,     _v2.y,   _v2.z);
				vertex_normal(     vb, _v2.nx,    _v2.ny,  _v2.nz);
				vertex_texcoord(   vb, _v2.u,     _v2.v);
				vertex_color(      vb, _v2.color, _v2.alpha);
				
				
				vertex_position_3d(vb, _v3.x,     _v3.y,   _v3.z);
				vertex_normal(     vb, _v3.nx,    _v3.ny,  _v3.nz);
				vertex_texcoord(   vb, _v3.u,     _v3.v);
				vertex_color(      vb, _v3.color, _v3.alpha);
				
				vertex_position_3d(vb, _v4.x,     _v4.y,   _v4.z);
				vertex_normal(     vb, _v4.nx,    _v4.ny,  _v4.nz);
				vertex_texcoord(   vb, _v4.u,     _v4.v);
				vertex_color(      vb, _v4.color, _v4.alpha);
				
				vertex_position_3d(vb, _v5.x,     _v5.y,   _v5.z);
				vertex_normal(     vb, _v5.nx,    _v5.ny,  _v5.nz);
				vertex_texcoord(   vb, _v5.u,     _v5.v);
				vertex_color(      vb, _v5.color, _v5.alpha);
				
				_in += 6;
				
				n++;
				i = floor(n / sub);
				j = n % sub;
			}
			
			
		} else {
			repeat( sub * sub ) {
				var _h0 = _h[ j      * sub1 + i    ];
				var _h1 = _h[ j      * sub1 + i + 1];
				var _h2 = _h[(j + 1) * sub1 + i    ];
				var _h3 = _h[(j + 1) * sub1 + i + 1];
				
				var _v0 = _vt[_in + 0];
				var _v1 = _vt[_in + 1];
				var _v2 = _vt[_in + 2];
				var _v3 = _vt[_in + 3];
				var _v4 = _vt[_in + 4];
				var _v5 = _vt[_in + 5];
		
				var _nx0 = st, _ny0 = 0,  _nz0 = _h1 - _h0;
				var _nx1 = 0,  _ny1 = st, _nz1 = _h2 - _h0;
				
				var _cx = _ny0 * _nz1 - _nz0 * _ny1;
			    var _cy = _nz0 * _nx1 - _nx0 * _nz1;
			    var _cz = _nx0 * _ny1 - _ny0 * _nx1;
			    
			    var len = sqrt(_cx * _cx + _cy * _cy + _cz * _cz);
			    
			    var _nx = _cx / len;
				var _ny = _cy / len;
				var _nz = _cz / len;
				
				_v0.z = _h0; _v0.nx = _nx; _v0.ny = _ny; _v0.nz = _nz;
				_v1.z = _h3; _v1.nx = _nx; _v1.ny = _ny; _v1.nz = _nz;
				_v2.z = _h1; _v2.nx = _nx; _v2.ny = _ny; _v2.nz = _nz;
																								
				_v3.z = _h0; _v3.nx = _nx; _v3.ny = _ny; _v3.nz = _nz;
				_v4.z = _h2; _v4.nx = _nx; _v4.ny = _ny; _v4.nz = _nz;
				_v5.z = _h3; _v5.nx = _nx; _v5.ny = _ny; _v5.nz = _nz;
				
				vertex_position_3d(vb, _v0.x,     _v0.y,   _v0.z);
				vertex_normal(     vb, _v0.nx,    _v0.ny,  _v0.nz);
				vertex_texcoord(   vb, _v0.u,     _v0.v);
				vertex_color(      vb, _v0.color, _v0.alpha);
				
				vertex_position_3d(vb, _v1.x,     _v1.y,   _v1.z);
				vertex_normal(     vb, _v1.nx,    _v1.ny,  _v1.nz);
				vertex_texcoord(   vb, _v1.u,     _v1.v);
				vertex_color(      vb, _v1.color, _v1.alpha);
				
				vertex_position_3d(vb, _v2.x,     _v2.y,   _v2.z);
				vertex_normal(     vb, _v2.nx,    _v2.ny,  _v2.nz);
				vertex_texcoord(   vb, _v2.u,     _v2.v);
				vertex_color(      vb, _v2.color, _v2.alpha);
				
				
				vertex_position_3d(vb, _v3.x,     _v3.y,   _v3.z);
				vertex_normal(     vb, _v3.nx,    _v3.ny,  _v3.nz);
				vertex_texcoord(   vb, _v3.u,     _v3.v);
				vertex_color(      vb, _v3.color, _v3.alpha);
				
				vertex_position_3d(vb, _v4.x,     _v4.y,   _v4.z);
				vertex_normal(     vb, _v4.nx,    _v4.ny,  _v4.nz);
				vertex_texcoord(   vb, _v4.u,     _v4.v);
				vertex_color(      vb, _v4.color, _v4.alpha);
				
				vertex_position_3d(vb, _v5.x,     _v5.y,   _v5.z);
				vertex_normal(     vb, _v5.nx,    _v5.ny,  _v5.nz);
				vertex_texcoord(   vb, _v5.u,     _v5.v);
				vertex_color(      vb, _v5.color, _v5.alpha);
				
				_in += 6;
				
				n++;
				i = floor(n / sub);
				j = n % sub;
			}
		
		}
		
		
		vertex_end(VB[0]);
	}
	
	onParameterUpdate = initModel;
}