function __3dSurfaceExtrude(_surface = noone, _height = noone, _smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type   = pr_trianglelist;
	object_counts = 3;
	
	surface  = _surface;
	height   = _height;
	smooth   = _smooth;
	
	back     = false;
	bsurface = noone;
	bheight  = noone;
	
	normal_draw_size = 0.05;
	vertex_array     = [];
	
	flevel_min = 0; flevel_max = 1;
	blevel_min = 0; blevel_max = 1;
	
	static initModel = function() { 
		if(!is_surface(surface)) return;
		
		var _surface  = surface;
		var _height   = height;
		var _bsurface = noone;
		var _bheight  = noone;
		
		var ww    = surface_get_width_safe(_surface);
		var hh    = surface_get_height_safe(_surface);
		var hg_ww = surface_get_width_safe(_height);
		var hg_hh = surface_get_height_safe(_height);
		
		var useH    = is_surface(_height);
		var h_buff  = noone;
		var c_buff  = noone;
		var hb_buff = noone;
		var cb_buff = noone;
		
		var flevel_rg = flevel_max - flevel_min;
		var blevel_rg = blevel_max - blevel_min;
		
		#region /////////////// Buffer
		
			if(useH) {
				var hgtW = hg_ww / ww;
				var hgtH = hg_hh / hh;
				
				var height_buffer = buffer_create(hg_ww * hg_hh * 4, buffer_fixed, 2);
				buffer_get_surface(height_buffer, _height, 0);
				buffer_seek(height_buffer, buffer_seek_start, 0);
			
				h_buff = buffer_create(hg_hh * hg_ww * 2, buffer_fixed, 2);
				buffer_to_start(h_buff);
			
				repeat(hg_hh * hg_ww) {
					var cc = buffer_read(height_buffer, buffer_u32);
					var _b = colorBrightness(cc & ~0b11111111);
					    _b = flevel_min + flevel_rg * _b;
					    
					buffer_write(h_buff, buffer_u16, round(_b * 65536));
				}
			
				buffer_delete(height_buffer);
			}
		
			var surface_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			buffer_get_surface(surface_buffer, _surface, 0);
			buffer_seek(surface_buffer, buffer_seek_start, 0);
			
			c_buff = buffer_create(hh * ww, buffer_fast, 1);
			buffer_to_start(c_buff);
			
			repeat(hh * ww) {
				var cc = buffer_read(surface_buffer, buffer_u32);
				var _a = (cc & (0xFF << 24)) >> 24;
				buffer_write(c_buff, buffer_u8, _a);
			}
			
			buffer_delete(surface_buffer);
			
			if(back) {
				_bsurface = surface_create(ww, hh);
				_bheight  = surface_create(hg_ww, hg_hh);
				
				BLEND_OVERRIDE
					surface_set_target(_bsurface);
						DRAW_CLEAR
						draw_surface_stretched(is_surface(bsurface)? bsurface : surface, 0, 0, ww, hh);
					surface_reset_target();
					
					if(useH) {
						surface_set_target(_bheight);
							DRAW_CLEAR
							draw_surface_stretched(is_surface(bheight)? bheight : _height, 0, 0, hg_ww, hg_hh);
						surface_reset_target();
					}
				BLEND_NORMAL
				
				/////////////////////////////////////////////////////////////////////////////////////////////////
				
				if(useH) {
					var height_buffer = buffer_create(hg_ww * hg_hh * 4, buffer_fixed, 2);
					buffer_get_surface(height_buffer, _bheight, 0);
					buffer_seek(height_buffer, buffer_seek_start, 0);
				
					hb_buff = buffer_create(hg_hh * hg_ww * 2, buffer_fixed, 2);
					buffer_to_start(hb_buff);
					
					repeat(hg_hh * hg_ww) {
						var cc = buffer_read(height_buffer, buffer_u32);
						var _b = colorBrightness(cc & ~0b11111111);
						    _b = blevel_min + blevel_rg * _b;
						    
						buffer_write(hb_buff, buffer_u16, round(_b * 65536));
					}
				
					buffer_delete(height_buffer);
				}
				
				/////////////////////////////////////////////////////////////////////////////////////////////////
				
				surface_free(_bsurface);
				surface_free(_bheight);
			}
		
		#endregion
		
		var asp = ww / hh;
		var tw  = asp / ww;
		var th  =  1 / hh;
		var sw  = -asp / 2;
		var sh  = 0.5;
		var fw  = 1 / ww;
		var fh  = 1 / hh;
		
		var ind = 0;
		var i = 0, j = 0, n = 0;
		
		array_foreach(VB, function(v) /*=>*/ { if(v != noone) vertex_delete_buffer(v); });
		
		var _bF = buffer_create(0, buffer_grow, 1); 
		var _bB = buffer_create(0, buffer_grow, 1); 
		var _bS = buffer_create(0, buffer_grow, 1); 
		
		repeat(hh * ww) {
			i = floor(n / ww);
			j = n % ww;
			n++;
			
			if(buffer_read_at(c_buff, j * ww + i, buffer_u8) == 0) continue;
			
			var i0 = sw + i * tw;
			var j0 = sh - j * th;
			var i1 = i0 + tw;
			var j1 = j0 - th;
			
			var tx0 =   i * fw;
			var tx1 = tx0 + fw;
			
			var ty0 =   j * fh;
			var ty1 = ty0 + fh;
			
			var dep  = useH?         buffer_read_at(h_buff,  (round(i * hgtW) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536 * 0.5 : 0.5;
			var depb = useH && back? buffer_read_at(hb_buff, (round(i * hgtW) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536 * 0.5 : dep;
			depb = -depb;
			
			__vertex_buffer_add_pntc(_bB, i1, j0, depb, 0, 0, -1, tx1, ty0,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bB, i0, j0, depb, 0, 0, -1, tx0, ty0,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bB, i1, j1, depb, 0, 0, -1, tx1, ty1,,, 0, 0, 255);
						    				  					  				   
			__vertex_buffer_add_pntc(_bB, i1, j1, depb, 0, 0, -1, tx1, ty1,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bB, i0, j0, depb, 0, 0, -1, tx0, ty0,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bB, i0, j1, depb, 0, 0, -1, tx0, ty1,,, 0, 0, 255);
									  	  
			__vertex_buffer_add_pntc(_bF, i1, j0,  dep, 0, 0, 1, tx1, ty0,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bF, i1, j1,  dep, 0, 0, 1, tx1, ty1,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bF, i0, j0,  dep, 0, 0, 1, tx0, ty0,,, 0, 0, 255);
						    		  	    					 				  
			__vertex_buffer_add_pntc(_bF, i1, j1,  dep, 0, 0, 1, tx1, ty1,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bF, i0, j1,  dep, 0, 0, 1, tx0, ty1,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bF, i0, j0,  dep, 0, 0, 1, tx0, ty0,,, 0, 0, 255);
				
			if(back) {
				
				if((useH && dep * 2 > buffer_read_at(h_buff, (round(i * hgtW) + max(0, round((j - 1) * hgtH)) * hg_ww) * 2, buffer_u16) / 65536)
					|| (j == 0 || buffer_read_at(c_buff, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, 0, 1, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
								    	  	  	  					  				   
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, 0, 1, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx0, ty1,,, 0, 0, 255);
				}
				
				if((useH && abs(depb) * 2 > buffer_read_at(hb_buff, (round(i * hgtW) + max(0, round((j - 1) * hgtH)) * hg_ww) * 2, buffer_u16) / 65536)
					|| (j == 0 || buffer_read_at(c_buff, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, 0, 1, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
					
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 0, 1, 0, tx0, ty1,,, 0, 0, 255);
				}
					
				if((useH && dep * 2 > buffer_read_at(h_buff, (round(i * hgtW) + min(round((j + 1) * hgtH), hg_hh - 1) * hg_ww) * 2, buffer_u16) / 65536)
					|| (j == hh - 1 || buffer_read_at(c_buff, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, 0, -1, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, 0, -1, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx0, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
				}
					
				if((useH && abs(depb) * 2 > buffer_read_at(hb_buff, (round(i * hgtW) + min(round((j + 1) * hgtH), hg_hh - 1) * hg_ww) * 2, buffer_u16) / 65536)
					|| (j == hh - 1 || buffer_read_at(c_buff, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
					
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, 0, -1, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 0, -1, 0, tx0, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_read_at(h_buff, (max(0, round((i - 1) * hgtW)) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536)
					|| (i == 0 || buffer_read_at(c_buff, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, -1, 0, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, -1, 0, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx0, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
				}
				
				if((useH && abs(depb) * 2 > buffer_read_at(hb_buff, (max(0, round((i - 1) * hgtW)) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536)
					|| (i == 0 || buffer_read_at(c_buff, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
					
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, -1, 0, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, -1, 0, 0, tx0, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_read_at(h_buff, (min(round((i + 1) * hgtW), hg_ww - 1 ) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536)
					|| (i == ww - 1 || buffer_read_at(c_buff, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
					
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 1, 0, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 1, 0, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 1, 0, 0, tx1, ty1,,, 0, 0, 255);
								    				  					  				   
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 1, 0, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 1, 0, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 1, 0, 0, tx0, ty1,,, 0, 0, 255);
				}
					
				if((useH && abs(depb) * 2 > buffer_read_at(hb_buff, (min(round((i + 1) * hgtW), hg_ww - 1 ) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536)
					|| (i == ww - 1 || buffer_read_at(c_buff, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
					
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 1, 0, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 1, 0, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 1, 0, 0, tx1, ty1,,, 0, 0, 255);
								    				  					  				   
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 1, 0, 0, tx1, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 1, 0, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 1, 0, 0, tx0, ty1,,, 0, 0, 255);
				}
				
			} else {
				
				if((useH && dep * 2 > buffer_read_at(h_buff, (round(i * hgtW) + max(0, round((j - 1) * hgtH)) * hg_ww) * 2, buffer_u16) / 65536)
					|| (j == 0 || buffer_read_at(c_buff, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, 0, 1, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
								    	  	  	  					  								
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 0, 1, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
				}
					
				if((useH && dep * 2 > buffer_read_at(h_buff, (round(i * hgtW) + min(round((j + 1) * hgtH), hg_hh - 1) * hg_ww) * 2, buffer_u16) / 65536)
					|| (j == hh - 1 || buffer_read_at(c_buff, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
					
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, 0, -1, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 0, -1, 0, tx1, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_read_at(h_buff, (max(0, round((i - 1) * hgtW)) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536)
					|| (i == 0 || buffer_read_at(c_buff, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, -1, 0, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, -1, 0, 0, tx1, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_read_at(h_buff, (min(round((i + 1) * hgtW), hg_ww - 1 ) + round(j * hgtH) * hg_ww) * 2, buffer_u16) / 65536)
					|| (i == ww - 1 || buffer_read_at(c_buff, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
					
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 1, 0, 0, tx1, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 1, 0, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 1, 0, 0, tx1, ty1,,, 0, 0, 255);
								    				  					  							
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 1, 0, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 1, 0, 0, tx1, ty1,,, 0, 0, 255);
				}
			}
			
		}
		
		var _vbF = buffer_exists(_bF)? vertex_create_buffer_from_buffer(_bF, VF) : noone;
		var _vbB = buffer_exists(_bB)? vertex_create_buffer_from_buffer(_bB, VF) : noone;
		var _vbS = buffer_exists(_bS)? vertex_create_buffer_from_buffer(_bS, VF) : noone;
		
		VB = [ _vbF, _vbB, _vbS ];
		
		buffer_delete_safe(h_buff);
		buffer_delete_safe(c_buff);
		buffer_delete_safe(hb_buff);
		buffer_delete_safe(cb_buff);
		
		buffer_delete_safe(_bF);
		buffer_delete_safe(_bB);
		buffer_delete_safe(_bS);
		
	} initModel();
	
	static onParameterUpdate = initModel;
}