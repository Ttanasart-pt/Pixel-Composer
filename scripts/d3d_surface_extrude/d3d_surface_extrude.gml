function __3dSurfaceExtrude(surface = noone, height = noone, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.surface = surface;
	self.height  = height;
	self.smooth  = smooth;
	
	surface_w = 1;
	surface_h = 1;
	
	normal_draw_size = 0.05;
	
	static getHeight = function(h, gw, gh, i, j) {
		gml_pragma("forceinline");
		
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
		
		var ww = surface_get_width_safe(_surface);
		var hh = surface_get_height_safe(_surface);
		
		surface_w = ww;
		surface_h = hh;
		
		var ap = ww / hh;
		var tw = ap / ww;
		var th =  1 / hh;
		var sw = -ap / 2;
		var sh = 0.5;
		var useH = is_surface(_height);
		var fw = 1 / ww;
		var fh = 1 / hh;
		
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
				var hgw = surface_get_width_safe(_height);
				var hgh = surface_get_height_safe(_height);
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
			
			var i0 = sw + i * tw;
			var j0 = sh - j * th;
			var i1 = i0 + tw;
			var j1 = j0 - th;
			
			var tx0 = fw * i, tx1 = tx0 + fw;
			var ty0 = fh * j, ty1 = ty0 + fh;
			
			var dep = (useH? getHeight(hei, hgtW, hgtH, i, j) : 1) * 0.5;
			
			ds_list_add(v, new __vertex(i1, j0, -dep).setNormal(0, 0, -1).setUV(tx1, ty0));
			ds_list_add(v, new __vertex(i0, j0, -dep).setNormal(0, 0, -1).setUV(tx0, ty0));
			ds_list_add(v, new __vertex(i1, j1, -dep).setNormal(0, 0, -1).setUV(tx1, ty1));
						    				  					  				   
			ds_list_add(v, new __vertex(i1, j1, -dep).setNormal(0, 0, -1).setUV(tx1, ty1));
			ds_list_add(v, new __vertex(i0, j0, -dep).setNormal(0, 0, -1).setUV(tx0, ty0));
			ds_list_add(v, new __vertex(i0, j1, -dep).setNormal(0, 0, -1).setUV(tx0, ty1));
									  	  
			ds_list_add(v, new __vertex(i1, j0,  dep).setNormal(0, 0, 1).setUV(tx1, ty0));
			ds_list_add(v, new __vertex(i1, j1,  dep).setNormal(0, 0, 1).setUV(tx1, ty1));
			ds_list_add(v, new __vertex(i0, j0,  dep).setNormal(0, 0, 1).setUV(tx0, ty0));
						    		  	    					 				  
			ds_list_add(v, new __vertex(i1, j1,  dep).setNormal(0, 0, 1).setUV(tx1, ty1));
			ds_list_add(v, new __vertex(i0, j1,  dep).setNormal(0, 0, 1).setUV(tx0, ty1));
			ds_list_add(v, new __vertex(i0, j0,  dep).setNormal(0, 0, 1).setUV(tx0, ty0));
						   
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j - 1)) || (j == 0 || ap[i][j - 1] == 0)) { //y side 
				ds_list_add(v, new __vertex(i0, j0,  dep).setNormal(0, 1, 0).setUV(tx1, ty0));
				ds_list_add(v, new __vertex(i0, j0, -dep).setNormal(0, 1, 0).setUV(tx0, ty0));
				ds_list_add(v, new __vertex(i1, j0,  dep).setNormal(0, 1, 0).setUV(tx1, ty1));
							    	  	  	  					  				   
				ds_list_add(v, new __vertex(i0, j0, -dep).setNormal(0, 1, 0).setUV(tx1, ty1));
				ds_list_add(v, new __vertex(i1, j0, -dep).setNormal(0, 1, 0).setUV(tx0, ty0));
				ds_list_add(v, new __vertex(i1, j0,  dep).setNormal(0, 1, 0).setUV(tx0, ty1));
			}
				
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i, j + 1)) || (j == hh - 1 || ap[i][j + 1] == 0)) { //y side 
				ds_list_add(v, new __vertex(i0, j1,  dep).setNormal(0, -1, 0).setUV(tx1, ty0));
				ds_list_add(v, new __vertex(i1, j1,  dep).setNormal(0, -1, 0).setUV(tx1, ty1));
				ds_list_add(v, new __vertex(i0, j1, -dep).setNormal(0, -1, 0).setUV(tx0, ty0));
							    				  					 				  
				ds_list_add(v, new __vertex(i0, j1, -dep).setNormal(0, -1, 0).setUV(tx1, ty1));
				ds_list_add(v, new __vertex(i1, j1,  dep).setNormal(0, -1, 0).setUV(tx0, ty1));
				ds_list_add(v, new __vertex(i1, j1, -dep).setNormal(0, -1, 0).setUV(tx0, ty0));
			}
			
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i - 1, j)) || (i == 0 || ap[i - 1][j] == 0)) { //x side 
				ds_list_add(v, new __vertex(i0, j0,  dep).setNormal(-1, 0, 0).setUV(tx1, ty0));
				ds_list_add(v, new __vertex(i0, j1,  dep).setNormal(-1, 0, 0).setUV(tx1, ty1));
				ds_list_add(v, new __vertex(i0, j0, -dep).setNormal(-1, 0, 0).setUV(tx0, ty0));
							    				  					 				  
				ds_list_add(v, new __vertex(i0, j0, -dep).setNormal(-1, 0, 0).setUV(tx1, ty1));
				ds_list_add(v, new __vertex(i0, j1,  dep).setNormal(-1, 0, 0).setUV(tx0, ty1));
				ds_list_add(v, new __vertex(i0, j1, -dep).setNormal(-1, 0, 0).setUV(tx0, ty0));
			}
			
			if((useH && dep * 2 > getHeight(hei, hgtW, hgtH, i + 1, j)) || (i == ww - 1 || ap[i + 1][j] == 0)) { //x side
				ds_list_add(v, new __vertex(i1, j0,  dep).setNormal(1, 0, 0).setUV(tx1, ty0));
				ds_list_add(v, new __vertex(i1, j0, -dep).setNormal(1, 0, 0).setUV(tx0, ty0));
				ds_list_add(v, new __vertex(i1, j1,  dep).setNormal(1, 0, 0).setUV(tx1, ty1));
							    				  					  				   
				ds_list_add(v, new __vertex(i1, j0, -dep).setNormal(1, 0, 0).setUV(tx1, ty1));
				ds_list_add(v, new __vertex(i1, j1, -dep).setNormal(1, 0, 0).setUV(tx0, ty0));
				ds_list_add(v, new __vertex(i1, j1,  dep).setNormal(1, 0, 0).setUV(tx0, ty1));
			}
		}
		
		if(smooth) {
			surface_free(_surface);
			if(useH) surface_free(_height);
		}
		
		vertex = [ ds_list_to_array(v) ];
		ds_list_destroy(v);
		
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}