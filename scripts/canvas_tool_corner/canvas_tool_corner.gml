function canvas_tool_corner() : canvas_tool_shader() constructor {
	
	mouse_sx = 0;
	mouse_sy = 0;
	
	modifying = false;
	amount    = 0;
	
	temp_surface   = [ noone, noone ];
	anchors        = [];
	anchorsRounded = [];
	
	function init() { mouse_init = true; }
	
	function onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_sx   = _mx;
		mouse_sy   = _my;
		
		anchors        = [];
		anchorsRounded = [];
	
		#region content extract
			var _sel  = node.tool_selection;
			var _surf = _sel.selection_surface;
			var _dim  = surface_get_dimension(_surf);
			
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
			
			surface_set_shader(temp_surface[0], sh_image_trace);
				shader_set_f("dimension", _dim);
				shader_set_i("diagonal",  0);
				draw_surface_safe(_surf);
			surface_reset_shader();
			
			var _w   = _dim[0], _h  = _dim[1];
			var xx   = 0,       yy  = 0;
			
			var _buff = buffer_from_surface(temp_surface[0], false);
			var _emp  = true;
			var _ind  = 0;
			
			buffer_seek(_buff, buffer_seek_start, 0);
			repeat(_w * _h) {
				var _b = buffer_read(_buff, buffer_u32);
				if(_b > 0) {
					_emp = false;
					xx   = _ind % _w;
					yy   = floor(_ind / _w);
					break;
				}
				_ind++;
			}
		#endregion
		
		var _sx  = xx, _sy  = yy;
		var _px  = xx, _py  = yy;
		var _nx  = xx, _ny  = yy;
		var _amo = _w * _h;
		var _rep = 0;
		var corner = 0;
		
		var _a   = array_create(_amo);
		var _ind = 0;
		var _daw = false;
		
		do {
			buffer_write_at(_buff, (yy * _w + xx) * 4, buffer_u32, 0);
			
			_nx = xx;
			_ny = yy;
			
			if(corner == 1 || corner == 3) _nx++;
			if(corner == 2 || corner == 3) _ny++;
			
			if(_ind == 0 || _px != _nx || _py != _ny) _a[_ind++] = [ _nx, _ny ];
			// print($"{corner} : {[ _nx, _ny ]}");
			
			_px = _nx; _py = _ny;
			
		    if(xx < _w - 1 && buffer_read_at(_buff, ((yy    ) * _w + xx + 1) * 4, buffer_u32)) { 
		     	if(corner == 2) {
					_a[_ind++] = [ xx, yy ];
					// print($"{corner} - 0 : {[ xx, yy ]}");
					_px = xx; _py = yy;
					
					corner = 0;
				}
				if(corner == 1) corner = 0;
		     	if(corner == 3) corner = 2;
		     	
				xx++;
			}
			else if(yy < _h - 1 && buffer_read_at(_buff, ((yy + 1) * _w + xx    ) * 4, buffer_u32)) { 
				if(corner == 0) {
					_a[_ind++] = [ xx + 1, yy ];
					// print($"{corner} - 1 : {[ xx + 1, yy ]}");
					_px = xx + 1; _py = yy;
			
					corner = 1;
				}
				if(corner == 2) corner = 0;
		     	if(corner == 3) corner = 1;
		     	
				yy++; 
			}
			else if(xx > 0      && buffer_read_at(_buff, ((yy    ) * _w + xx - 1) * 4, buffer_u32)) { 
				if(corner == 1) {
					_a[_ind++] = [ xx + 1, yy + 1 ];
					// print($"{corner} - 3 : {[ xx + 1, yy + 1 ]}");
					_px = xx + 1; _py = yy + 1;
			
					corner = 3;
				}
				if(corner == 0) corner = 1;
		     	if(corner == 2) corner = 3;
		     	
				xx--; 
			}
			else if(yy > 0      && buffer_read_at(_buff, ((yy - 1) * _w + xx    ) * 4, buffer_u32)) { 
				if(corner == 3) {
					_a[_ind++] = [ xx, yy + 1 ];
					// print($"{corner} - 2 : {[ xx, yy + 1 ]}");
					_px = xx; _py = yy + 1;
					
					corner = 2;
				}
				if(corner == 0) corner = 2;
		     	if(corner == 1) corner = 3;
		     	
				yy--; 
			}
			
			else if(xx < _w - 1 && yy < _h - 1 && buffer_read_at(_buff, ((yy + 1) * _w + xx + 1) * 4, buffer_u32)) { 
				if(corner == 0) { _a[_ind++] = [ xx + 1, yy ];     /*print($"{corner} ++ : {[ xx + 1, yy     ]}");*/ }
				if(corner == 1) { _a[_ind++] = [ xx + 1, yy + 1 ]; /*print($"{corner} ++ : {[ xx + 1, yy + 1 ]}");*/ }
				if(corner == 2) { _a[_ind++] = [ xx + 1, yy + 1 ]; /*print($"{corner} ++ : {[ xx + 1, yy + 1 ]}");*/ }
				if(corner == 3) { _a[_ind++] = [ xx + 1, yy + 1 ]; /*print($"{corner} ++ : {[ xx + 1, yy + 1 ]}");*/ }
				
				xx++; yy++; 
			}
			
			else if(xx < _w - 1 && yy > 0      && buffer_read_at(_buff, ((yy - 1) * _w + xx + 1) * 4, buffer_u32)) { 
				if(corner == 0) { _a[_ind++] = [ xx + 1, yy ];     /*print($"{corner} +- : {[ xx + 1, yy     ]}");*/ }
				if(corner == 1) { _a[_ind++] = [ xx + 1, yy - 1 ]; /*print($"{corner} +- : {[ xx + 1, yy - 1 ]}");*/ }
				if(corner == 2) { _a[_ind++] = [ xx, yy ];         /*print($"{corner} +- : {[ xx,     yy     ]}");*/ }
				if(corner == 3) { _a[_ind++] = [ xx + 1, yy ];     /*print($"{corner} +- : {[ xx + 1, yy     ]}");*/ }
				
				xx++; yy--; 
			}
			
			else if(xx > 0      && yy < _h - 1 && buffer_read_at(_buff, ((yy + 1) * _w + xx - 1) * 4, buffer_u32)) { 
				if(corner == 0) { _a[_ind++] = [ xx, yy + 1 ];     /*print($"{corner} -+ : {[ xx,     yy + 1 ]}");*/ }
				if(corner == 1) { _a[_ind++] = [ xx, yy ];         /*print($"{corner} -+ : {[ xx,     yy     ]}");*/ }
				if(corner == 2) { _a[_ind++] = [ xx - 1, yy + 1 ]; /*print($"{corner} -+ : {[ xx - 1, yy + 1 ]}");*/ }
				if(corner == 3) { _a[_ind++] = [ xx, yy + 1 ];     /*print($"{corner} -+ : {[ xx,     yy + 1 ]}");*/ }
				
				xx--; yy++; 
			}
			
			else if(xx > 0      && yy > 0      && buffer_read_at(_buff, ((yy - 1) * _w + xx - 1) * 4, buffer_u32)) { 
				if(corner == 0) { _a[_ind++] = [ xx, yy - 1 ]; /*print($"{corner} -- : {[ xx,     yy - 1 ]}");*/ }
				if(corner == 1) { _a[_ind++] = [ xx, yy ];     /*print($"{corner} -+ : {[ xx,     yy     ]}");*/ }
				if(corner == 2) { _a[_ind++] = [ xx, yy ];     /*print($"{corner} -+ : {[ xx,     yy     ]}");*/ }
				if(corner == 3) { _a[_ind++] = [ xx + 1, yy ]; /*print($"{corner} -- : {[ xx + 1, yy     ]}");*/ }
				
				xx--; yy--; 
			}
			
			if(++_rep >= _amo) break;
		} until(xx == _sx && yy == _sy);
		
		if(xx == _sx && yy > _sy) { //y--
			if(corner == 3) {
				_a[_ind++] = [ xx, yy + 1 ];
				_a[_ind++] = [ xx, yy ];
				// print($"{corner} - 2 : {[ xx, yy + 1 ]}");
				// print($"{corner} - 2 : {[ xx, yy ]}");
			}
			
		} else if(xx == _sx && yy < _sy) { //y++
			if(corner == 0) {
				_a[_ind++] = [ xx + 1, yy ];
				_a[_ind++] = [ xx + 1, yy + 1 ];
				// print($"{corner} - 1 : {[ xx + 1, yy ]}");
				// print($"{corner} - 1 : {[ xx + 1, yy + 1 ]}");
			}
			
		} else if(yy == _sy && xx > _sx) { //x--
			if(corner == 1) {
				_a[_ind++] = [ xx + 1, yy + 1 ];
				_a[_ind++] = [ xx, yy + 1 ];
				// print($"{corner} - 3 : {[ xx + 1, yy + 1 ]}");
				// print($"{corner} - 3 : {[ xx, yy + 1 ]}");
			}
			
		} else if(yy == _sy && xx < _sx) { //x++
			if(corner == 2) {
				_a[_ind++] = [ xx, yy ];
				_a[_ind++] = [ xx + 1, yy ];
				// print($"{corner} - 0 : {[ xx, yy ]}");
				// print($"{corner} - 0 : {[ xx + 1, yy ]}");
			}
			
		}
		
		// print(_a);
		
		buffer_delete(_buff);
		
		anchors = array_verify(anchors, _ind);
		var _aind = 0;
		var _aamo = _ind;
		if(_aamo <= 2) {
			anchors = [];
			return;
		}
		
		var sx, sy;
		var ox, oy, cx, cy;
		var dx, dy;
		var dd  = array_create(_aamo - 1);
		
		ox = _a[0][0];
		oy = _a[0][1];
		
		sx = ox;
		sy = oy;
		
		anchors[_aind++] = new __vec2( sx, sy );
		
		for( var i = 1; i < _aamo; i++ ) {
			cx = _a[i][0];
			cy = _a[i][1];
			
			dx = cx - ox;
			dy = cy - oy;
			dd[i - 1] = dx * 100 + dy;
			// anchors[_aind++] = new __vec2( _a[i][0], _a[i][1] );
			
			ox = cx;
			oy = cy;
		}
		
		// print(dd);
		var len = array_length(dd);
	    var pattern       = [dd[0]];
	    var patternLen    = 1;
	    var patternRepeat = 0;
		
	    for (var i = 1; i < len; i++) { // can be done inline, but my tiny brain won't be able to comprehnd it weeks after
	        // print($"{i}: {patternLen}");
	        
	        if (dd[i] == pattern[patternRepeat % patternLen]) {
	            
	            if ((patternRepeat % patternLen) == patternLen - 1) 
	                patternRepeat++;
	            
	        } else {
	            
	            if (patternRepeat == 0) {
	                pattern[patternLen] = dd[i];
	                patternLen++;
	                
	            } else {
	                anchors[_aind++] = new __vec2( _a[i][0], _a[i][1] );
	                
	                pattern = [dd[i]];
	                patternLen    = 1;
	                patternRepeat = -1;
	            }
	        }
	        
	        patternRepeat++;
	    }
		
		array_resize(anchors, _aind);
		
		// print(anchors);
	}
	
	function stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		modifying = true;
		var _dim = node.attributes.dimension;
		var _suf = node.getCanvasSurface();
		
		var _dx  = (_mx - mouse_sx) / _s / 4;
		amount   = max(_dx, 0);
		
		if(amount == 0) {
			surface_set_shader(preview_surface[1]);
				draw_surface_safe(preview_surface[0]);
			surface_reset_shader();
			return;
		}
		
		var a, b, c;
		var d, dr = 0;
		
		anchorsRounded = [];
		for( var i = 0, n = array_length(anchors); i < n; i++ ) {
			a = anchors[(i - 1 + n) % n];
			b = anchors[i];
			c = anchors[(i + 1 + n) % n];
			
			var _dir = sign(angle_difference(point_direction(a.x, a.y, b.x, b.y), point_direction(b.x, b.y, c.x, c.y)));
			
			if(dr == 0) {
				dr = _dir;
			} else if(dr != _dir) {
				array_push(anchorsRounded, new __vec2(b.x, b.y));
				continue;
			}
			
			dr = _dir;
			d = calculateCircleCenter(a, b, c, amount);
			
			var _ox = d.x;
			var _oy = d.y;
			var _or = d.r;
			
			var dd = sqrt(sqr(d.d) - sqr(d.r));
			var ba = point_direction(b.x, b.y, a.x, a.y);
    		var bc = point_direction(b.x, b.y, c.x, c.y);
    		
    		var e = new __vec2( b.x + lengthdir_x(dd, ba), b.y + lengthdir_y(dd, ba) );
    		var f = new __vec2( b.x + lengthdir_x(dd, bc), b.y + lengthdir_y(dd, bc) );
    		
    		var ee = point_direction(d.x, d.y, e.x, e.y);
    		var ff = point_direction(d.x, d.y, f.x, f.y);
    		
			var ast = 4;
			var ad  = angle_difference(ff, ee);
			var sgn = sign(ad);
			var ar  = abs(ad) / ast;
			
			for( var j = 0; j < ar; j++ ) {
				var a = ee + ast * j * sgn;
				
				nx = _ox + lengthdir_x(_or, a);
				ny = _oy + lengthdir_y(_or, a);
				
				array_push(anchorsRounded, new __vec2(nx, ny));
			}
		}
		
		var _dim = surface_get_dimension(preview_surface[0]);
		var mx   = mask_boundary_init[0];
		var my   = mask_boundary_init[1];
		
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[1], noone);
			if(array_length(anchorsRounded) >= 3) {
				var _pTri = polygon_triangulate(anchorsRounded);
				var triangles  = _pTri[0];
				
				draw_set_color(c_white);
				draw_primitive_begin(pr_trianglelist);
				for( var i = 0, n = array_length(triangles); i < n; i++ ) {
					var tri = triangles[i];
					var p0  = tri[0];
					var p1  = tri[1];
					var p2  = tri[2];
					
					draw_vertex(mx + p0.x, my + p0.y);
					draw_vertex(mx + p1.x, my + p1.y);
					draw_vertex(mx + p2.x, my + p2.y);
				}
				draw_primitive_end();
			} else 
				draw_clear(c_white);
		surface_reset_shader();
		
		surface_set_shader(preview_surface[1], noone);
			draw_surface_safe(preview_surface[0]);
			
			BLEND_MULTIPLY
				draw_surface_safe(temp_surface[1]);
			BLEND_NORMAL
			
		surface_reset_shader();
		
		// surface_set_shader(preview_surface[1], sh_canvas_corner);
			
		// 	shader_set_f("dimension",  _dim);
		// 	shader_set_f("amount",     amount);
		// 	shader_set_surface("base", _suf);
			
		// 	draw_surface_safe(preview_surface[0]);
		// surface_reset_shader();
		
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!modifying) return;
		
		if(array_length(anchorsRounded) >= 3) {
		
			draw_set_color(COLORS._main_accent);
			var ox, oy, nx, ny, sx, sy;
			var mx = mask_boundary_init[0];
			var my = mask_boundary_init[1];
			
			ox = anchorsRounded[0].x;
			oy = anchorsRounded[0].y;
			
			sx = ox;
			sy = oy;
			
			for( var i = 1, n = array_length(anchorsRounded); i < n; i++ ) {
				nx = anchorsRounded[i].x;
				ny = anchorsRounded[i].y;
				
				draw_line(_x + (mx + ox) * _s, _y + (my + oy) * _s, 
				          _x + (mx + nx) * _s, _y + (my + ny) * _s);
				
				ox = nx;
				oy = ny;
			}
			
			draw_line(_x + (mx + ox) * _s, _y + (my + oy) * _s, 
			          _x + (mx + sx) * _s, _y + (my + sy) * _s);
			          
		} else if(array_length(anchors) >= 3) {
			
			draw_set_color(COLORS._main_accent);
			var ox, oy, nx, ny, sx, sy;
			var mx = mask_boundary_init[0];
			var my = mask_boundary_init[1];
			
			ox = anchors[0].x;
			oy = anchors[0].y;
			
			sx = ox;
			sy = oy;
			
			for( var i = 1, n = array_length(anchors); i < n; i++ ) {
				nx = anchors[i].x;
				ny = anchors[i].y;
				
				draw_line(_x + (mx + ox) * _s, _y + (my + oy) * _s, 
				          _x + (mx + nx) * _s, _y + (my + ny) * _s);
				
				ox = nx;
				oy = ny;
			}
			
			draw_line(_x + (mx + ox) * _s, _y + (my + oy) * _s, 
			          _x + (mx + sx) * _s, _y + (my + sy) * _s);
			          
		}
		
		    
		// var a, b, c;
		// var d;
		
		// for( var i = 0, n = array_length(anchors); i < n; i++ ) {
		// 	a = anchors[(i - 1 + n) % n];
		// 	b = anchors[i];
		// 	c = anchors[(i + 1 + n) % n];
			
		// 	d = calculateCircleCenter(a, b, c, amount);
			
		// 	var _ox = _x + (mx + d[0]) * _s;
		// 	var _oy = _y + (my + d[1]) * _s;
		// 	var _or = d[2] * _s;
			
		// 	var dd = sqrt(sqr(d[3]) - sqr(d[2]));
		// 	var ba = point_direction(b[0], b[1], a[0], a[1]);
  //  		var bc = point_direction(b[0], b[1], c[0], c[1]);
    	
  //  		var e = [ b[0] + lengthdir_x(dd, ba), b[1] + lengthdir_y(dd, ba) ];
  //  		var f = [ b[0] + lengthdir_x(dd, bc), b[1] + lengthdir_y(dd, bc) ];
    		
  //  		var ee = point_direction(d[0], d[1], e[0], e[1]);
  //  		var ff = point_direction(d[0], d[1], f[0], f[1]);
    		
		// 	// draw_circle(_ox, _oy, _or, true);
		// 	draw_arc(_ox, _oy, _or, ee, ff, 1, 90);
		// }
	}
}

function calculateCircleCenter(a, b, c, r) {
    
    var ba = point_direction(b.x, b.y, a.x, a.y);
    var bc = point_direction(b.x, b.y, c.x, c.y);
    var da = point_distance(b.x, b.y, a.x, a.y);
    var dc = point_distance(b.x, b.y, c.x, c.y);
    r = min(r, da / 2, dc / 2);
    
    var a2 = angle_difference(bc, ba) / 2;
    var dd = r / dsin(a2);
    
    return {
    	x: b.x + lengthdir_x(dd, ba + a2),
    	y: b.y + lengthdir_y(dd, ba + a2), 
    	r: r, 
    	d: dd,
	};
}