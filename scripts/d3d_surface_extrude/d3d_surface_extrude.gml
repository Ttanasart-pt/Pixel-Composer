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
	
	voxel_use   = false;
	voxel_scale = .1;
	
	normal_draw_size = 0.05;
	vertex_array     = [];
	
	flevel_min = 0; flevel_max = 1;
	blevel_min = 0; blevel_max = 1;
	
	static initModel = function() { 
		if(!is_surface(surface)) return;
		
		edges   = [];
		var eid = 0;
	    
		var ww      = surface_get_width_safe(surface);
		var hh      = surface_get_height_safe(surface);
		var useH    = is_surface(height);
		
		var h_buff  = noone;
		var c_buff  = noone;
		var hb_buff = noone;
		var cb_buff = noone;
		
		#region Buffer
			var _fsurface = surface_create(ww, hh, surface_r8unorm);
			surface_set_shader(_fsurface, sh_d3d_surface_ex_alpha);
				draw_surface_stretched(surface, 0, 0, ww, hh);
			surface_reset_shader();
			
			c_buff = buffer_create(hh * ww, buffer_fast, 1);
			buffer_get_surface(c_buff, _fsurface, 0);
			surface_free(_fsurface);
			
			if(useH) {
				var _fheight = surface_create(ww, hh, surface_r16float);
				surface_set_shader(_fheight, sh_d3d_surface_ex_height);
					shader_set_2("level", [flevel_min, flevel_max]);
					draw_surface_stretched(height, 0, 0, ww, hh);
				surface_reset_shader();
				
				h_buff = buffer_create(hh * ww * 2, buffer_fixed, 1);
				buffer_get_surface(h_buff, _fheight, 0);
				surface_free(_fheight);
			}
			
			if(back) {
				var _bsurface = surface_create(ww, hh);
				surface_set_target(_bsurface);
					DRAW_CLEAR
					draw_surface_stretched(is_surface(bsurface)? bsurface : surface, 0, 0, ww, hh);
				surface_reset_target();
				surface_free(_bsurface);
				
				if(useH) {
					var _bheight = surface_create(ww, hh, surface_r16float);
					surface_set_shader(_bheight, sh_d3d_surface_ex_height);
						shader_set_2("level", [blevel_min, blevel_max]);
						draw_surface_stretched(is_surface(bheight)? bheight : height, 0, 0, ww, hh);
					surface_reset_shader();
				
					hb_buff = buffer_create(hh * ww * 2, buffer_fixed, 1);
					buffer_get_surface(hb_buff, _bheight, 0);
					surface_free(_bheight);
				}
				
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
		var i = 0, j = 0, n = -1;
		
		array_foreach(VB, function(v,i) /*=>*/ { if(v != noone) vertex_delete_buffer(v); return true; });
		
		var _bF = buffer_create(0, buffer_grow, 1); 
		var _bB = buffer_create(0, buffer_grow, 1); 
		var _bS = buffer_create(0, buffer_grow, 1); 
		
		var sx = 1, sy = 1, sz = 1;
		if(voxel_use) {
			sx = voxel_scale * ww;
			sy = voxel_scale * hh;
			sz = voxel_scale;
		}
		
		buffer_to_start(c_buff);
		
		var pxAmo = hh * ww;
		repeat(pxAmo) {
			n++;
			i = n % ww;
			j = floor(n / ww);
			
			var _solid = buffer_peek(c_buff, n, buffer_u8);
			if(_solid == 0) continue;
			
			var i0 = sw + i * tw;
			var j0 = sh - j * th;
			var i1 = i0 + tw;
			var j1 = j0 - th;
			
			var tx0 =   i * fw;
			var tx1 = tx0 + fw;
			
			var ty0 =   j * fh;
			var ty1 = ty0 + fh;
			
			var dep  = useH?         buffer_peek(h_buff,  ((j * ww) + i) * 2, buffer_f16) * .5 : 0.5;
			var depb = useH && back? buffer_peek(hb_buff, ((j * ww) + i) * 2, buffer_f16) * .5 : dep;
			depb = -depb;
			
			i0  *= sx; i1   *= sx;
			j0  *= sy; j1   *= sy;
			dep *= sz; depb *= sz;
			
			var k0 = depb;
			var k1 = dep;
			
			// -Z
			__vertex_buffer_add_pntc(_bB, i1, j0, k0, 0, 0, -1, tx1, ty0,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bB, i0, j0, k0, 0, 0, -1, tx0, ty0,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bB, i1, j1, k0, 0, 0, -1, tx1, ty1,,, 0, 0, 255);
			
			__vertex_buffer_add_pntc(_bB, i1, j1, k0, 0, 0, -1, tx1, ty1,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bB, i0, j0, k0, 0, 0, -1, tx0, ty0,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bB, i0, j1, k0, 0, 0, -1, tx0, ty1,,, 0, 0, 255);
			
			// +Z				  	  
			__vertex_buffer_add_pntc(_bF, i1, j0, k1, 0, 0,  1, tx1, ty0,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bF, i1, j1, k1, 0, 0,  1, tx1, ty1,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bF, i0, j0, k1, 0, 0,  1, tx0, ty0,,, 0, 0, 255);
			
			__vertex_buffer_add_pntc(_bF, i1, j1, k1, 0, 0,  1, tx1, ty1,,, 255, 0, 0);
			__vertex_buffer_add_pntc(_bF, i0, j1, k1, 0, 0,  1, tx0, ty1,,, 0, 255, 0);
			__vertex_buffer_add_pntc(_bF, i0, j0, k1, 0, 0,  1, tx0, ty0,,, 0, 0, 255);
			
			edges[eid++] = new __3dObject_Edge([i0, j0, k0], [i0, j1, k0]);
			edges[eid++] = new __3dObject_Edge([i0, j1, k0], [i1, j1, k0]);
			edges[eid++] = new __3dObject_Edge([i1, j1, k0], [i1, j0, k0]);
			edges[eid++] = new __3dObject_Edge([i1, j0, k0], [i0, j0, k0]);
			
			edges[eid++] = new __3dObject_Edge([i0, j0, k1], [i0, j1, k1]);
			edges[eid++] = new __3dObject_Edge([i0, j1, k1], [i1, j1, k1]);
			edges[eid++] = new __3dObject_Edge([i1, j1, k1], [i1, j0, k1]);
			edges[eid++] = new __3dObject_Edge([i1, j0, k1], [i0, j0, k1]);
			
			edges[eid++] = new __3dObject_Edge([i0, j0, k0], [i0, j0, k1]);
			edges[eid++] = new __3dObject_Edge([i0, j1, k0], [i0, j1, k1]);
			edges[eid++] = new __3dObject_Edge([i1, j0, k0], [i1, j0, k1]);
			edges[eid++] = new __3dObject_Edge([i1, j1, k0], [i1, j1, k1]);
			
			if(voxel_use) {
				// -X
				__vertex_buffer_add_pntc(_bS, i0, j0, k1, -1, 0, 0, tx1, ty0,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bS, i0, j1, k1, -1, 0, 0, tx1, ty1,,, 0, 0, 255);
				__vertex_buffer_add_pntc(_bS, i0, j0, k0, -1, 0, 0, tx0, ty0,,, 0, 255, 0);
				
				__vertex_buffer_add_pntc(_bS, i0, j0, k0, -1, 0, 0, tx0, ty0,,, 0, 255, 0);
				__vertex_buffer_add_pntc(_bS, i0, j1, k1, -1, 0, 0, tx1, ty1,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bS, i0, j1, k0, -1, 0, 0, tx0, ty1,,, 0, 0, 255);
				
				// +X
				__vertex_buffer_add_pntc(_bF, i1, j0, k1,  1, 0, 0, tx1, ty0,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bF, i1, j0, k0,  1, 0, 0, tx0, ty0,,, 0, 0, 255);
				__vertex_buffer_add_pntc(_bF, i1, j1, k1,  1, 0, 0, tx1, ty1,,, 0, 255, 0);
				
				__vertex_buffer_add_pntc(_bF, i1, j1, k0,  1, 0, 0, tx0, ty1,,, 0, 255, 0);
				__vertex_buffer_add_pntc(_bF, i1, j1, k1,  1, 0, 0, tx1, ty1,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bF, i1, j0, k0,  1, 0, 0, tx0, ty0,,, 0, 0, 255);
				
				// -Y
				__vertex_buffer_add_pntc(_bS, i0, j0, k1, 0, -1, 0, tx1, ty0,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bS, i0, j0, k0, 0, -1, 0, tx0, ty0,,, 0, 255, 0);
				__vertex_buffer_add_pntc(_bS, i1, j0, k1, 0, -1, 0, tx1, ty1,,, 0, 0, 255);
				
				__vertex_buffer_add_pntc(_bS, i1, j0, k1, 0, -1, 0, tx1, ty1,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bS, i0, j0, k0, 0, -1, 0, tx0, ty0,,, 0, 255, 0);
				__vertex_buffer_add_pntc(_bS, i1, j0, k0, 0, -1, 0, tx0, ty1,,, 0, 0, 255);
				
				// +Y
				__vertex_buffer_add_pntc(_bF, i0, j1, k1, 0,  1, 0, tx1, ty0,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bF, i1, j1, k1, 0,  1, 0, tx1, ty1,,, 0, 255, 0);
				__vertex_buffer_add_pntc(_bF, i0, j1, k0, 0,  1, 0, tx0, ty0,,, 0, 0, 255);
				
				__vertex_buffer_add_pntc(_bF, i1, j1, k1, 0,  1, 0, tx1, ty1,,, 255, 0, 0);
				__vertex_buffer_add_pntc(_bF, i1, j1, k0, 0,  1, 0, tx0, ty1,,, 0, 255, 0);
				__vertex_buffer_add_pntc(_bF, i0, j1, k0, 0,  1, 0, tx0, ty0,,, 0, 0, 255);
				continue;
			}
			
			// Old "Accurate" height
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
				if((useH && dep * 2 > buffer_peek(h_buff, (i + max(0, j - 1) * ww) * 2, buffer_f16))
					|| (j == 0 || buffer_peek(c_buff, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, 0, 1, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
								    	  	  	  					  				   
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, 0, 1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 0, 1, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
				}
				
				if((useH && abs(depb) * 2 > buffer_peek(hb_buff, (i + max(0, j - 1) * ww) * 2, buffer_f16))
					|| (j == 0 || buffer_peek(c_buff, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, 0, 1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 0, 1, 0, tx1, ty0,,, 0, 0, 255);
					
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 0, 1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 0, 1, 0, tx1, ty0,,, 0, 0, 255);
				}
					
				if((useH && dep * 2 > buffer_peek(h_buff, (i + min(j + 1, hh - 1) * ww) * 2, buffer_f16))
					|| (j == hh - 1 || buffer_peek(c_buff, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, 0, -1, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, 0, -1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 0, -1, 0, tx1, ty0,,, 0, 0, 255);
				}
					
				if((useH && abs(depb) * 2 > buffer_peek(hb_buff, (i + min(j + 1, hh - 1) * ww) * 2, buffer_f16))
					|| (j == hh - 1 || buffer_peek(c_buff, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
					
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, 0, -1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 0, -1, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty1,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 0, -1, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 0, -1, 0, tx1, ty1,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_peek(h_buff, (max(0, i - 1) + j * ww) * 2, buffer_f16))
					|| (i == 0 || buffer_peek(c_buff, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, -1, 0, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, -1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, -1, 0, 0, tx1, ty0,,, 0, 0, 255);
				}
				
				if((useH && abs(depb) * 2 > buffer_peek(hb_buff, (max(0, i - 1) + j * ww) * 2, buffer_f16))
					|| (i == 0 || buffer_peek(c_buff, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
					
					__vertex_buffer_add_pntc(_bS, i0, j0,    0, -1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, -1, 0, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty1,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,    0, -1, 0, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, -1, 0, 0, tx1, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_peek(h_buff, (min(i + 1, ww - 1 ) + j * ww) * 2, buffer_f16))
					|| (i == ww - 1 || buffer_peek(c_buff, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
					
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 1, 0, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 1, 0, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 1, 0, 0, tx1, ty1,,, 0, 0, 255);
								    				  					  				   
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 1, 0, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 1, 0, 0, tx1, ty1,,, 0, 0, 255);
				}
					
				if((useH && abs(depb) * 2 > buffer_peek(hb_buff, (min(i + 1, ww - 1 ) + j * ww) * 2, buffer_f16))
					|| (i == ww - 1 || buffer_peek(c_buff, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
					
					__vertex_buffer_add_pntc(_bS, i1, j0,    0, 1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 1, 0, 0, tx0, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 1, 0, 0, tx1, ty0,,, 0, 0, 255);
								    				  					  				   
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 1, 0, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,    0, 1, 0, 0, tx1, ty0,,, 0, 0, 255);
				}
				
			} else {
				
				if((useH && dep * 2 > buffer_peek(h_buff, (i + max(0, j - 1) * ww) * 2, buffer_f16))
					|| (j == 0 || buffer_peek(c_buff, (j - 1) * ww + (i), buffer_u8) == 0)) { //y side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, 0, 1, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
								    	  	  	  					  								
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, 0, 1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0, depb, 0, 1, 0, tx1, ty0,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 0, 1, 0, tx1, ty1,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_peek(h_buff, (i + min(j + 1, hh - 1) * ww) * 2, buffer_f16))
					|| (j == hh - 1 || buffer_peek(c_buff, (j + 1) * ww + (i), buffer_u8) == 0)) { //y side 
					
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, 0, -1, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty0,,, 0, 0, 255);
					
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, 0, -1, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1,  dep, 0, -1, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i1, j1, depb, 0, -1, 0, tx1, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_peek(h_buff, (max(0, i - 1) + j * ww) * 2, buffer_f16))
					|| (i == 0 || buffer_peek(c_buff, (j) * ww + (i - 1), buffer_u8) == 0)) { //x side 
						
					__vertex_buffer_add_pntc(_bS, i0, j0,  dep, -1, 0, 0, tx0, ty1,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty0,,, 0, 0, 255);
								    				  					 				  
					__vertex_buffer_add_pntc(_bS, i0, j0, depb, -1, 0, 0, tx0, ty0,,, 255, 0, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1,  dep, -1, 0, 0, tx1, ty1,,, 0, 255, 0);
					__vertex_buffer_add_pntc(_bS, i0, j1, depb, -1, 0, 0, tx1, ty0,,, 0, 0, 255);
				}
				
				if((useH && dep * 2 > buffer_peek(h_buff, (min(i + 1, ww - 1) + j * ww) * 2, buffer_f16))
					|| (i == ww - 1 || buffer_peek(c_buff, (j) * ww + (i + 1), buffer_u8) == 0)) { //x side
					
					__vertex_buffer_add_pntc(_bS, i1, j0,  dep, 1, 0, 0, tx0, ty1,,, 255, 0, 0);
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
		
		edges = [ edges ];
		buildEdge();
		
	} initModel();
	
	static onParameterUpdate = initModel;
}