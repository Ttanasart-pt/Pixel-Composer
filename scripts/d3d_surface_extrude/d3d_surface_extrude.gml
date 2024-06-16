function __3dSurfaceExtrude(surface = noone, height = noone, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.surface = surface;
	self.height  = height;
	self.smooth  = smooth;
	
	surface_w = 1;
	surface_h = 1;
	
	height_w = 1;
	height_h = 1;
	
	normal_draw_size = 0.05;
	vertex_array = [];
	
	static initModel = function() { 
		if(!is_surface(surface)) return;
		
		var _surface = surface;
		var _height  = height;
		
		var ww = surface_get_width_safe(_surface);
		var hh = surface_get_height_safe(_surface);
		
		surface_w = ww;
		surface_h = hh;
		
		var ap   = ww / hh;
		var tw   = ap / ww;
		var th   =  1 / hh;
		var sw   = -ap / 2;
		var sh   = 0.5;
		var fw   = 1 / ww;
		var fh   = 1 / hh;
		var useH = is_surface(_height);
		var hei  = 0;
		
		#region ---- buffer prepare ----
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
				height_w = surface_get_width_safe(_height);
				height_h = surface_get_height_safe(_height);
				
				var hgtW = height_w / ww;
				var hgtH = height_h / hh;
				
				var height_buffer = buffer_create(height_w * height_h * 4, buffer_fixed, 2);
				buffer_get_surface(height_buffer, _height, 0);
				buffer_seek(height_buffer, buffer_seek_start, 0);
			
				var hei = buffer_create(height_h * height_w * 2, buffer_fixed, 2);
				buffer_to_start(hei);
			
				repeat(height_h * height_w) {
					var cc = buffer_read(height_buffer, buffer_u32);
					var _b = round(colorBrightness(cc & ~0b11111111) * 65536);
					buffer_write(hei, buffer_u16, _b);
				}
			
				buffer_delete(height_buffer);
			}
		
			var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			buffer_get_surface(surface_buffer, _surface, 0);
			buffer_seek(surface_buffer, buffer_seek_start, 0);
			
			var ap = buffer_create(hh * ww, buffer_fast, 1);
				buffer_to_start(ap);
			
			repeat(hh * ww) {
				var cc = buffer_read(surface_buffer, buffer_u32);
				var _a = (cc & (0b11111111 << 24)) >> 24;
				buffer_write(ap, buffer_u8, _a);
			}
			
			buffer_delete(surface_buffer);
			
			if(smooth) {
				surface_free(_surface);
				if(useH) surface_free(_height);
			}
		#endregion
		
		var _len = array_length(vertex_array);
		for(var i = _len; i < ww * hh * 36; i++)
			vertex_array[i] = new __vertex();
			
		var v   = array_create(ww * hh * 36);
		var ind = 0;
		
		var i = 0, j = 0, n = 0;
		
		repeat(hh * ww) {
			if(!smooth && buffer_read_at(ap, (j) * ww + (i), buffer_u8) == 0) continue;
			
			var i0 = sw + i * tw;
			var j0 = sh - j * th;
			var i1 = i0 + tw;
			var j1 = j0 - th;
			
			var tx0 = fw * i, tx1 = tx0 + fw;
			var ty0 = fh * j, ty1 = ty0 + fh;
			
			var dep = useH? buffer_read_at(hei, (round(i * hgtW) + round(j * hgtH) * height_w) * 2, buffer_u16) / 65536 * 0.5
				              : 0.5;
			
			v[ind] = vertex_array[ind].set(i1, j0, -dep, 0, 0, -1, tx1, ty0); ind++;
			v[ind] = vertex_array[ind].set(i0, j0, -dep, 0, 0, -1, tx0, ty0); ind++;
			v[ind] = vertex_array[ind].set(i1, j1, -dep, 0, 0, -1, tx1, ty1); ind++;
						    				  					  				   
			v[ind] = vertex_array[ind].set(i1, j1, -dep, 0, 0, -1, tx1, ty1); ind++;
			v[ind] = vertex_array[ind].set(i0, j0, -dep, 0, 0, -1, tx0, ty0); ind++;
			v[ind] = vertex_array[ind].set(i0, j1, -dep, 0, 0, -1, tx0, ty1); ind++;
									  	  
			v[ind] = vertex_array[ind].set(i1, j0,  dep, 0, 0, 1, tx1, ty0); ind++;
			v[ind] = vertex_array[ind].set(i1, j1,  dep, 0, 0, 1, tx1, ty1); ind++;
			v[ind] = vertex_array[ind].set(i0, j0,  dep, 0, 0, 1, tx0, ty0); ind++;
						    		  	    					 				  
			v[ind] = vertex_array[ind].set(i1, j1,  dep, 0, 0, 1, tx1, ty1); ind++;
			v[ind] = vertex_array[ind].set(i0, j1,  dep, 0, 0, 1, tx0, ty1); ind++;
			v[ind] = vertex_array[ind].set(i0, j0,  dep, 0, 0, 1, tx0, ty0); ind++;
						   
			if((useH && dep * 2 > buffer_read_at(hei, (round(i * hgtW) + max(0, round((j - 1) * hgtH)) * height_w) * 2, buffer_u16) / 65536)
				|| (j == 0 || buffer_read_at(ap, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
				
				v[ind] = vertex_array[ind].set(i0, j0,  dep, 0, 1, 0, tx1, ty0); ind++;
				v[ind] = vertex_array[ind].set(i0, j0, -dep, 0, 1, 0, tx0, ty0); ind++;
				v[ind] = vertex_array[ind].set(i1, j0,  dep, 0, 1, 0, tx1, ty1); ind++;
							    	  	  	  					  				   
				v[ind] = vertex_array[ind].set(i0, j0, -dep, 0, 1, 0, tx1, ty1); ind++;
				v[ind] = vertex_array[ind].set(i1, j0, -dep, 0, 1, 0, tx0, ty0); ind++;
				v[ind] = vertex_array[ind].set(i1, j0,  dep, 0, 1, 0, tx0, ty1); ind++;
			}
				
			if((useH && dep * 2 > buffer_read_at(hei, (round(i * hgtW) + min(round((j + 1) * hgtH), height_h - 1) * height_w) * 2, buffer_u16) / 65536)
				|| (j == hh - 1 || buffer_read_at(ap, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
				
				v[ind] = vertex_array[ind].set(i0, j1,  dep, 0, -1, 0, tx1, ty0); ind++;
				v[ind] = vertex_array[ind].set(i1, j1,  dep, 0, -1, 0, tx1, ty1); ind++;
				v[ind] = vertex_array[ind].set(i0, j1, -dep, 0, -1, 0, tx0, ty0); ind++;
							    				  					 				  
				v[ind] = vertex_array[ind].set(i0, j1, -dep, 0, -1, 0, tx1, ty1); ind++;
				v[ind] = vertex_array[ind].set(i1, j1,  dep, 0, -1, 0, tx0, ty1); ind++;
				v[ind] = vertex_array[ind].set(i1, j1, -dep, 0, -1, 0, tx0, ty0); ind++;
			}
			
			if((useH && dep * 2 > buffer_read_at(hei, (max(0, round((i - 1) * hgtW)) + round(j * hgtH) * height_w) * 2, buffer_u16) / 65536)
				|| (i == 0 || buffer_read_at(ap, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
				
				v[ind] = vertex_array[ind].set(i0, j0,  dep, -1, 0, 0, tx1, ty0); ind++;
				v[ind] = vertex_array[ind].set(i0, j1,  dep, -1, 0, 0, tx1, ty1); ind++;
				v[ind] = vertex_array[ind].set(i0, j0, -dep, -1, 0, 0, tx0, ty0); ind++;
							    				  					 				  
				v[ind] = vertex_array[ind].set(i0, j0, -dep, -1, 0, 0, tx1, ty1); ind++;
				v[ind] = vertex_array[ind].set(i0, j1,  dep, -1, 0, 0, tx0, ty1); ind++;
				v[ind] = vertex_array[ind].set(i0, j1, -dep, -1, 0, 0, tx0, ty0); ind++;
			}
			
			if((useH && dep * 2 > buffer_read_at(hei, (min(round((i + 1) * hgtW), height_w - 1 ) + round(j * hgtH) * height_w) * 2, buffer_u16) / 65536)
				|| (i == ww - 1 || buffer_read_at(ap, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
				
				v[ind] = vertex_array[ind].set(i1, j0,  dep, 1, 0, 0, tx1, ty0); ind++;
				v[ind] = vertex_array[ind].set(i1, j0, -dep, 1, 0, 0, tx0, ty0); ind++;
				v[ind] = vertex_array[ind].set(i1, j1,  dep, 1, 0, 0, tx1, ty1); ind++;
							    				  					  				   
				v[ind] = vertex_array[ind].set(i1, j0, -dep, 1, 0, 0, tx1, ty1); ind++;
				v[ind] = vertex_array[ind].set(i1, j1, -dep, 1, 0, 0, tx0, ty0); ind++;
				v[ind] = vertex_array[ind].set(i1, j1,  dep, 1, 0, 0, tx0, ty1); ind++;
			}
			
			n++;
			i = floor(n / ww);
			j = n % ww;
		}
		
		array_resize(v, ind);
		
		if(hei) buffer_delete(hei);
		buffer_delete(ap);
		
		vertex = [ v ];
		VB     = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}