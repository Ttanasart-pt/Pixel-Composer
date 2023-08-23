function __3dSurfaceExtrude(surface = noone, height = noone, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.surface = surface;
	self.height  = height;
	self.smooth  = smooth;
	
	normal_draw_size = 0.05;
	
	static getHeight = function(h, gw, gh, i, j) {
		var _i = round(i * gw);
		var _j = round(j * gh);
		
		_i = clamp(_i, 0, array_length(h) - 1);
		_j = clamp(_j, 0, array_length(h[_i]) - 1);
		
		return h[_i][_j];
	}
	
	static initModel = function() {
		if(!is_surface(surface)) return;
		
		var _surface = surface;
		var _height  = height;
		
		var ww = surface_get_width(_surface);
		var hh = surface_get_height(_surface);
		
		var tw = 1 / ww;
		var th = 1 / hh;
		var sw = -ww / 2 * tw;
		var sh =  hh / 2 * th;
		var useH = is_surface(_height);
		
		#region ---- data prepare ----
			if(smooth) {
				var ts = surface_create(ww, hh);
				surface_set_shader(ts, sh_3d_extrude_filler);
					shader_set_f("dimension", ww, hh);
					draw_surface(_surface, 0, 0);
				surface_reset_shader();
				_surface = ts;
			
				if(useH) {
					var ds = surface_create(ww, hh);
					surface_set_shader(ds, sh_3d_extrude_filler_depth);
						shader_set_f("dimension", ww, hh);
						draw_surface(_height, 0, 0);
					surface_reset_shader();
					_height = ds;
				}
			}
		
			if(useH) {
				var hgw = surface_get_width(_height);
				var hgh = surface_get_height(_height);
				var hgtW = hgw / ww;
				var hgtH = hgh / hh;
			
				var height_buffer = buffer_create(hgw * hgh * 4, buffer_fixed, 2);
				buffer_get_surface(height_buffer, _height, 0);
				buffer_seek(height_buffer, buffer_seek_start, 0);
			
				var hei = array_create(hgw, hgh);
			
				for( var j = 0; j < hgh; j++ )
				for( var i = 0; i < hgw; i++ ) {
					var cc = buffer_read(height_buffer, buffer_u32);
					var _b = colorBrightness(cc & ~0b11111111);
					hei[i][j] = _b;
				}
			
				buffer_delete(height_buffer);
			}
		
			var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			buffer_get_surface(surface_buffer, _surface, 0);
			buffer_seek(surface_buffer, buffer_seek_start, 0);
		
			var v  = ds_list_create();
			var ap = array_create(ww, hh);
		
			for( var j = 0; j < hh; j++ )
			for( var i = 0; i < ww; i++ ) {
				var cc = buffer_read(surface_buffer, buffer_u32);
				var _a = (cc & (0b11111111 << 24)) >> 24;
				ap[i][j] = _a;
			}
		
			buffer_delete(surface_buffer);
		#endregion
		
		for( var i = 0; i < ww; i++ )
		for( var j = 0; j < hh; j++ ) {
			if(!smooth && ap[i][j] == 0) continue;
			
			var j0 = sh - j * th;
			var j1 = j0 - th;
			var i0 = sw + i * tw;
			var i1 = i0 + tw;
			
			var tx0 = tw * i, tx1 = tx0 + tw;
			var ty0 = th * j, ty1 = ty0 + th;
			
			var dep = (useH? getHeight(hei, hgtW, hgtH, i, j) : 1) * 0.5;
			
			if(smooth) { #region
				var d0, d1, d2, d3;
				var d00, d10, d01, d11;
				var a, a0, a1, a2, a3;
				
				// d00 | a0 | d10
				// a1  | a  | a2
				// d01 | a3 | d11
				
				if(useH) {
					d00 = (i > 0 && j > 0)?			  getHeight(hei, hgtW, hgtH, i - 1, j - 1) * 0.5 : 0;
					d10 = (i < ww - 1 && j > 0)?	  getHeight(hei, hgtW, hgtH, i + 1, j - 1) * 0.5 : 0;
					d01 = (i > 0 && j < hh - 1)?	  getHeight(hei, hgtW, hgtH, i - 1, j + 1) * 0.5 : 0;
					d11 = (i < ww - 1 && j < hh - 1)? getHeight(hei, hgtW, hgtH, i + 1, j + 1) * 0.5 : 0;
					
					d0  = (j > 0)?		getHeight(hei, hgtW, hgtH, i, j - 1) * 0.5 : 0;
					d1  = (i > 0)?		getHeight(hei, hgtW, hgtH, i - 1, j) * 0.5 : 0;
					d2  = (i < ww - 1)?	getHeight(hei, hgtW, hgtH, i + 1, j) * 0.5 : 0;
					d3  = (j < hh - 1)?	getHeight(hei, hgtW, hgtH, i, j + 1) * 0.5 : 0;
				} else {
					d00 = (i > 0 && j > 0)?			  bool(ap[i - 1][j - 1]) * 0.5 : 0;
					d10 = (i < ww - 1 && j > 0)?	  bool(ap[i + 1][j - 1]) * 0.5 : 0;
					d01 = (i > 0 && j < hh - 1)?	  bool(ap[i - 1][j + 1]) * 0.5 : 0;
					d11 = (i < ww - 1 && j < hh - 1)? bool(ap[i + 1][j + 1]) * 0.5 : 0;
					
					d0 = (j > 0)?		bool(ap[i][j - 1]) * 0.5 : 0;
					d1 = (i > 0)?		bool(ap[i - 1][j]) * 0.5 : 0;
					d2 = (i < ww - 1)?	bool(ap[i + 1][j]) * 0.5 : 0;
					d3 = (j < hh - 1)?	bool(ap[i][j + 1]) * 0.5 : 0;
				}
				
				a  = ap[i][j];
				a0 = (j > 0)?		ap[i][j - 1] : 0;
				a1 = (i > 0)?		ap[i - 1][j] : 0;
				a2 = (i < ww - 1)?	ap[i + 1][j] : 0;
				a3 = (j < hh - 1)?	ap[i][j + 1] : 0;
				
				if(a1 && a0) d00 = (d1 + d0) / 2;
				if(a0 && a2) d10 = (d0 + d2) / 2;
				if(a2 && a3) d11 = (d2 + d3) / 2;
				if(a3 && a1) d01 = (d3 + d1) / 2;
				
				if(a) {
					ds_list_add(v, V3(j0, i1, -d10).setNormal(0, 0, -1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i1, -d11).setNormal(0, 0, -1).setUV(tx1, ty1));
					ds_list_add(v, V3(j0, i0, -d00).setNormal(0, 0, -1).setUV(tx0, ty0));
						    			  
					ds_list_add(v, V3(j1, i1, -d11).setNormal(0, 0, -1).setUV(tx1, ty1));
					ds_list_add(v, V3(j1, i0, -d01).setNormal(0, 0, -1).setUV(tx0, ty1));
					ds_list_add(v, V3(j0, i0, -d00).setNormal(0, 0, -1).setUV(tx0, ty0));
										  
					ds_list_add(v, V3(j0, i1,  d10).setNormal(0, 0, 1).setUV(tx1, ty0));
					ds_list_add(v, V3(j0, i0,  d00).setNormal(0, 0, 1).setUV(tx0, ty0));
					ds_list_add(v, V3(j1, i1,  d11).setNormal(0, 0, 1).setUV(tx1, ty1));
						    		  	  	  					 				 
					ds_list_add(v, V3(j1, i1,  d11).setNormal(0, 0, 1).setUV(tx1, ty1));
					ds_list_add(v, V3(j0, i0,  d00).setNormal(0, 0, 1).setUV(tx0, ty0));
					ds_list_add(v, V3(j1, i0,  d01).setNormal(0, 0, 1).setUV(tx0, ty1));
				} else if(!a0 && !a1 && a2 && a3) {
					//var _tx0 = tw * (i + 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d00 *= d0 * d1;
					d10 *= d1 * d2;
					d01 *= d1 * d3;
					
					ds_list_add(v, V3(j0, i1, -d10).setNormal(0, 0, -1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i1, -d11).setNormal(0, 0, -1).setUV(tx1, ty1));
					ds_list_add(v, V3(j1, i0, -d01).setNormal(0, 0, -1).setUV(tx0, ty1));
												  					  				   
					ds_list_add(v, V3(j0, i1,  d10).setNormal(0, 0,  1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i1,  d11).setNormal(0, 0,  1).setUV(tx1, ty1));
					ds_list_add(v, V3(j1, i0,  d01).setNormal(0, 0,  1).setUV(tx0, ty1));
				} else if(!a0 && a1 && !a2 && a3) {
					//var _tx0 = tw * (i - 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d00 *= d0 * d1;
					d10 *= d1 * d2;
					d11 *= d2 * d3;
					
					ds_list_add(v, V3(j1, i1, -d11).setNormal(0, 0, -1).setUV(tx1, ty1));
					ds_list_add(v, V3(j1, i0, -d01).setNormal(0, 0, -1).setUV(tx0, ty1));
					ds_list_add(v, V3(j0, i0, -d00).setNormal(0, 0, -1).setUV(tx0, ty0));
												  					  				   
					ds_list_add(v, V3(j1, i1,  d11).setNormal(0, 0,  1).setUV(tx1, ty1));
					ds_list_add(v, V3(j1, i0,  d01).setNormal(0, 0,  1).setUV(tx0, ty1));
					ds_list_add(v, V3(j0, i0,  d00).setNormal(0, 0,  1).setUV(tx0, ty0));
				} else if(a0 && a1 && !a2 && !a3) {
					//var _tx0 = tw * (i - 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d10 *= d1 * d2;
					d01 *= d1 * d3;
					d11 *= d2 * d3;
					
					ds_list_add(v, V3(j0, i0, -d00).setNormal(0, 0, -1).setUV(tx0, ty0));
					ds_list_add(v, V3(j0, i1, -d10).setNormal(0, 0, -1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i0, -d01).setNormal(0, 0, -1).setUV(tx0, ty1));
												  					  				   
					ds_list_add(v, V3(j0, i0,  d00).setNormal(0, 0,  1).setUV(tx0, ty0));
					ds_list_add(v, V3(j0, i1,  d10).setNormal(0, 0,  1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i0,  d01).setNormal(0, 0,  1).setUV(tx0, ty1));
				} else if(a0 && !a1 && a2 && !a3) {
					//var _tx0 = tw * (i + 1), _tx1 = _tx0 + tw;
					//var _ty0 = th * (j + 0), _ty1 = _ty0 + th;
					
					d00 *= d0 * d1;
					d01 *= d1 * d3;
					d11 *= d2 * d3;
					
					ds_list_add(v, V3(j0, i1, -d10).setNormal(0, 0, -1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i1, -d11).setNormal(0, 0, -1).setUV(tx1, ty1));
					ds_list_add(v, V3(j0, i0, -d00).setNormal(0, 0, -1).setUV(tx0, ty0));
												  					  				   
					ds_list_add(v, V3(j0, i1,  d10).setNormal(0, 0,  1).setUV(tx1, ty0));
					ds_list_add(v, V3(j1, i1,  d11).setNormal(0, 0,  1).setUV(tx1, ty1));
					ds_list_add(v, V3(j0, i0,  d00).setNormal(0, 0,  1).setUV(tx0, ty0));
				} 
			#endregion
			} else { #region
				ds_list_add(v, V3(i1, j0, -dep).setNormal(0, 0, -1).setUV(tx1, ty0));
				ds_list_add(v, V3(i0, j0, -dep).setNormal(0, 0, -1).setUV(tx0, ty0));
				ds_list_add(v, V3(i1, j1, -dep).setNormal(0, 0, -1).setUV(tx1, ty1));
						    				  					  				   
				ds_list_add(v, V3(i1, j1, -dep).setNormal(0, 0, -1).setUV(tx1, ty1));
				ds_list_add(v, V3(i0, j0, -dep).setNormal(0, 0, -1).setUV(tx0, ty0));
				ds_list_add(v, V3(i0, j1, -dep).setNormal(0, 0, -1).setUV(tx0, ty1));
									  	  
				ds_list_add(v, V3(i1, j0,  dep).setNormal(0, 0, 1).setUV(tx1, ty0));
				ds_list_add(v, V3(i1, j1,  dep).setNormal(0, 0, 1).setUV(tx1, ty1));
				ds_list_add(v, V3(i0, j0,  dep).setNormal(0, 0, 1).setUV(tx0, ty0));
						    		  	    					 				  
				ds_list_add(v, V3(i1, j1,  dep).setNormal(0, 0, 1).setUV(tx1, ty1));
				ds_list_add(v, V3(i0, j1,  dep).setNormal(0, 0, 1).setUV(tx0, ty1));
				ds_list_add(v, V3(i0, j0,  dep).setNormal(0, 0, 1).setUV(tx0, ty0));
						   
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j - 1)) || (j == 0 || ap[i][j - 1] == 0)) { //y side 
					ds_list_add(v, V3(i0, j0,  dep).setNormal(0, 1, 0).setUV(tx1, ty0));
					ds_list_add(v, V3(i0, j0, -dep).setNormal(0, 1, 0).setUV(tx0, ty0));
					ds_list_add(v, V3(i1, j0,  dep).setNormal(0, 1, 0).setUV(tx1, ty1));
							    	  	  	  					  				   
					ds_list_add(v, V3(i0, j0, -dep).setNormal(0, 1, 0).setUV(tx1, ty1));
					ds_list_add(v, V3(i1, j0, -dep).setNormal(0, 1, 0).setUV(tx0, ty0));
					ds_list_add(v, V3(i1, j0,  dep).setNormal(0, 1, 0).setUV(tx0, ty1));
				}
			
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j + 1)) || (j == hh - 1 || ap[i][j + 1] == 0)) { //y side 
					ds_list_add(v, V3(i0, j1,  dep).setNormal(0, -1, 0).setUV(tx1, ty0));
					ds_list_add(v, V3(i1, j1,  dep).setNormal(0, -1, 0).setUV(tx1, ty1));
					ds_list_add(v, V3(i0, j1, -dep).setNormal(0, -1, 0).setUV(tx0, ty0));
							    				  					 				  
					ds_list_add(v, V3(i0, j1, -dep).setNormal(0, -1, 0).setUV(tx1, ty1));
					ds_list_add(v, V3(i1, j1,  dep).setNormal(0, -1, 0).setUV(tx0, ty1));
					ds_list_add(v, V3(i1, j1, -dep).setNormal(0, -1, 0).setUV(tx0, ty0));
				}
			
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i - 1, j)) || (i == 0 || ap[i - 1][j] == 0)) { //x side 
					ds_list_add(v, V3(i0, j0,  dep).setNormal(-1, 0, 0).setUV(tx1, ty0));
					ds_list_add(v, V3(i0, j1,  dep).setNormal(-1, 0, 0).setUV(tx1, ty1));
					ds_list_add(v, V3(i0, j0, -dep).setNormal(-1, 0, 0).setUV(tx0, ty0));
							    				  					 				  
					ds_list_add(v, V3(i0, j0, -dep).setNormal(-1, 0, 0).setUV(tx1, ty1));
					ds_list_add(v, V3(i0, j1,  dep).setNormal(-1, 0, 0).setUV(tx0, ty1));
					ds_list_add(v, V3(i0, j1, -dep).setNormal(-1, 0, 0).setUV(tx0, ty0));
				}
			
				if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i + 1, j)) || (i == ww - 1 || ap[i + 1][j] == 0)) { //x side
					ds_list_add(v, V3(i1, j0,  dep).setNormal(1, 0, 0).setUV(tx1, ty0));
					ds_list_add(v, V3(i1, j0, -dep).setNormal(1, 0, 0).setUV(tx0, ty0));
					ds_list_add(v, V3(i1, j1,  dep).setNormal(1, 0, 0).setUV(tx1, ty1));
							    				  					  				   
					ds_list_add(v, V3(i1, j0, -dep).setNormal(1, 0, 0).setUV(tx1, ty1));
					ds_list_add(v, V3(i1, j1, -dep).setNormal(1, 0, 0).setUV(tx0, ty0));
					ds_list_add(v, V3(i1, j1,  dep).setNormal(1, 0, 0).setUV(tx0, ty1));
				}
			#endregion
			}
		}
		
		if(smooth) {
			surface_free(_surface);
			if(useH) surface_free(_height);
		}
		
		vertex = [ ds_list_to_array(v) ];
		ds_list_destroy(v);
		
		VB = build();
		generateNormal();
	} initModel();
	
	static onParameterUpdate = initModel;
}