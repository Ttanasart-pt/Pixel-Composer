function SVGElement(svgObj = noone) : dynaSurf() constructor {
	parent = svgObj;
	
	x = 0;
	y = 0;
	
	width  = 1;
	height = 1;
	
	fill         = undefined;
	fill_opacity = undefined;
	
	stroke       = undefined;
	stroke_width = undefined;
	
	static getWidth     = function() /*=>*/ {return width};
	static getHeight    = function() /*=>*/ {return height};
	static getFormat    = function() /*=>*/ {return surface_rgba8unorm};
	static getDimension = function() /*=>*/ {return [ width, height ]};
	
	static attrColor = function(attr, key) {
		if(!struct_has(attr, key)) return undefined;
		
		var str = attr[$ key];
		if(is_real(str))      return str;
		if(is_string(str))    return colorFromHex(string_replace(str, "#", ""));
		
		return c_black;
	}
	
	static attrReal  = function(str, def = 0) {
		if(is_undefined(str)) return str;
		if(is_real(str))      return str;
		
		var e;
		if(is_string(str)) {
			try      { return real(str); } 
			catch(e) { return def; }
		}
		
		return def;
	}
	
	static setAttr   = function(attr) /*=>*/ {
		
		var box  = struct_try_get(attr, "viewBox", "");
		var ww   = struct_try_get(attr, "width",   "");
		var hh   = struct_try_get(attr, "height",  "");
		
		    box = string_splice(box, " ");
		var bx  = attrReal(array_safe_get(box, 0, 0), 0);
		var by  = attrReal(array_safe_get(box, 1, 0), 0);
		var bw  = attrReal(array_safe_get(box, 2, 1), 1);
		var bh  = attrReal(array_safe_get(box, 3, 1), 1);
		
		width  = attrReal(ww, 1);
		height = attrReal(hh, 1);
		
		if(string_pos("%", ww)) width  *= bw / 100;
		if(string_pos("%", hh)) height *= bh / 100;
		
		fill         = attrColor(attr, "fill");
		stroke       = attrColor(attr, "stroke");
		stroke_width = struct_try_get(attr, "stroke-width", undefined);
		
		onSetAttr(attr);
		
		return self;
	}
	static onSetAttr = function(attr) /*=>*/ {}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
}

function SVG(svgObj = noone) : SVGElement(svgObj) constructor {
	bbox   = [ 1, 1, 1, 1 ];
	
	fill         = c_black;
	fill_opacity = 1;
	
	contents = [];
	surfaces = [ noone ];
	
	static mapX = function(px) /*=>*/ {return lerp_invert(px, bbox[0], bbox[0] + bbox[2]) *  width};
	static mapY = function(py) /*=>*/ {return lerp_invert(py, bbox[1], bbox[1] + bbox[3]) * height};
	
	static onSetAttr = function(attr) /*=>*/ {
		if(struct_has(attr, "viewBox")) {
			var _bbox = attr.viewBox;
			_bbox = string_splice(_bbox);
			for (var i = 0, n = array_length(_bbox); i < n; i++)
				bbox[i] = attrReal(_bbox[i]);
		}
	}
	
	static setContent = function(cont) {
		if(!struct_has(cont, "children")) return;
		
		setAttr(cont.attributes);
		var _ind = 0;
		
		for (var i = 0, n = array_length(cont.children); i < n; i++) {
			var _ch = cont.children[i];
			
			switch(_ch.type) {
				case "path" :	  contents[_ind++] = new SVG_path(self).setAttr(_ch.attributes);		break;
				case "rect" :	  contents[_ind++] = new SVG_rect(self).setAttr(_ch.attributes);		break;
				case "circle" :   contents[_ind++] = new SVG_circle(self).setAttr(_ch.attributes);		break;
				case "ellipse" :  contents[_ind++] = new SVG_ellipse(self).setAttr(_ch.attributes);		break;
				case "line" :	  contents[_ind++] = new SVG_line(self).setAttr(_ch.attributes);		break;
				case "polyline" : contents[_ind++] = new SVG_polyline(self).setAttr(_ch.attributes);	break;
				case "polygon" :  contents[_ind++] = new SVG_polygon(self).setAttr(_ch.attributes);		break;
			}
		}
		
		return self;
	}
	
	static getSurface = function(sx=1, sy=1) /*=>*/ {return surface_verify(surfaces[0], width * sx, height * sy)};
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		for (var i = 0, n = array_length(contents); i < n; i++) {
			if(!is_undefined(fill)) 		draw_set_color(fill);
			if(!is_undefined(fill_opacity)) draw_set_alpha(fill_opacity);
			
			contents[i].draw(dx, dy, sx, sy, _ang, _col, _alp);
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		for (var i = 0, n = array_length(contents); i < n; i++)
			contents[i].drawOverlay(hover, active, _x, _y, _s, _mx, _my);
	}
}

function SVG_path(svgObj = noone) : SVGElement(svgObj) constructor {
	
	segments = [];
	shapes   = [];
	surfaces = [ noone, noone, noone ];
	
	static setTris = function() /*=>*/ {
		shapes = [];
		var ox, oy, nx, ny, x0, y0, x1, y1;
		
		for (var i = 0, n = array_length(segments); i < n; i++) {
			var _seg = segments[i];
			var _p   = array_create(array_length(_seg));
			
			for (var j = 0, m = array_length(_seg); j < m; j++)
				_p[j] = new __vec2(_seg[j][0], _seg[j][1]);
			
			var _pTri = polygon_triangulate(_p);
			shapes[i] = _pTri;
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
			
			var _tri = _pTri[0];
			var _vb  = vertex_create_buffer();
			vertex_begin(_vb, VF_P3CT);
			for (var j = 0, m = array_length(_tri); j < m; j++) {
				vertex_position_3d(_vb, _tri[j][0].x, _tri[j][0].y, 0); vertex_color(_vb, c_white, 1); vertex_texcoord(_vb, 0, 0);
				vertex_position_3d(_vb, _tri[j][1].x, _tri[j][1].y, 0); vertex_color(_vb, c_white, 1); vertex_texcoord(_vb, 0, 0);
				vertex_position_3d(_vb, _tri[j][2].x, _tri[j][2].y, 0); vertex_color(_vb, c_white, 1); vertex_texcoord(_vb, 0, 0);
			}
			vertex_end(_vb);
			_pTri[4]  = _vb;
			
			var _ctr = _pTri[3];
			var _vb  = vertex_create_buffer();
			vertex_begin(_vb, VF_P3CT);
			for (var j = 0, m = array_length(_ctr); j < m; j++) {
				vertex_position_3d(_vb, _ctr[j][0], _ctr[j][1], 0); vertex_color(_vb, c_white, 1); vertex_texcoord(_vb, 0.0, 0);
				vertex_position_3d(_vb, _ctr[j][2], _ctr[j][3], 0); vertex_color(_vb, c_white, 1); vertex_texcoord(_vb, 0.5, 0);
				vertex_position_3d(_vb, _ctr[j][4], _ctr[j][5], 0); vertex_color(_vb, c_white, 1); vertex_texcoord(_vb, 1.0, 1);
			}
			vertex_end(_vb);
			_pTri[5]  = _vb;
			
		}
		
	}
	
	static bezierCubicApprox = function(anchors, x1, y1, x2, y2, x3, y3, x4, y4) /*=>*/ {
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
	
	static arcToBezier = function(anchors, _x1, _y1, _x2, _y2, _rx, _ry, _a, _fa, _fs) /*=>*/ {
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		
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
				
				if(_val != "") array_push(_par, real(_val));
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
							_par  = [];
							_mode = "L";
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
							_par  = [];
							_mode = "l";
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

	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(fill)) 		draw_set_color(fill);
		if(!is_undefined(fill_opacity)) draw_set_alpha(fill_opacity);
		
		var _sw = parent.width;
		var _sh = parent.height;
		var _bg = 0;
		var a = -degtorad(_ang);
		
		// for( var i = 0, n = array_length(surfaces); i < n; i++ ) {
		// 	surfaces[i] = surface_verify(surfaces[i], _sw, _sh); 
		// 	surface_clear(surfaces[i]);
		// }
		
		var _sw = surface_get_width(surface_get_target());
		var _sh = surface_get_height(surface_get_target());
		
		gpu_set_blendmode_ext(bm_inv_dest_alpha, bm_inv_dest_alpha);
		
		for (var i = 0, n = array_length(shapes); i < n; i++) {
			var shp  = shapes[i];
			
			var _vbf = shp[4];
			var _cbf = shp[5];
			
			// surface_set_target(surfaces[2]);
			// DRAW_CLEAR
			// BLEND_OVERRIDE
				
				matrix_stack_clear();
				
				matrix_stack_push([
					 1,  0, 0, 0, 
					 0,  1, 0, 0, 
					 0,  0, 1, 0, 
					dx, dy, 0, 1, 
				]);
				
				matrix_stack_push([
					 1,  0, 0, 0, 
					 0,  1, 0, 0, 
					 0,  0, 1, 0, 
					-_sw/2, -_sh/2, 0, 1, 
				]);
				
				matrix_stack_push([
					 cos(a), sin(a), 0, 0, 
					-sin(a), cos(a), 0, 0, 
					 0, 0, 1, 0, 
					 0, 0, 0, 1, 
				]);
				
				matrix_stack_push([
					sx,  0, 0, 0, 
					 0, sy, 0, 0, 
					 0,  0, 1, 0, 
					 0,  0, 0, 1, 
				]);
				
				camera_set_view_mat(camera_get_active(), matrix_stack_top());
				camera_apply(camera_get_active());
				vertex_submit(_vbf, pr_trianglelist, -1);
				
				shader_set(sh_svg_curve_quad);
				vertex_submit(_cbf, pr_trianglelist, -1);
				shader_reset();
			
				camera_set_view_mat(camera_get_active(), MATRIX_IDENTITY);
				matrix_stack_clear();
				
			// BLEND_NORMAL
			// surface_reset_target();
			
			// _bg = !_bg;
			// surface_set_shader(surfaces[_bg], sh_svg_fill);
			// 	shader_set_surface("bg", surfaces[!_bg]);
			// 	shader_set_surface("fg", surfaces[2]);
				
			// 	draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _sw, _sh, draw_get_color(), draw_get_alpha());
				
			// surface_reset_shader();
		}
		
		BLEND_NORMAL
		
		// draw_surface_safe(surfaces[_bg], dx, dy);
	}

	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		x = struct_try_get(attr, "x", 0);
		y = struct_try_get(attr, "y", 0);
		
		width  = struct_try_get(attr, "width",  0);
		height = struct_try_get(attr, "height", 0);
	}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
		var _x = dx * sx;
		var _y = dy * sy;
		var _w = width  * sx;
		var _h = height * sy;
		
		draw_rectangle(_x, _y, _x + _w, _y + _h, false);
		
		if(is_undefined(stroke) || is_undefined(stroke_width)) 
			return;
		
		if(!is_undefined(stroke)) draw_set_color(stroke);
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_rectangle(_x, _y, _x + _w, _y + _h, true);
		else 
			draw_rectangle_border(_x, _y, _x + _w, _y + _h, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		cx = struct_try_get(attr, "cx", 0);
		cy = struct_try_get(attr, "cy", 0);
		
		r  = struct_try_get(attr, "r", 0);
	}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
		var _cx = dx + cx * sx;
		var _cy = dy + cy * sy;
		var _rx = r  * sx;
		var _ry = r  * sy;
		
		if(sx == sy) draw_circle(  _cx, _cy, _rx, false);
		else         draw_ellipse( _cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, false);
		
		if(is_undefined(stroke) || is_undefined(stroke_width)) 
			return;
		
		if(!is_undefined(stroke)) draw_set_color(stroke);
		
		if(sx == sy) {
			if(is_undefined(stroke_width) || stroke_width == 1)
				draw_circle(_cx, _cy, r * sx, true);
			else 
				draw_circle_border(_cx, _cy, r * sx, stroke_width);
				
		} else {
			if(is_undefined(stroke_width) || stroke_width == 1)
				draw_ellipse(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, true);
			else 
				draw_ellipse_border(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, stroke_width);
				
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		cx = struct_try_get(attr, "cx", 0);
		cy = struct_try_get(attr, "cy", 0);
		
		rx  = struct_try_get(attr, "rx", 0);
		ry  = struct_try_get(attr, "ry", 0);
	}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(fill)) 			draw_set_color(fill);
		if(!is_undefined(fill_opacity)) 	draw_set_alpha(fill_opacity);
		
		var _cx = dx + cx * sx;
		var _cy = dy + cy * sy;
		var _rx = rx * sx;
		var _ry = ry * sy;
		
		draw_ellipse(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, false);
		
		if(is_undefined(stroke) || is_undefined(stroke_width)) 
			return;
		
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_ellipse(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, true);
		else 
			draw_ellipse_border(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		x0 = struct_try_get(attr, "x0", 0);
		y0 = struct_try_get(attr, "y0", 0);
		
		x1 = struct_try_get(attr, "x1", 0);
		y1 = struct_try_get(attr, "y1", 0);
	}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke) && is_undefined(stroke_width)) 
			return;
		
		var _x0 = dx + x0 * sx;
		var _y0 = dy + y0 * sy;
		var _x1 = dx + x1 * sx;
		var _y1 = dy + y1 * sy;
		
		if(is_undefined(stroke_width) || stroke_width == 1)
			draw_line(_x0, _y0, _x1, _y1);
		else 
			draw_line_width(_x0, _y0, _x1, _y1, stroke_width);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		points = struct_try_get(attr, "points", []);
	}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke) && is_undefined(stroke_width)) 
			return;
		
		var _ox, _oy, _nx, _ny;
		
		for (var i = 0, n = floor(array_length(points) / 2); i < n; i++) {
			_nx = dx + points[i * 2 + 0] * sx;
			_ny = dy + points[i * 2 + 1] * sy;
			
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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
	
	static onSetAttr = function(attr) /*=>*/ {
		points = struct_try_get(attr, "points", []);
	}
	
	static draw = function(dx=0, dy=0, sx=1, sy=1, _ang=0, _col=c_white, _alp=1) {
		if(!is_undefined(stroke)) 			draw_set_color(stroke);
		
		if(is_undefined(stroke) && is_undefined(stroke_width)) 
			return;
		
		var _ox, _oy, _nx, _ny;
		
		for (var i = 0, n = floor(array_length(points) / 2); i < n; i++) {
			_nx = dx + points[i * 2 + 0] * sx;
			_ny = dy + points[i * 2 + 1] * sy;
			
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
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

