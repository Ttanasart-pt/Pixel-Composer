function Node_Vector2(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name  = "Vector2";
	color = COLORS.node_blend_number;
	
	setDimension(96, 32 + 24 * 2);
	
	inputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 3] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "Coordinate" ]);
	
	outputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	drag_type = 0;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sx   = 0;
	drag_sy   = 0;
	
	wd_dragging = false;
	wd_minx		= -1;
	wd_miny		= -1;
	wd_maxx		=  1;
	wd_maxy		=  1;
	
	wd_panning	= false;
	wd_pan_sx	= 0;
	wd_pan_sy	= 0;
	wd_pan_mx	= 0;
	wd_pan_my	= 0;
	
	coordinate_menu = [
		menuItem(__txt("Reset view"),  function() {
			wd_minx		= -1;
			wd_miny		= -1;
			wd_maxx		=  1;
			wd_maxy		=  1;
		}),
		menuItem(__txt("Focus value"),  function() {
			var _x = inputs[| 0].getValue();
			var _y = inputs[| 1].getValue();
			
			wd_minx		= _x - 1;
			wd_miny		= _y - 1;
			wd_maxx		= _x + 1;
			wd_maxy		= _y + 1;
		}),
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var __ax = getInputData(0);
		var __ay = getInputData(1);
		
		if(is_array(__ax) || is_array(__ay)) return;
						
		var _ax = __ax * _s + _x;
		var _ay = __ay * _s + _y;
		var _val;
		
		draw_sprite_colored(THEME.anchor_selector, 0, _ax, _ay);
						
		if(drag_type) {
			draw_sprite_colored(THEME.anchor_selector, 1, _ax, _ay);
			var _nx = value_snap((drag_sx + (_mx - drag_mx) - _x) / _s, _snx);
			var _ny = value_snap((drag_sy + (_my - drag_my) - _y) / _s, _sny);
			if(key_mod_press(CTRL)) {
				_val[0] = round(_nx);
				_val[1] = round(_ny);
			} else {
				_val[0] = _nx;
				_val[1] = _ny;
			}
			
			var s0 = inputs[| 0].setValue(_val[0]);
			var s1 = inputs[| 1].setValue(_val[1]);
			
			if(s0 || s1)
				UNDO_HOLDING = true;
							
			if(mouse_release(mb_left)) {
				drag_type = 0;
				UNDO_HOLDING = false;
			}
		}
						
		if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
			hover = 1;
			draw_sprite_colored(THEME.anchor_selector, 1, _ax, _ay);
			if(mouse_press(mb_left, active)) {
				drag_type = 1;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax;
				drag_sy   = _ay;
			}
		} 
	} #endregion
	
	static step = function() { #region
		var int  = getInputData(2);
		var disp = getInputData(3);
		
		for( var i = 0; i < 2; i++ ) {
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
			inputs[| i].editWidget.setSlidable(int? 0.1 : 0.01);
		}
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		
		setDimension(96, 80, false);
				
		if(disp == 1 && inputs[| 0].value_from == noone && inputs[| 1].value_from == noone)
			setDimension(160, 160, false);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var vec = [ _data[0], _data[1] ];
		for( var i = 0, n = array_length(vec); i < n; i++ ) 
			vec[i] = _data[2]? round(vec[i]) : vec[i];
			
		return vec;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var disp = getInputData(3);
		var vec  = getSingleValue(0,, true);
		var bbox = drawGetBbox(xx, yy, _s);
		
		var v0 = array_safe_get_fast(vec, 0);
		var v1 = array_safe_get_fast(vec, 1);
		
		if(disp == 0 || inputs[| 0].value_from != noone || inputs[| 1].value_from != noone) {
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			var str	= $"{v0}\n{v1}";
			var ss	= string_scale(str, bbox.w, bbox.h);
			draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
			return;
		}
		
		draggable = _hover && !point_in_rectangle(_mx, _my, bbox.x0, bbox.y0, bbox.x1, bbox.y1);
		
		var line_step = power(5, floor(logn(5, wd_maxx - wd_minx)));
		draw_set_color(color);
		draw_set_alpha(0.2);
		
		var line_min_x = ceil(wd_minx / line_step) * line_step;
		var line_max_x = ceil(wd_maxx / line_step) * line_step;
		for( var i = line_min_x; i < line_max_x; i += line_step ) {
			var zero_x = (i - wd_minx) / (wd_maxx - wd_minx);
			var zero_y = (0 - wd_miny) / (wd_maxy - wd_miny);
			
			draw_set_alpha(i == 0? 0.3 : 0.1);
			draw_line(bbox.x0 + zero_x * bbox.w, bbox.y0, bbox.x0 + zero_x * bbox.w, bbox.y1);
		}
		
		var line_min_y = ceil(wd_miny / line_step) * line_step;
		var line_max_y = ceil(wd_maxy / line_step) * line_step;
		for( var i = line_min_y; i < line_max_y; i += line_step ) {
			var zero_x = (0 - wd_minx) / (wd_maxx - wd_minx);
			var zero_y = (i - wd_miny) / (wd_maxy - wd_miny);
			
			draw_set_alpha(i == 0? 0.3 : 0.1);
			draw_line(bbox.x0, bbox.y1 - zero_y * bbox.h, bbox.x1, bbox.y1 - zero_y * bbox.h);
		}
		
		draw_set_alpha(0.5);
		draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 1);
		draw_set_alpha(1);
		
		var pin_x = (v0 - wd_minx) / (wd_maxx - wd_minx);
		var pin_y = (v1 - wd_miny) / (wd_maxy - wd_miny);
		if(point_in_rectangle(v0, v1, wd_minx, wd_miny, wd_maxx, wd_maxy)) { #region draw pin
			var pin_dx = bbox.x0 + bbox.w * pin_x;
			var pin_dy = bbox.y1 - bbox.h * pin_y;
			draw_sprite_ext(THEME.node_coor_pin, 0, pin_dx, pin_dy, 1, 1, 0, c_white, 1);
		} #endregion
		
		if(wd_dragging) { #region
			var mx = wd_minx + (_mx - bbox.x0) / bbox.w * (wd_maxx - wd_minx);
			var my = wd_maxy - (_my - bbox.y0) / bbox.h * (wd_maxy - wd_miny);
			
			if(key_mod_press(CTRL)) {
				mx = round(mx);
				my = round(my);
			}
			
			var _i0 = inputs[| 0].setValue(mx);
			var _i1 = inputs[| 1].setValue(my);
			if(_i0 || _i1) UNDO_HOLDING = true;
				
			if(mouse_release(mb_left)) {
				wd_dragging  = false;
				UNDO_HOLDING = false;
			}
		#endregion
		} else if(wd_panning) { #region
			draw_set_color(color);
			draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 1);
			
			var rx = wd_maxx - wd_minx;
			var ry = wd_maxy - wd_miny;
			var sx = bbox.w / rx;
			var sy = bbox.h / ry;
			
			wd_minx = (wd_pan_sx - (_mx - wd_pan_mx) / sx);
			wd_miny = (wd_pan_sy + (_my - wd_pan_my) / sy);
			wd_maxx = wd_minx + rx;
			wd_maxy = wd_miny + ry;
				
			if(mouse_release(mb_middle))
				wd_panning   = false;
		#endregion
		}
		
		if(_hover && point_in_rectangle(_mx, _my, bbox.x0, bbox.y0, bbox.x1, bbox.y1)) { #region
			draw_set_color(color);
			draw_rectangle(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 1);
			
			PANEL_GRAPH.graph_draggable = false;
			
			if(mouse_click(mb_left, _focus))
				wd_dragging = true;
			else if(mouse_press(mb_middle, active)) {
				wd_panning	= true;
				wd_pan_sx	= wd_minx;
				wd_pan_sy	= wd_miny;
				wd_pan_mx	= _mx;
				wd_pan_my	= _my;
			} else if(mouse_wheel_down()) {
				var wd_cx = (wd_maxx + wd_minx) / 2;
				var wd_cy = (wd_maxy + wd_miny) / 2;
				var rx    = (wd_maxx - wd_minx) / 2;
				var ry    = (wd_maxy - wd_miny) / 2;
				
				rx = clamp(rx * 1.5, 1, 100);
				ry = clamp(ry * 1.5, 1, 100);
				
				wd_minx = wd_cx - rx;
				wd_miny = wd_cy - ry;
				wd_maxx = wd_cx + rx;
				wd_maxy = wd_cy + ry;
			} else if(mouse_wheel_up()) {
				var wd_cx = (wd_maxx + wd_minx) / 2;
				var wd_cy = (wd_maxy + wd_miny) / 2;
				var rx    = (wd_maxx - wd_minx) / 2;
				var ry    = (wd_maxy - wd_miny) / 2;
				
				rx = clamp(rx / 1.5, 1, 100);
				ry = clamp(ry / 1.5, 1, 100);
				
				wd_minx = wd_cx - rx;
				wd_miny = wd_cy - ry;
				wd_maxx = wd_cx + rx;
				wd_maxy = wd_cy + ry;
			}
			
			if(mouse_press(mb_right, _focus)) {
				menuCall("node_vec2_coordinate",,, coordinate_menu);
			}
		} #endregion
		
		draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
		var str	= $"[{v0}, {v1}]";
		var ss	= min(1, string_scale(str, bbox.w - 16 * _s, bbox.h));
		draw_text_transformed(bbox.xc, bbox.y1 - 4, str, ss, ss, 0);
	} #endregion
} #endregion