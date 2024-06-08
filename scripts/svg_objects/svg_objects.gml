function SVG() constructor {
	width  = 1;
	height = 1;
	bbox   = [ 1, 1, 1, 1 ];
	
	fill         = c_black;
	fill_opacity = 1;
	
	stroke       = undefined;
	stroke_width = undefined;
	
	contents = [];
	
	static mapX = function(px) { return lerp_invert(px, bbox[0], bbox[0] + bbox[2]) *  width; }
	static mapY = function(py) { return lerp_invert(py, bbox[1], bbox[1] + bbox[3]) * height; }
	
	static getSurface = function(scale = 1) { return surface_create(width * scale, height * scale); }
	
	static draw = function(scale = 1) {
		if(!is_undefined(fill)) 
			draw_set_color(fill);
		
		if(!is_undefined(fill_opacity)) 
			draw_set_alpha(fill_opacity);
		
		for (var i = 0, n = array_length(contents); i < n; i++)
			contents[i].draw(scale);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		for (var i = 0, n = array_length(contents); i < n; i++)
			contents[i].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
}

function SVG_path(svgObj) constructor {
	parent   = svgObj;
	
	fill         = undefined;
	fill_opacity = undefined;
	
	stroke       = undefined;
	stroke_width = undefined;
	
	segments = [];
	shapes   = [];
	
	static setTris = function() {
		shapes = [];
		var ox, oy, nx, ny, x0, y0;
		
		for (var i = 0, n = array_length(segments); i < n; i++) {
			var _seg = segments[i];
			var _p   = array_create(array_length(_seg));
			
			for (var j = 0, m = array_length(_seg); j < m; j++)
				_p[j] = new __vec2(_seg[j][0], _seg[j][1]);
			
			var _pTri = polygon_triangulate(_p);
			var _ctri = [];
			
			for (var j = 0, m = array_length(_seg); j < m; j++) {
				var _s = _seg[j];
				nx = _s[0];
				ny = _s[1];
				
				if(j && array_length(_s) == 4) {
					x0 = _s[2];
					y0 = _s[3];
					
					array_push(_ctri, [ ox, oy, x0, y0, nx, ny ]);
				}
				
				ox = nx;
				oy = ny;
			}
			
			_pTri[3]  = _ctri;
			shapes[i] = _pTri;
			
			// print($"{i}: {array_length(_pTri[0])} - {_pTri[2]}");
		}
		
	}
	
	static setDef = function(def) {
		var _mode = "";
		var _len  = string_length(def);
		var _ind  = 1;
		var _val  = "";
		var _par  = [];
		
		var _oa = ord("a"), _oz = ord("z");
		var _oA = ord("A"), _oZ = ord("Z");
		var _o0 = ord("0"), _o9 = ord("9");
		
		var _om = ord("-"); 
		var _od = ord(".");
		var _os = ord(" ");
		
		var _sx = 0, _sy = 0;
		var _tx = 0, _ty = 0;
		var _cx = 0, _cy = 0;
		
		segments = [];
		var anchors = [];
		// print("=========================================================================");
		// print(def);
		
		repeat(_len) {
			var _chr  = string_char_at(def, _ind);
			var _chrn = _ind < _len? ord(string_char_at(def, _ind + 1)) : 0;
			var _och  = ord(_chr);
			var _eval = false;
			_ind++;
			
			if((_och >= _oa && _och <= _oz) || (_och >= _oA && _och <= _oZ)) {
				
				if(_chr == "Z" || _chr == "z") {
					array_push(anchors, [ parent.mapX(_sx), parent.mapY(_sy) ]);
					
					if(!array_empty(anchors)) 
						array_push(segments, anchors);
					anchors = [];
					
				} else if(_chr == "M" || _chr == "m") {
					
					if(!array_empty(anchors)) 
						array_push(segments, anchors);
					anchors = [];
				}
				
				_mode = _chr;
				_val  = "";
				
			} else if((_och >= _o0 && _och <= _o9) || _och == _od || _och == _om) {
				_val += _chr;
			}
			
			if(_och == _os || _chrn == _om || (_chrn >= _oa && _chrn <= _oz) || (_chrn >= _oA && _chrn <= _oZ)) {
				
				if(_val != "")
					array_push(_par, real(_val));
				_val  = "";
				_eval = true;
			} 
			
			if(_eval) {
				// print($"Eval [{_mode}]: ({anchors}) - {_par}");
				
				switch(_mode) {
					case "M" : //Move to absolute
						
						if(array_length(_par) >= 2) {
							_tx = _par[0];
							_ty = _par[1];
							_sx = _tx;
							_sy = _ty;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "m" : //Move to relative
					
						if(array_length(_par) >= 2) {
							_tx += _par[0];
							_ty += _par[1];
							_sx  = _tx;
							_sy  = _ty;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "L" : //Line to absolute
						if(array_length(_par) >= 2) {
							_tx = _par[0];
							_ty = _par[1];
						
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "l" : //Line to relative
						if(array_length(_par) >= 2) {
							_tx += _par[0];
							_ty += _par[1];
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "H" : //Line to horizontal absolute
						if(array_length(_par) >= 1) {
							_tx = _par[0];
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "h" : //Line to horizontal relative
						if(array_length(_par) >= 1) {
							_tx += _par[0];
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "V" : //Line to vertical absolute
						if(array_length(_par) >= 1) {
							_ty = _par[0];
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "v" : //Line to vertical relative
						if(array_length(_par) >= 1) {
							_ty += _par[0];
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty) ]);
							_par = [];
						}
						break;
						
					case "C" : //Cubic bezier absolute
						if(array_length(_par) >= 6) {
							var _x1 = _par[0];
							var _y1 = _par[1];
							var _x2 = _par[2];
							var _y2 = _par[3];
							    _tx = _par[4];
							    _ty = _par[5];
							
							_cx = _x2 - _tx;
							_cy = _y2 - _ty;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1), 
												  parent.mapX(_x2), 
												  parent.mapY(_y2) ]);
							_par = [];
						}
						break;
						
					case "c" : //Cubic bezier relative
						if(array_length(_par) >= 6) {
							var _x1 = _tx + _par[0];
							var _y1 = _ty + _par[1];
							var _x2 = _tx + _par[2];
							var _y2 = _ty + _par[3];
							    _tx = _tx + _par[4];
							    _ty = _ty + _par[5];
							
							_cx = _x2 - _tx;
							_cy = _y2 - _ty;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1), 
												  parent.mapX(_x2), 
												  parent.mapY(_y2) ]);
							_par = [];
						}
						break;
						
					case "S" : //Smooth cubic bezier absolute
						if(array_length(_par) >= 4) {
							var _x1 = _tx + _cx;
							var _y1 = _ty + _cy;
							var _x2 = _par[0];
							var _y2 = _par[1];
							    _tx = _par[2];
							    _ty = _par[3];
							
							_cx = _x2 - _tx;
							_cy = _y2 - _ty;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1), 
												  parent.mapX(_x2), 
												  parent.mapY(_y2) ]);
							_par = [];
						}
						break;
						
					case "s" : //Smooth cubic bezier relative
						if(array_length(_par) >= 4) {
							var _x1 = _tx + _cx;
							var _y1 = _ty + _cy;
							var _x2 = _tx + _par[0];
							var _y2 = _ty + _par[1];
							    _tx = _tx + _par[2];
							    _ty = _ty + _par[3];
							
							_cx = _x2 - _tx;
							_cy = _y2 - _ty;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1), 
												  parent.mapX(_x2), 
												  parent.mapY(_y2) ]);
							_par = [];
						}
						break;
						
					case "Q" : //Quadratic bezier absolute
						if(array_length(_par) >= 4) {
							var _x1 = _par[0];
							var _y1 = _par[1];
							    _tx = _par[2];
							    _ty = _par[3];
							
							_cx = _tx - _x1;
							_cy = _ty - _y1;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1) ]);
							_par = [];
						}
						break;
						
					case "q" : //Quadratic bezier relative
						if(array_length(_par) >= 4) {
							var _x1 = _tx + _par[0];
							var _y1 = _ty + _par[1];
							    _tx = _tx + _par[2];
							    _ty = _ty + _par[3];
							
							_cx = _tx - _x1;
							_cy = _ty - _y1;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1) ]);
							_par = [];
						}
						break;
						
					case "T" : //Smooth quadratic bezier absolute
						if(array_length(_par) >= 2) {
							var _x1 = _tx + _cx;
							var _y1 = _ty + _cy;
							    _tx = _par[0];
							    _ty = _par[1];
							
							_cx = _tx - _x1;
							_cy = _ty - _y1;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1) ]);
							_par = [];
						}
						break;
						
					case "t" : //Smooth quadratic bezier relative
						if(array_length(_par) >= 2) {
							var _x1 = _tx + _cx;
							var _y1 = _ty + _cy;
							    _tx = _tx + _par[0];
							    _ty = _ty + _par[1];
							
							_cx = _tx - _x1;
							_cy = _ty - _y1;
							
							array_push(anchors, [ parent.mapX(_tx), 
												  parent.mapY(_ty), 
												  parent.mapX(_x1), 
												  parent.mapY(_y1) ]);
							_par = [];
						}
						break;
						
				}
			} 
		}
		
		setTris();
		// print(segments);
	}

	static draw = function(scale = 1) {
		if(!is_undefined(fill)) 
			draw_set_color(fill);
		
		if(!is_undefined(fill_opacity)) 
			draw_set_alpha(fill_opacity);
		
		var _temp = [
			parent.getSurface(scale),
			parent.getSurface(scale),
		];
		
		var _sw = surface_get_width_safe(_temp[0]);
		var _sh = surface_get_height_safe(_temp[0]);
		
		surface_clear(_temp[0]);
		surface_clear(_temp[1]);
		
		var _surf = parent.getSurface(scale);
		
		for (var i = 0, n = array_length(shapes); i < n; i++) {
			var shp  = shapes[i];
			var _tri = shp[0];
			var _sid = shp[2];
			var _ctr = shp[3];
			
			surface_set_target(_surf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
				draw_primitive_begin(pr_trianglelist);
				for (var j = 0, m = array_length(_tri); j < m; j++) {
					draw_vertex(_tri[j][0].x * scale, _tri[j][0].y * scale);
					draw_vertex(_tri[j][1].x * scale, _tri[j][1].y * scale);
					draw_vertex(_tri[j][2].x * scale, _tri[j][2].y * scale);
				}
				draw_primitive_end();
				
				shader_set(sh_svg_curve_quad);
				draw_primitive_begin(pr_trianglelist);
				for (var j = 0, m = array_length(_ctr); j < m; j++) {
					draw_vertex_texture(_ctr[j][0] * scale, _ctr[j][1] * scale, 0.0, 0);
					draw_vertex_texture(_ctr[j][2] * scale, _ctr[j][3] * scale, 0.5, 0);
					draw_vertex_texture(_ctr[j][4] * scale, _ctr[j][5] * scale, 1.0, 1);
				}
				draw_primitive_end();
				shader_reset();
			
			BLEND_NORMAL
			surface_reset_target();
			
			surface_set_shader(_temp[i % 2], sh_svg_fill);
				
				shader_set_surface("bg", _temp[!(i % 2)]);
				shader_set_surface("fg", _surf);
				
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _sw, _sh, draw_get_color(), draw_get_alpha());
				
			surface_reset_shader();
			
		}
		
		draw_surface(_temp[!(i % 2)], 0, 0);
		
		surface_free(_surf);
		surface_free(_temp[0]);
		surface_free(_temp[1]);
	}

	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		for (var i = 0, n = array_length(segments); i < n; i++) {
			var _seg = segments[i];
			var _ox, _oy, _nx, _ny;
			
			draw_set_color(COLORS._main_accent);
			
			for (var j = 0, m = array_length(_seg); j < m; j++) {
				var _pnt = _seg[j];
				_nx = _pnt[0];
				_ny = _pnt[1];
				
				_nx  = _x + _nx * _s;
				_ny  = _y + _ny * _s;
				
				if(j) draw_line(_ox, _oy, _nx, _ny);
				draw_circle(_nx, _ny, 4, false);
				
				if(array_length(_pnt) >= 4) {
					var _nx1 = _pnt[2];
					var _ny1 = _pnt[3];
					
					_nx1  = _x + _nx1 * _s;
					_ny1  = _y + _ny1 * _s;
					
					draw_circle(_nx1, _ny1, 4, true);
				} 
				
				if(array_length(_pnt) >= 6) {
					var _nx1 = _pnt[4];
					var _ny1 = _pnt[5];
					
					_nx1  = _x + _nx1 * _s;
					_ny1  = _y + _ny1 * _s;
					
					draw_circle(_nx1, _ny1, 4, true);
				} 
				
				_ox = _nx;
				_oy = _ny;
			}
		}
	}
}