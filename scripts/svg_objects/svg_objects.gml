function SVGElement(svgObj = noone) constructor {
	parent = svgObj;
	
	x = 0;
	y = 0;
	
	width  = 1;
	height = 1;
	
	fill         = undefined;
	fill_opacity = undefined;
	
	stroke       = undefined;
	stroke_width = undefined;
	
	static setAttr = function(attr) {
		
		var box  = struct_try_get(attr, "viewBox", "");
		var ww   = struct_try_get(attr, "width",   "");
		var hh   = struct_try_get(attr, "height",  "");
		
		box = string_splice(box, " ");
		var bx = toNumber(array_safe_get(box, 0, 0));
		var by = toNumber(array_safe_get(box, 1, 0));
		var bw = toNumber(array_safe_get(box, 2, 1));
		var bh = toNumber(array_safe_get(box, 3, 1));
		
		width  = toNumber(ww);
		height = toNumber(hh);
		
		if(string_pos("%", ww)) width  *= bw / 100;
		if(string_pos("%", hh)) height *= bh / 100;
		
		fill         = struct_try_get(attr, "fill",         undefined);
		stroke       = struct_try_get(attr, "stroke",       undefined);
		stroke_width = struct_try_get(attr, "stroke-width", undefined);
		
		if(is_string(fill))   fill   = color_from_rgb(string_replace_all(fill,   "#", ""));
		if(is_string(stroke)) stroke = color_from_rgb(string_replace_all(stroke, "#", ""));
		
		shapeAttr(attr);
		
		return self;
	}
	
	static shapeAttr = function(attr) {}
	
	static draw = function(scale = 1) {}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
}

function SVG(svgObj = noone) : SVGElement(svgObj) constructor {
	bbox   = [ 1, 1, 1, 1 ];
	
	fill         = c_black;
	fill_opacity = 1;
	
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

function SVG_path(svgObj = noone) : SVGElement(svgObj) constructor {
	
	segments = [];
	shapes   = [];
	
	static setTris = function() {
		shapes = [];
		var ox, oy, nx, ny, x0, y0, x1, y1;
		
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
				
				if(j) {
					if(array_length(_s) == 4) {
						x0 = _s[2];
						y0 = _s[3];
						
						array_push(_ctri, [ ox, oy, x0, y0, nx, ny ]);
						
					}
				}
				
				ox = nx;
				oy = ny;
			}
			
			_pTri[3]  = _ctri;
			shapes[i] = _pTri;
			
			// print($"{i}: {array_length(_pTri[0])} - {_pTri[2]}");
		}
		
	}
	
	static bezierCubicApprox = function(anchors, x1, y1, x2, y2, x3, y3, x4, y4) {
		var _len = point_distance(x1, y1, x2, y2)
		         + point_distance(x2, y2, x3, y3)
		         + point_distance(x3, y3, x4, y4);
		         
		var _smp = ceil(_len / 12);
		var _stp = 1 / _smp;
		var _p;
		
		for(var i = 0; i < _smp; i++) {
			_p = eval_bezier((i + 1) * _stp, x1, y1, x4, y4, x2, y2, x3, y3);
			array_push(anchors, [ parent.mapX(_p[0]), parent.mapY(_p[1]) ]);
		}
	}
	
	static arcToBezier = function(anchors, _x1, _y1, _x2, _y2, _rx, _ry, _a, _fa, _fs) {
		
		// var x1p = (_x1 - _x2) / 2 *   dcos(_a)  + (_y1 - _y2) / 2 * dsin(_a);
		// var y1p = (_x1 - _x2) / 2 * (-dsin(_a)) + (_y1 - _y2) / 2 * dcos(_a);
		
		// var _rr = sqrt((_rx * _rx * _ry * _ry - _rx * _rx * y1p * y1p - _ry * _ry * x1p * x1p) / (_rx * _rx * y1p * y1p + _ry * _ry * x1p * x1p));
		// // if(_fa == _fs) _rr *= -1;
		
		// var _cxp =  _rr * _rx * y1p / _ry;
		// var _cyp = -_rr * _ry * x1p / _rx;
		
		// var _cx = _cxp * dcos(_a) + _cyp * (-dsin(_a)) + (_x1 + _x2) / 2;
		// var _cy = _cxp * dsin(_a) + _cyp *   dcos(_a)  + (_y1 + _y2) / 2;
		
		// var _a1  = point_direction(_cx, _cy, _x1, _y1);
		// var _a2  = point_direction(_cx, _cy, _x2, _y2);
		// var _dif = angle_difference(_a1, _a2);
		// // if(!_fs && _dif > 0) _dif -= 360;
		// // if( _fs && _dif < 0) _dif += 360;
		
		// var _ang = _a1 + _dif / 2;
		// var _px  = dcos(_ang) * _rx;
		// var _py  = dsin(_ang) * _ry;
		// var _p   = point_rotate(_px, _py, 0, 0, _a);
		
		// array_push(anchors, [ parent.mapX(_cx + _p[0]), parent.mapY(_cy + _p[1]) ]);
		array_push(anchors, [ parent.mapX(_x2),         parent.mapY(_y2) ]);
		
		// var _stp = abs(_dif) * (_rx + _ry) / 360;
		// for(var i = 1; i <= _stp; i++) {
		// 	var _ang = lerp_angle_linear(_a1, _a2, i / _stp);
			
		// 	var _px  = dcos(_ang) * _rx;
		// 	var _py  = dsin(_ang) * _ry;
		// 	var _p   = point_rotate(_px, _py, 0, 0, _a);
			
		// 	array_push(anchors, [ parent.mapX(_cx + _p[0]), parent.mapY(_cy + _p[1]) ]);
		// }
	}
	
	static shapeAttr = function(attr) {
		
		var def   = struct_try_get(attr, "d", "");
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
		var _oc = ord(",");
		
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
			
			if(_och == _os || _och == _oc || _chrn == _om || (_chrn >= _oa && _chrn <= _oz) || (_chrn >= _oA && _chrn <= _oZ)) {
				
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
							var _x0 = _tx;
							var _y0 = _ty;
							var _x1 = _par[0];
							var _y1 = _par[1];
							var _x2 = _par[2];
							var _y2 = _par[3];
							    _tx = _par[4];
							    _ty = _par[5];
							
							_cx = _x2 - _tx;
							_cy = _y2 - _ty;
							
							bezierCubicApprox(anchors, _x0, _y0, _x1, _y1, _x2, _y2, _tx, _ty);
							
							// array_push(anchors, [ parent.mapX(_tx), 
							// 					  parent.mapY(_ty), 
							// 					  parent.mapX(_x1), 
							// 					  parent.mapY(_y1), 
							// 					  parent.mapX(_x2), 
							// 					  parent.mapY(_y2) ]);
							_par = [];
						}
						break;
						
					case "c" : //Cubic bezier relative
						if(array_length(_par) >= 6) {
							var _x0 = _tx;
							var _y0 = _ty;
							var _x1 = _tx + _par[0];
							var _y1 = _ty + _par[1];
							var _x2 = _tx + _par[2];
							var _y2 = _ty + _par[3];
							    _tx = _tx + _par[4];
							    _ty = _ty + _par[5];
							
							_cx = _x2 - _tx;
							_cy = _y2 - _ty;
							
							bezierCubicApprox(anchors, _x0, _y0, _x1, _y1, _x2, _y2, _tx, _ty);
							
							// array_push(anchors, [ parent.mapX(_tx), 
							// 					  parent.mapY(_ty), 
							// 					  parent.mapX(_x1), 
							// 					  parent.mapY(_y1), 
							// 					  parent.mapX(_x2), 
							// 					  parent.mapY(_y2) ]);
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
						
					case "A" : //Elliptical arc
						if(array_length(_par) >= 7) {
							var _x0 = _tx;
							var _y0 = _ty;
							var _rx = _par[0];
							var _ry = _par[1];
							var _a  = _par[2];
							var _la = _par[3];
							var _sw = _par[4];
							    _tx = _par[5];
							    _ty = _par[6];
							
							arcToBezier(anchors, _x0, _y0, _tx, _ty, _rx, _ry, _a, _la, _sw);
							_par = [];
							
							noti_warning("SVG 2.0 feature detected [Elliptical arc] : Reimport file to SVG 1.1 to prevent draw error.")
						}
						break;
						
					case "a" : //Elliptical arc
						if(array_length(_par) >= 7) {
							var _x0 = _tx;
							var _y0 = _ty;
							var _rx  = _par[0];
							var _ry  = _par[1];
							var _a   = _par[2];
							var _la  = _par[3];
							var _sw  = _par[4];
							    _tx += _par[5];
							    _ty += _par[6];
							
							arcToBezier(anchors, _x0, _y0, _tx, _ty, _rx, _ry, _a, _la, _sw);
							_par = [];
							
							noti_warning("SVG 2.0 feature detected [Elliptical arc] : Reimport file to SVG 1.1 to prevent draw error.")
						}
						break;
						
				}
			} 
		}
		
		setTris();
		
		return self;
	}

	static draw = function(scale = 1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
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
						if(array_length(_ctr[j]) == 6) {
							draw_vertex_texture(_ctr[j][0] * scale, _ctr[j][1] * scale, 0.0, 0);
							draw_vertex_texture(_ctr[j][2] * scale, _ctr[j][3] * scale, 0.5, 0);
							draw_vertex_texture(_ctr[j][4] * scale, _ctr[j][5] * scale, 1.0, 1);
							
						}
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

function SVG_rect(svgObj = noone) : SVGElement(svgObj) constructor {
	
	static shapeAttr = function(attr) {
		x = struct_try_get(attr, "x", 0);
		y = struct_try_get(attr, "y", 0);
		
		width  = struct_try_get(attr, "width",  0);
		height = struct_try_get(attr, "height", 0);
	}
	
	static draw = function(scale = 1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
		var _x = x * scale;
		var _y = y * scale;
		var _w = width  * scale;
		var _h = height * scale;
		
		draw_rectangle(_x, _y, _x + _w, _y + _h, false);
		
		if(is_undefined(stroke) || is_undefined(stroke_width)) 
			return;
		
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_rectangle(_x, _y, _x + _w, _y + _h, true);
		else 
			draw_rectangle_border(_x, _y, _x + _w, _y + _h, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _ox = _x + x * _s;
		var _oy = _y + y * _s;
		var _ow = width  * _s;
		var _oh = height * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_rectangle(_ox, _oy, _ox + _ow, _oy + _oh, true);
	}
}

function SVG_circle(svgObj = noone) : SVGElement(svgObj) constructor {
	cx = 0;
	cy = 0;
	r  = 0;
	
	static shapeAttr = function(attr) {
		cx = struct_try_get(attr, "cx", 0);
		cy = struct_try_get(attr, "cy", 0);
		
		r  = struct_try_get(attr, "r", 0);
	}
	
	static draw = function(scale = 1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
		var _cx = cx * scale;
		var _cy = cy * scale;
		var _r  = r  * scale;
		
		draw_circle(_cx, _cy, _r, false);
		
		if(is_undefined(stroke) || is_undefined(stroke_width)) 
			return;
		
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_circle(_cx, _cy, _r, true);
		else 
			draw_circle_border(_cx, _cy, _r, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _ox = _x + cx * _s;
		var _oy = _y + cy * _s;
		var _or = r * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle(_ox, _oy, _or, true);
	}
}

function SVG_ellipse(svgObj = noone) : SVGElement(svgObj) constructor {
	cx = 0;
	cy = 0;
	rx = 0;
	ry = 0;
	
	static shapeAttr = function(attr) {
		cx = struct_try_get(attr, "cx", 0);
		cy = struct_try_get(attr, "cy", 0);
		
		rx  = struct_try_get(attr, "rx", 0);
		ry  = struct_try_get(attr, "ry", 0);
	}
	
	static draw = function(scale = 1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
		var _cx = cx * scale;
		var _cy = cy * scale;
		var _rx = rx * scale;
		var _ry = ry * scale;
		
		draw_ellipse(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, false);
		
		if(is_undefined(stroke) || is_undefined(stroke_width)) 
			return;
		
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_ellipse(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, true);
		else 
			draw_ellipse_border(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _ox = _x + cx * _s;
		var _oy = _y + cy * _s;
		var _rx = rx * _s;
		var _ry = ry * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_ellipse(_ox - _rx, _oy - _ry, _ox + _rx, _oy + _ry, true);
	}
}

function SVG_line(svgObj = noone) : SVGElement(svgObj) constructor {
	x0 = 0;
	y0 = 0;
	x1 = 0;
	y1 = 0;
	
	static shapeAttr = function(attr) {
		x0 = struct_try_get(attr, "x0", 0);
		y0 = struct_try_get(attr, "y0", 0);
		
		x1 = struct_try_get(attr, "x1", 0);
		y1 = struct_try_get(attr, "y1", 0);
	}
	
	static draw = function(scale = 1) {
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke) && is_undefined(stroke_width)) 
			return;
		
		var _x0 = x0 * scale;
		var _y0 = y0 * scale;
		var _x1 = x1 * scale;
		var _y1 = y1 * scale;
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_line(_x0, _y0, _x1, _y1);
		else 
			draw_line_width(_x0, _y0, _x1, _y1, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _x0 = _x + x0 * _s;
		var _y0 = _y + y0 * _s;
		var _x1 = _x + x1 * _s;
		var _y1 = _y + y1 * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(_x0, _y0, _x1, _y1);
	}
}

function SVG_polyline(svgObj = noone) : SVGElement(svgObj) constructor {
	points = [];
	
	static shapeAttr = function(attr) {
		points = struct_try_get(attr, "points", []);
	}
	
	static draw = function(scale = 1) {
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke) && is_undefined(stroke_width)) 
			return;
		
		var _ox, _oy, _nx, _ny;
		
		for (var i = 0, n = floor(array_length(points) / 2); i < n; i++) {
			_nx = points[i * 2 + 0] * scale;
			_ny = points[i * 2 + 1] * scale;
			
			if(i) {
				if(is_undefined(stroke_width) || stroke_width == 1)
					draw_line(_ox, _oy, _nx, _ny);
				else 
					draw_line_width(_ox, _oy, _nx, _ny, stroke_width);
			}
			
			_ox = _nx;
			_oy = _ny;
		}
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		draw_set_color(COLORS._main_accent);
		
		var _ox, _oy, _nx, _ny;
		
		for (var i = 0, n = floor(array_length(points) / 2); i < n; i++) {
			_nx = _x + points[i * 2 + 0] * _s;
			_ny = _y + points[i * 2 + 1] * _s;
			
			if(i) {
				if(is_undefined(stroke_width) || stroke_width == 1)
					draw_line(_ox, _oy, _nx, _ny);
				else 
					draw_line_width(_ox, _oy, _nx, _ny, stroke_width);
			}
			
			_ox = _nx;
			_oy = _ny;
		}
	}
}

function SVG_polygon(svgObj = noone) : SVGElement(svgObj) constructor {
	points = [];
	
	static shapeAttr = function(attr) {
		points = struct_try_get(attr, "points", []);
	}
	
	static draw = function(scale = 1) {
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke) && is_undefined(stroke_width)) 
			return;
		
		var _ox, _oy, _nx, _ny;
		
		for (var i = 0, n = floor(array_length(points) / 2); i < n; i++) {
			_nx = points[i * 2 + 0] * scale;
			_ny = points[i * 2 + 1] * scale;
			
			if(i) {
				if(is_undefined(stroke_width) || stroke_width == 1)
					draw_line(_ox, _oy, _nx, _ny);
				else 
					draw_line_width(_ox, _oy, _nx, _ny, stroke_width);
			}
			
			_ox = _nx;
			_oy = _ny;
		}
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		draw_set_color(COLORS._main_accent);
		
		var _ox, _oy, _nx, _ny;
		
		for (var i = 0, n = floor(array_length(points) / 2); i < n; i++) {
			_nx = _x + points[i * 2 + 0] * _s;
			_ny = _y + points[i * 2 + 1] * _s;
			
			if(i) {
				if(is_undefined(stroke_width) || stroke_width == 1)
					draw_line(_ox, _oy, _nx, _ny);
				else 
					draw_line_width(_ox, _oy, _nx, _ny, stroke_width);
			}
			
			_ox = _nx;
			_oy = _ny;
		}
	}
}

