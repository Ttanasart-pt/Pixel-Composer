function curveBox(_onModify) : widget() constructor {
	always_break_line  = true;
	h = ui(200);
	
	onModify    = _onModify;
	curr_data   = [];
	anc_mirror  = [];
	linear_mode = false;
	
	curve_surface   = noone;
	node_dragging   = -1;
	node_drag_typ   = -1;
	node_drag_break = false;
	
	height_drag     = false;
	height_my       = 0;
	height_ss       = 0;
	show_coord      = false;
	show_coord_side = 0;
	
	minx = 0; maxx = 1; irangex = 1;
	miny = 0; maxy = 1; irangey = 1;
	
	dragging       = 0;
	drag_m         = 0;
	drag_s         = 0;
	drag_h         = 0;
	progress_draw  = -1;
	
	display_pos_x  = 0;
	display_pos_y  = 0;
	display_sel    = 0;
	
	grid_snap      = false;
	grid_step      = 0.10;
	grid_show      = true;
	
	scale_control  = true;
	control_zoom   = 64;
	
	selecting      = noone;
	select_type    = 0;
	
	display_val    = 0;
	display_min    = 0;
	display_max    = 1;
	
	curve_y_min    = 0;
	curve_y_max    = 0;
	
	range_display_data = {};
	show_x_control     = false;
	
	cw = 0;
	ch = 0;
	
	tb_shift = textBox_Number(function(v) /*=>*/ { var _data = array_clone(curr_data); _data[0] = v; onModify(_data); }).setLabel("Shift");
	tb_scale = textBox_Number(function(v) /*=>*/ { var _data = array_clone(curr_data); _data[1] = v; onModify(_data); }).setLabel("Scale");
	tb_range = new rangeBox(function(v,i) /*=>*/ { var _data = array_clone(curr_data); _data[3+i] = v; onModify(_data); }).setFont(f_p3);
	
	static get_x = function(v) /*=>*/ {return cw * (    (v - minx) * irangex)};
	static get_y = function(v) /*=>*/ {return ch * (1 - (v - miny) * irangey)};
	
	static replaceCurve = function(_c) {
		var _crv = array_create(array_length(_c));
		
		for( var i = 0, n = array_length(_c); i < n; i++ ) 
			_crv[i] = i < CURVE_PADD? curr_data[i] : _c[i];
		
		onModify(_crv);
	}
	
	static setInteract = function(i = noone) {
		interactable = i;
		tb_range.setInteract(i);
		tb_shift.setInteract(i);
		tb_scale.setInteract(i);
	}
	
	static register = function(p = noone) {
		parent = p;
		tb_range.register(p);
		tb_shift.register(p);
		tb_scale.register(p);
	}
	
	static isHovering = function() { 
		return hovering              || 
		       tb_range.isHovering() || 
		       tb_shift.isHovering() || 
		       tb_scale.isHovering();
	}
	
	static fetchHeight = function(params) { return h; }
	static drawParam   = function(params) {
		rx = params.rx;
		ry = params.ry;
		
		tb_range.setParam(params);
		tb_shift.setParam(params);
		tb_scale.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		     x = _x; 
		     y = _y;
		     w = _w; 
		var hh =  h - ui(4);
		
		if(!is_array(_data) || array_length(_data) == 0) return 0;
		if(is_array(_data[0])) return 0;
		
		var tbh       = line_get_height(font);
		var _amo      = array_length(_data);
		var points    = (_amo - CURVE_PADD) / 6;
		
		var zoom_size = ui(6);
		var zoom_padd = zoom_size + ui(4);
		
		cw = _w - zoom_padd;
		ch = hh - zoom_padd - (tbh + ui(4)) * (1 + show_x_control);
		
		hovering  = false;
		curr_data = _data;
		
		var _shift = _data[0]; 
		var _scale = _data[1];
		var _type  = _data[2];
		
		var _miny  = _data[3];
		var _maxy  = _data[4];
		
		if(_miny == 0 && _maxy == 0) _maxy = 1;
		
		curve_y_min = _miny;
		curve_y_max = _maxy;
		
		linear_mode = curr_data[CURVE_PADD + 0] == 0 && curr_data[CURVE_PADD + 4] == 0;
		
		display_pos_x = lerp(minx, maxx,     (_m[0] - _x) / cw);
		display_pos_y = lerp(miny, maxy, 1 - (_m[1] - _y) / ch);
		display_sel   = false;
		
		curve_surface = surface_verify(curve_surface, cw, ch);
		
		if(node_dragging != -1) { // editing
			show_coord = true;
			_data = array_clone(_data);
			
			if(node_drag_typ == 0) { //anchor
				
				var _mx = (_m[0] - _x) / cw;
					_mx = clamp(_mx * (maxx - minx) + minx, 0, 1);
						
				var _my = 1 - (_m[1] - _y) / ch;
					_my = clamp(_my * (maxy - miny) + miny, 0, 1);
					
				var node_point = (node_dragging - CURVE_PADD - 2) / 6;
				if(node_point > 0 && node_point < points - 1) {
					
					if(key_mod_press(CTRL) || grid_snap)
						_mx = value_snap(_mx, grid_step);
					
					var bfx = _data[node_dragging - 6];
					var afx = _data[node_dragging + 6];
					
					if(_mx > bfx && _mx < afx) _data[node_dragging + 0] = _mx;
				}
				
				if(key_mod_press(CTRL) || grid_snap) 
					_my = value_snap(_my, grid_step);
				_data[node_dragging + 1] = _my;
				
				display_pos_x = _data[node_dragging + 0];
				display_pos_y = _data[node_dragging + 1];
				display_sel   = 1;
				
				if(onModify(_data))
					UNDO_HOLDING = true;
					
			} else { //control
			
				var _px = _data[node_dragging + 0];
				var _py = _data[node_dragging + 1];
				
				var _mx = (_m[0] - _x) / cw;
					_mx = clamp(lerp(minx, maxx, _mx), 0, 1);
					
				var _my = 1 - (_m[1] - _y) / ch;
					_my = lerp(miny, maxy, _my);
				
				if(key_mod_press(CTRL) || grid_snap) _mx = value_snap(_mx, grid_step);
				if(key_mod_press(CTRL) || grid_snap) _my = value_snap(_my, grid_step);
					
				if(node_drag_break) {
					if(node_drag_typ == 1) {
						_data[node_dragging + 2] = (_mx - _px) * node_drag_typ;
						_data[node_dragging + 3] = clamp(_my - _py, -1, 1) * node_drag_typ;	
						
					} else {
						_data[node_dragging - 2] = (_px - _mx) * node_drag_typ;
						_data[node_dragging - 1] = clamp(_py - _my, -1, 1) * node_drag_typ;
						
					}
					
				} else {
					_data[node_dragging - 2] = (_px - _mx) * node_drag_typ;
					_data[node_dragging + 2] = (_mx - _px) * node_drag_typ;
					
					_data[node_dragging - 1] = clamp(_py - _my, -1, 1) * node_drag_typ;
					_data[node_dragging + 3] = clamp(_my - _py, -1, 1) * node_drag_typ;
				}
				
				display_pos_x = node_drag_typ? _data[node_dragging - 2] : _data[node_dragging + 2];
				display_pos_y = node_drag_typ? _data[node_dragging - 1] : _data[node_dragging + 3];
				display_sel   = 2;
				
				if(onModify(_data))
					UNDO_HOLDING = true;
			} 
			
			if(mouse_release(mb_left)) {
				node_dragging = -1;
				node_drag_typ = -1;
				
				UNDO_HOLDING = false;
			}
		}
		
		var node_hovering  = -1;
		var node_hover_typ = -1;
		var point_insert   =  1;
		var _x1 = 0;
		var ac, ar;
		
		var msx = _m[0] - _x;
		var msy = _m[1] - _y;
		
		irangex = 1 / (maxx - minx);
		irangey = 1 / (maxy - miny);
		
		var _hover = point_in_rectangle(_m[0], _m[1], _x, _y, _x + w, _y + h);
		if(_hover && is(parent, scrollPane)) parent.scroll_dragable = false;
		right_click_block = !_hover;
		
		#region ==== draw curve ====
			surface_set_target(curve_surface);
				DRAW_CLEAR
				
				if(grid_show) {
					var st = max(grid_step, 0.02);
					
					draw_set_color(COLORS.widget_curve_line);
					for( var i = st; i < 1; i += st ) {
						var y0 = ch * (1 - (i - miny) / (maxy - miny));
						draw_set_alpha(i == .5? .85 : .7);
						draw_line(0, y0, cw, y0);
						
						var x0 = cw * (i - minx) / (maxx - minx);
						draw_set_alpha(i == .5? .85 : .7);
						draw_line(x0, get_y(0), x0, get_y(1));
					}
				}
				
				var y0 = get_y(0);
				var y1 = get_y(1);
				var yc = get_y(-_miny / (_maxy - _miny));
				
				draw_set_alpha(0.9);
					draw_line(0, y0, cw, y0);
					draw_line(0, y1, cw, y1);
					
					if(_miny < 0 && _maxy > 0) {
						draw_set_alpha(0.75);
						draw_line(0, yc, cw, yc);
					}
				draw_set_alpha(1);
				
				if(progress_draw > -1) {
					var _prg = clamp(progress_draw, 0, 1);
					var _px  = get_x(_prg);
					
					draw_set_color_alpha(COLORS.widget_curve_line, .75);
					draw_line(_px, 0, _px, ch);
					draw_set_alpha(1);
				}
				
				if(_shift != 0 || _scale != 1) {
					draw_set_color(merge_color(COLORS._main_icon, COLORS._main_icon_dark, 0.5));
					draw_curve(0, 0, cw, ch, _data, minx, maxx, miny, maxy, _shift, _scale);
				}
				
				draw_set_color(COLORS._main_accent);
				draw_curve(0, 0, cw, ch, _data, minx, maxx, miny, maxy);
				
				var _sca = cw;
				for( var i = 0; i < points; i++ ) {
					var ind = CURVE_PADD + i * 6;
					var _x0 = _data[ind + 2];
					var _y0 = _data[ind + 3];
					
					var bx0 = _x0 + _data[ind + 0];
					var by0 = _y0 + _data[ind + 1];
					var ax0 = _x0 + _data[ind + 4];
					var ay0 = _y0 + _data[ind + 5];
					
					bx0 = get_x(bx0);
					by0 = get_y(by0);
					_x0 = get_x(_x0);
					_y0 = get_y(_y0);
					ax0 = get_x(ax0);
					ay0 = get_y(ay0);
					
					if(_type == 0) {
						if(i > 0) { //draw pre line
							ac = COLORS.widget_curve_line;
							ar = ui(3);
							
							if(hover && point_in_circle(msx, msy, bx0, by0, 10)) {
								ac = COLORS._main_icon_light;
								ar = ui(4);
								
								node_hovering  = ind + 2;
								node_hover_typ = -1;
								
								display_pos_x = _data[ind + 0];
								display_pos_y = _data[ind + 1];
								display_sel   = 2;
							}
							
							draw_set_color(ac);
							draw_set_alpha(.95);
							draw_line(bx0, by0, _x0, _y0);
							draw_set_alpha(1);
							
							draw_circle_prec(bx0, by0, ar, false);
						}
				
						if(i < points - 1) { //draw post line
							ac = COLORS.widget_curve_line;
							ar = ui(3);
							
							if(hover && point_in_circle(msx, msy, ax0, ay0, 10)) {
								ac = COLORS._main_icon_light;
								ar = ui(4);
								
								node_hovering  = ind + 2;
								node_hover_typ = 1;
								
								display_pos_x = _data[ind + 4];
								display_pos_y = _data[ind + 5];
								display_sel   = 2;
							}
							
							draw_set_color(ac);
							draw_set_alpha(.95);
							draw_line(ax0, ay0, _x0, _y0);
							draw_set_alpha(1);
							
							draw_circle_prec(ax0, ay0, ar, false);
						}
					}
					
					ac = COLORS._main_accent;
					ar = ui(4);
					
					if(hover && point_in_circle(msx, msy, _x0, _y0, ui(6))) {
						ac = COLORS._main_accent;
						ar = ui(5);
						
						node_hovering = ind + 2;
						node_hover_typ = 0;
							
						display_pos_x = _data[ind + 2];
						display_pos_y = _data[ind + 3];
						display_sel   = 1;
					}
					
					draw_set_color(ac);	
					draw_circle_prec(_x0, _y0, ar, false);
					
					if(msx >= _x1 && msx <= _x0)
						point_insert = i;
					_x1 = _x0;
				}
				
			surface_reset_target();
		#endregion
		
		#region ==== view controls ====
			var hov = 0;
			var bs  = zoom_size;
			
			////- =Height
			
			var zminy = 0 - 1;
			var zmaxy = 1 + 1;
			
			var byH = ch;
			
			var bx  = _x + w - bs;
			var by  = _y;
			var zy0 = by + bs / 2 + (byH - bs) * (1 - (miny - zminy) / (zmaxy - zminy));
			var zy1 = by + bs / 2 + (byH - bs) * (1 - (maxy - zminy) / (zmaxy - zminy));
				
			if(dragging) {
				var _mdy = (drag_m[1] - _m[1]) / (byH - bs) * 2;
				
				if(dragging == 1 || dragging == 3) {
					miny = clamp(drag_s[0] + _mdy, zminy, min(maxy - 0.1, zmaxy));
					
					if(dragging == 1 && key_mod_press(CTRL))
						maxy = clamp(drag_s[1] - _mdy, max(miny + 0.1, zminy), zmaxy);
				}
				
				if(dragging == 2 || dragging == 3) {
					maxy = clamp(drag_s[1] + _mdy, max(miny + 0.1, zminy), zmaxy);
					
					if(dragging == 2 && key_mod_press(CTRL))
						miny = clamp(drag_s[0] - _mdy, zminy, min(maxy - 0.1, zmaxy));
				}
			} 
			
				 if(point_in_rectangle(_m[0], _m[1], bx, zy0 - bs / 2, bx + bs, zy0 + bs / 2)) hov = 1;
			else if(point_in_rectangle(_m[0], _m[1], bx, zy1 - bs / 2, bx + bs, zy1 + bs / 2)) hov = 2;
			else if(point_in_rectangle(_m[0], _m[1], bx, zy1 - bs / 2, bx + bs, zy0 + bs / 2)) hov = 3;
				
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, by, bs, byH, CDEF.main_black, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, zy1, bs, zy0 - zy1, drag_h == 3? merge_color(CDEF.main_dkgrey, CDEF.main_grey, 0.4) : CDEF.main_dkgrey, 1);
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, zy0 - bs / 2, bs, bs, drag_h == 1? COLORS._main_icon_light : COLORS._main_icon, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, zy1 - bs / 2, bs, bs, drag_h == 2? COLORS._main_icon_light : COLORS._main_icon, 1);
			
			////- =Width
			
			var zminx = 0;
			var zmaxx = 1;
			
			var bxW = _w - zoom_padd;
			var bx  = _x;
			var by  = _y + hh - bs - (tbh + ui(4)) * (1 + show_x_control);
			
			var zx0 = bx + bs / 2 + (bxW - bs) * (minx - zminx) / (zmaxx - zminx);
			var zx1 = bx + bs / 2 + (bxW - bs) * (maxx - zminx) / (zmaxx - zminx);
			
			if(dragging) {
				var _mdx = (_m[0] - drag_m[0]) / (bxW - bs);
				
				if(dragging == 4 || dragging == 6) {
					minx = clamp(drag_s[2] + _mdx, zminx, min(maxx - 0.1, zmaxx));
					
					if(dragging == 4 && key_mod_press(CTRL))
						maxx = clamp(drag_s[3] - _mdx, max(minx + 0.1, zminx), zmaxx);
				}
				
				if(dragging == 5 || dragging == 6) {
					maxx = clamp(drag_s[3] + _mdx, max(minx + 0.1, zminx), zmaxx);
					
					if(dragging == 5 && key_mod_press(CTRL))
						minx = clamp(drag_s[2] - _mdx, zminx, min(maxx - 0.1, zmaxx));
				}
			} 
			
				 if(point_in_rectangle(_m[0], _m[1], zx0 - bs / 2, by, zx0 + bs / 2, by + bs)) hov = 4;
			else if(point_in_rectangle(_m[0], _m[1], zx1 - bs / 2, by, zx1 + bs / 2, by + bs)) hov = 5;
			else if(point_in_rectangle(_m[0], _m[1], zx0 - bs / 2, by, zx1 + bs / 2, by + bs)) hov = 6;
				
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, by, bxW, bs, CDEF.main_black, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, zx0, by, zx1 - zx0, bs, drag_h == 6? merge_color(CDEF.main_dkgrey, CDEF.main_grey, 0.4) : CDEF.main_dkgrey, 1);
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, zx0 - bs / 2, by, bs, bs, drag_h == 4? COLORS._main_icon_light : COLORS._main_icon, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, zx1 - bs / 2, by, bs, bs, drag_h == 5? COLORS._main_icon_light : COLORS._main_icon, 1);
			
			////- =Pan
			
			drag_h = hov;
			
			if(hov) {
				if(DOUBLE_CLICK && active) {
					     if(hov <= 3) { miny = 0; maxy = 1; } 
					else if(hov <= 6) { minx = 0; maxx = 1; }
				}
				
				if(mouse_press(mb_left, active)) {
					dragging = hov;
					drag_m   = [ _m[0], _m[1] ];
					drag_s   = [ miny, maxy, minx, maxx ];
				}
			}
			
			if(dragging == 10) {
				var _mdx = (_m[0] - drag_m[0]) / (bxW - bs);
				var _mdy = (drag_m[1] - _m[1]) / (byH - bs) * 2;
				
				var zw = drag_s[3] - drag_s[2];
				var zh = drag_s[1] - drag_s[0];
				
				var cx = clamp((drag_s[3] + drag_s[2]) / 2 - _mdx, zminx + zw / 2, zmaxx - zw / 2);
				var cy = clamp((drag_s[1] + drag_s[0]) / 2 - _mdy, zminy + zh / 2, zmaxy - zh / 2);
				
				minx = cx - zw / 2;
				maxx = cx + zw / 2;
				
				miny = cy - zh / 2;
				maxy = cy + zh / 2;
			}
					
			if(point_in_rectangle(_m[0], _m[1], _x, _y, _x + cw, _y + ch) && mouse_press(mb_middle, active)) {
				dragging = 10;
				drag_m   = [ _m[0], _m[1] ];
				drag_s   = [ miny, maxy, minx, maxx ];
			}
			
			if(mouse_release(mb_left) || mouse_release(mb_middle))
				dragging = false;
			
			////- =Height drag
			
			var _bhx = _x + _w - bs;
			var _bhy = _y + hh - bs - (tbh + ui(4)) * (1 + show_x_control);
			var _hov = false;
			
			if(point_in_rectangle(_m[0], _m[1], _bhx, _bhy, _bhx + bs, _bhy + bs)) {
				_hov = true;
				if(mouse_press(mb_left, active)) {
					dragging = hov;
					
					height_drag = true;
					height_my   = _m[1];
					height_ss   = h;
				}
				
			}
			draw_sprite_stretched_ext(THEME.box_r2, 0, _bhx, _bhy, bs, bs, _hov? COLORS._main_icon : CDEF.main_dkgrey, 1);
			
			if(height_drag) {
				h = height_ss + _m[1] - height_my;
				h = max(100, h);
				
				if(mouse_release(mb_left))
					height_drag = false;
			}
		#endregion
		
		draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y, cw, ch, COLORS.widget_curve_outline, 1);
		draw_surface(curve_surface, _x, _y);
		
		////- =Interaction
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + cw, _y + ch)) {
			show_coord = true;
			hovering   = true;
			
			if(node_hovering != -1) {
				CURSOR_SPRITE = THEME.cursor_move;
				
				if(node_hover_typ != 0) {
					if(key_mod_press(SHIFT)) 
						CURSOR_SPRITE = THEME.cursor_path_anchor_detach;
					else
						CURSOR_SPRITE = THEME.cursor_path_anchor_unmirror;
				}
			}
			
			if(mouse_press(mb_left, active)) {
				if(node_hovering == -1) {
					var _ind = CURVE_PADD + point_insert * 6;
					var _px =     (_m[0] - _x) / cw;
					var _py = 1 - (_m[1] - _y) / ch;
					
					var _xp = _data[_ind - 6 + 2];
					var _xn = _data[_ind     + 2];
					var _sp = (_xn - _xp) / 4;
					
					array_insert(_data, _ind + 0, linear_mode? 0 : -_sp);
					array_insert(_data, _ind + 1, 0);
					array_insert(_data, _ind + 2, _px);
					array_insert(_data, _ind + 3, _py);
					array_insert(_data, _ind + 4, linear_mode? 0 : _sp);
					array_insert(_data, _ind + 5, 0);
					
					if(onModify(_data))
						UNDO_HOLDING = true;
					
					node_dragging = _ind + 2;
					node_drag_typ = 0;
					
				} else {
					node_dragging = node_hovering;
					node_drag_typ = node_hover_typ;
						
					if(node_hover_typ != 0) {
						var _cax = _data[node_dragging - 2];
						var _cay = _data[node_dragging - 1];
						var _cbx = _data[node_dragging + 2];
						var _cby = _data[node_dragging + 3];
						
						node_drag_break = key_mod_press(SHIFT) || _cax != -_cbx || _cay != -_cby;
					}
				}
				
			}
			
			if(mouse_press(mb_right, active)) {
				var rmx = rx + _m[0];
				var rmy = ry + _m[1];
				
				if(node_hovering == -1 || node_hover_typ != 0) {
					menuCall("widget_curve", [
						menuItemGroup(__txt("Presets"), [ 
							[ [THEME.curve_presets, 0], function() /*=>*/ {return replaceCurve(CURVE_DEF_00)} ],
							[ [THEME.curve_presets, 1], function() /*=>*/ {return replaceCurve(CURVE_DEF_11)} ],
							[ [THEME.curve_presets, 2], function() /*=>*/ {return replaceCurve(CURVE_DEF_01)} ],
							[ [THEME.curve_presets, 3], function() /*=>*/ {return replaceCurve(CURVE_DEF_10)} ],
						]),
						menuItem(__txt("More Preset..."), function(d) /*=>*/ { dialogPanelCall(new Panel_Curve_Presets(d[0], d[1])) } ).setParam([_data, onModify]),
						-1,
						
						menuItemGroup(__txt("Modes"), [ 
							[ [THEME.curve_type, 0], function() /*=>*/ {
								var _dat = variable_clone(curr_data);
								
								_dat[2] = 0;
								for( var i = CURVE_PADD, n = array_length(_dat); i < n; i += 6 ) {
									_dat[i + 0] = -1/3;
									_dat[i + 1] =    0;
									_dat[i + 4] =  1/3;
									_dat[i + 5] =    0;
								}
								onModify(_dat);
							} ],
							[ [THEME.curve_type, 1], function() /*=>*/ {
								var _dat = variable_clone(curr_data);
								
							    _dat[2] = 0;
								for( var i = CURVE_PADD, n = array_length(_dat); i < n; i += 6 ) {
									_dat[i + 0] = 0;
									_dat[i + 1] = 0;
									_dat[i + 4] = 0;
									_dat[i + 5] = 0;
								}
								onModify(_dat);
							} ],
							[ [THEME.curve_type, 2], function() /*=>*/ {
								var _dat = variable_clone(curr_data);
								    _dat[2] = 1;
								onModify(_dat);
							} ],
						]),
						
						-1,
						menuItem(__txt("Reset View"),      function() /*=>*/ { minx = 0; maxx = 1; miny = 0; maxy = 1; } ),
						menuItem(__txt("Show Value"),      function() /*=>*/ { display_val    = !display_val;    }, noone, noone, function() /*=>*/ {return display_val}    ),
						menuItem(__txt("Show X Controls"), function() /*=>*/ { show_x_control = !show_x_control; }, noone, noone, function() /*=>*/ {return show_x_control} ),
						menuItem(__txt("Scale Controls"),  function() /*=>*/ { scale_control  = !scale_control;  }, noone, noone, function() /*=>*/ {return scale_control}  ),
						
						-1,
						menuItem(__txt("Grid"),         function() /*=>*/ { grid_show = !grid_show; }, noone, noone, function() /*=>*/ {return grid_show} ),
						menuItem(__txt("Snap to grid"), function() /*=>*/ { grid_snap = !grid_snap; }, noone, noone, function() /*=>*/ {return grid_snap} ),
						menuItemGroup(__txt("Grid size"), [
							[ "1%",  function() /*=>*/ { grid_step = 0.01; } ],
							[ "5%",  function() /*=>*/ { grid_step = 0.05; } ],
							[ "10%", function() /*=>*/ { grid_step = 0.10; } ],
							[ "25%", function() /*=>*/ { grid_step = 0.25; } ],
						]),
					], rmx, rmy);
					
				} else {
					selecting   = node_hovering;
					select_type = node_hover_typ;
					select_data = _data;
					
					var _pnt  = (selecting - CURVE_PADD - 2) / 6;
					var _menu = [];
					
					array_push(_menu, menuItem(__txt("Reset Controls"), function() /*=>*/ { 
						var _ind = selecting - 2;
						
						select_data[@ _ind + 0] = -1/3;
						select_data[@ _ind + 1] = 0;
						select_data[@ _ind + 4] =  1/3;
						select_data[@ _ind + 5] = 0;
						onModify(select_data);
					}));
					
					array_push(_menu, menuItem(__txt("Break Control Mirror"), function() /*=>*/ { 
						var _ind = selecting - 2;
						
						// select_data[@ _ind + 0] = -1/3;
						select_data[@ _ind + 1] += 0.01;
						// select_data[@ _ind + 4] =  1/3;
						select_data[@ _ind + 5] += 0.01;
						onModify(select_data);
					}));
					
					array_push(_menu, menuItem(__txt("Remove Controls"), function() /*=>*/ { 
						var _ind = selecting - 2;
						
						select_data[@ _ind + 0] = 0;
						select_data[@ _ind + 1] = 0;
						select_data[@ _ind + 4] = 0;
						select_data[@ _ind + 5] = 0;
						onModify(select_data);
					}));
					
					if(_pnt > 0 && _pnt < points - 1)
						array_push(_menu, -1, menuItem(__txt("Delete Anchor"), function() /*=>*/ { 
							array_delete(select_data, selecting - 2, 6); 
							onModify(select_data); 
						}, THEME.cross));
					
					menuCall("widget_curve", _menu, rmx, rmy);
				}
			}
		}
			
		////- =Bottom Bar
		
		if(show_coord) {
			var ttx = undefined, llx = undefined;
			var tty = undefined, lly = undefined;
			
			if(display_val == 0 || display_sel == 2) {
				llx = display_sel == 2? "dx" : "x";
				lly = display_sel == 2? "dy" : "y";

				ttx = $"{string_format(display_pos_x * 100, -1, 2)}%";
				tty = $"{string_format(display_pos_y * 100, -1, 2)}%";
				
			} else if(display_val == 1) {
				var _spx = display_pos_x;
				var _spy = lerp(display_min, display_max, lerp(curve_y_min, curve_y_max, display_pos_y));
				
				llx = "x";
				lly = "y";

				ttx = $"{string_format(_spx * 100, -1, 2)}%";
				tty = $"{string_format(_spy, -1, 2)}";
			}
				
			if(ttx != undefined) {
				var llw = ui(18);
				var ttw = ui(64);
				var tth = ui(16);
				
				var tx1 = show_coord_side == 0? _x + cw - ui(4) : _x + ui(4) + ttw * 2 + ui(3);
				var ty1 = show_coord_side == 0? _y + ch - ui(4) : _y + ui(4) + tth;
				
				var _ttx0 = _x + cw - ui(8) - ttw * 2;
				var _tty0 = _y + ch - ui(8) - tth;
				if(show_coord_side == 0 && point_in_rectangle(_m[0], _m[1], _ttx0, _tty0, _x + cw, _y + ch))
					show_coord_side = 1;
					
				var _ttx1 = _x + ui(8) + ttw * 2;
				var _tty1 = _y + ui(8) + tth;
				if(show_coord_side == 1 && point_in_rectangle(_m[0], _m[1], _x, _y, _ttx1, _tty1))
					show_coord_side = 0;
				
				var tx0 = tx1 - ttw;
				var ty0 = ty1 - tth;
				
				var tc = display_sel? COLORS._main_text : COLORS._main_text_sub;
				if(node_dragging > -1) tc = COLORS._main_accent;
				
				draw_sprite_stretched_ext(THEME.box_r5, 0, tx0, ty0, llw, tth, COLORS._main_icon, 1);
				draw_sprite_stretched_add(THEME.box_r5, 1, tx0, ty0, ttw, tth, COLORS._main_icon, .5);
				
				draw_set_text(f_p4, fa_center, fa_bottom, CDEF.main_mdblack);
				draw_text_add(tx0 + llw / 2, ty1 - ui(2), lly);
				
				draw_set_text(f_p4, fa_right, fa_bottom, tc);
				draw_text_add(tx1 - ui(3), ty1 - ui(2), tty);
				
				tx0 -= ttw + ui(3);
				tx1 -= ttw + ui(3);
				draw_sprite_stretched_ext(THEME.box_r5, 0, tx0, ty0, llw, tth, COLORS._main_icon, 1);
				draw_sprite_stretched_add(THEME.box_r5, 1, tx0, ty0, ttw, tth, COLORS._main_icon, .5);
				
				draw_set_text(f_p4, fa_center, fa_bottom, CDEF.main_mdblack);
				draw_text_add(tx0 + llw / 2, ty1 - ui(2), llx);
				
				draw_set_text(f_p4, fa_right, fa_bottom, tc);
				draw_text_add(tx1 - ui(3), ty1 - ui(2), ttx);
			}
			
			show_coord = false;
		}
		
		var tbx;
		var tby = _y + h;
		var tbw = _w / 2;
		
		if(show_x_control) {
			tby -= tbh;
			tbw = _w / 2;
			
			tb_shift.setFocusHover(active, hover);
			tb_scale.setFocusHover(active, hover);
			
			tb_shift.hide = true;
			tb_scale.hide = true;
				
			if(hide == 0) {
				draw_sprite_stretched_ext(THEME.textbox, 3, _x, tby, _w, tbh, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, tby, _w, tbh, c_white, 0.5 + 0.5 * interactable);	
			}
			
			tb_shift.draw(_x,       tby, tbw, tbh, _data[0], _m);
			tb_scale.draw(_x + tbw, tby, tbw, tbh, _data[1], _m);
			
			tby -= ui(4);
		}
		
		tby -= tbh;
		tbw = _w;
		
		var bb = THEME.button_hide_fill;
		var bs = tbh;
		var bx = _x + _w - bs;
		var by = tby;
		
		if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, hover, active, __txt("Presets"), THEME.preset,,,, ui(6)) == 2)
			dialogPanelCall(new Panel_Curve_Presets(_data, onModify));
		bx -= bs + ui(2); tbw -= bs + ui(2);
		
		bx = _x;
		if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, hover, active, __txt("Flip X"), THEME.flip_h,,,, ui(6)) == 2)
			onModify(curve_flip_h(_data));
		bx += bs + ui(2); tbw -= bs + ui(2);
		
		if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, hover, active, __txt("Flip Y"), THEME.flip_v,,,, ui(6)) == 2) 
			onModify(curve_flip_v(_data));
		bx += bs + ui(2); tbw -= bs + ui(2);
		
		tb_range.setFocusHover(active, hover);
		tb_range.draw(bx, tby, tbw, tbh, [_miny, _maxy], range_display_data, _m);
		tby -= ui(4);
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() /*=>*/ {return new curveBox(onModify)};

	static free = function() { surface_free_safe(curve_surface); }
}