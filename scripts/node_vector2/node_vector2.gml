function Node_Vector2(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { 
	name  = "Vector2";
	color = COLORS.node_blend_number;
	
	setDimension(96, 32 + 24 * 2);
	
	newInput(0, nodeValue_Float("x", self, 0))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Float("y", self, 0))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Bool("Integer", self, false));
	
	newInput(3, nodeValue_Enum_Scroll("Display", self,  0, [ "Number", "Coordinate" ]));
	
	newInput(4, nodeValue_Bool("Show on global", self, false, "Whether to show overlay gizmo when not selecting any nodes."));
	
	newInput(5, nodeValue_Vec2("Gizmo offset", self, [ 0, 0 ]));
	
	newInput(6, nodeValue_Float("Gizmo scale", self, 1));
	
	newInput(7, nodeValue_Enum_Scroll("Gizmo style", self, 0, [ "Default", "Shapes", "Sprite" ]));
	
	newInput(8, nodeValue_Enum_Scroll("Gizmo shape", self, 0, [ "Rectangle", "Ellipse" ]));
	
	newInput(9, nodeValue_Surface("Gizmo sprite", self, noone));
	
	newInput(10, nodeValue_Vec2("Gizmo size", self, [ 32, 32 ]));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Vector", self, VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("x", self, VALUE_TYPE.float, 0))
		
	newOutput(2, nodeValue_Output("y", self, VALUE_TYPE.float, 0))
		
	input_display_list = [ 0, 1, 2, 
		["Editor", false], 3, 
		["Gizmo",  false], 4, 5, 6, 7, 8, 9, 10, 
	];
	
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
		menuItem(__txt("Reset view"),  function() /*=>*/ { wd_minx = -1; wd_miny = -1; wd_maxx = 1; wd_maxy = 1; }),
		menuItem(__txt("Focus value"), function() /*=>*/ {
			var _x = getInputData(0);
			var _y = getInputData(1);
			
			wd_minx	= _x - 1; wd_miny = _y - 1;
			wd_maxx	= _x + 1; wd_maxy = _y + 1;
		}),
	];
	
	gz_style  = 0;
	gz_shape  = 0;
	gz_sprite = 0;
	gz_pos    = [ 0, 0 ];
	gz_size   = [ 0, 0 ];
	gz_scale  = 1;
	
	gz_dragging = false;
	gz_drag_mx  = 0;
	gz_drag_my  = 0;
	gz_drag_sx  = 0;
	gz_drag_sy  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { 
		PROCESSOR_OVERLAY_CHECK
		if(process_amount > 1) return;
		
		var _hov = false;
		var _gx  = _x + gz_pos[0] * _s;
		var _gy  = _y + gz_pos[1] * _s;
		
		var _ax = _gx + current_data[0] * _s;
		var _ay = _gy + current_data[1] * _s;
		var _vx, _vy;
		var _nx, _ny;
				
		if(gz_dragging) {
			_nx = value_snap(gz_drag_sx + (_mx - gz_drag_mx) / _s, _snx);
			_ny = value_snap(gz_drag_sy + (_my - gz_drag_my) / _s, _sny);
			_vx = key_mod_press(CTRL)? round(_nx) : _nx;
			_vy = key_mod_press(CTRL)? round(_ny) : _ny;
			
			var s0 = inputs[0].setValue(_vx);
			var s1 = inputs[1].setValue(_vy);
			
			if(s0 || s1) UNDO_HOLDING = true;
							
			if(mouse_release(mb_left)) {
				gz_dragging  = false;
				UNDO_HOLDING = false;
			}
		}
		
		if(gz_style == 0) {
			_hov = hover && point_in_circle(_mx, _my, _ax, _ay, ui(8));
			draw_anchor(_hov, _ax, _ay, ui(8));
			
		} else {
			
			var _rx  = _ax;
			var _ry  = _ay;
			var _rw  = gz_size[0] * _s;
			var _rh  = gz_size[1] * _s;
			var _rx0 = _rx - _rw / 2;
			var _ry0 = _ry - _rh / 2;
			var _rx1 = _rx + _rw / 2;
			var _ry1 = _ry + _rh / 2;
			
			_hov = hover && point_in_rectangle(_mx, _my, _rx0, _ry0, _rx1, _ry1);
			
			draw_set_color(_hov || gz_dragging? COLORS._main_accent : COLORS._main_icon);
			draw_set_circle_precision(32);
			
			if(gz_style == 1) {
				switch(gz_shape) {
					case 0 : draw_rectangle(_rx0, _ry0, _rx1, _ry1, true); break;
					case 1 : draw_ellipse(_rx0, _ry0, _rx1, _ry1, true);   break;
				}
				
			} else if(gz_style == 2) 
				if(is_surface(gz_sprite)) draw_surface_stretched_ext(gz_sprite, _rx0, _ry0, _rw, _rh, c_white, 0.5 + 0.5 * _hov);
		}
		
		if(_hov && mouse_press(mb_left, active)) {
			gz_dragging = true;
			gz_drag_mx  = _mx;
			gz_drag_my  = _my;
			gz_drag_sx  = current_data[0];
			gz_drag_sy  = current_data[1];
		}
	} 
	
	static step = function() { 
		var int  = getInputData(2);
		var disp = getInputData(3);
		
		for( var i = 0; i < 2; i++ ) 
			inputs[i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		
		outputs[0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		
		setDimension(96, 80, false);
				
		if(disp == 1 && inputs[0].value_from == noone && inputs[1].value_from == noone)
			setDimension(160, 160, false);
	} 
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) { 
		var _x   = _data[0];
		var _y   = _data[1];
		var _int = _data[2];
		
		isGizmoGlobal = _data[4];
		gz_pos        = _data[5];
		gz_scale      = _data[6];
		gz_style      = _data[7];
		gz_shape      = _data[8];
		gz_sprite     = _data[9];
		gz_size       = _data[10];
		
		inputs[ 8].setVisible(gz_style == 1);
		inputs[ 9].setVisible(gz_style == 2, gz_style == 2);
		inputs[10].setVisible(gz_style != 0);
		
		_outData[0][0] = _int? round(_x) : _x;
		_outData[0][1] = _int? round(_y) : _y;
		
		_outData[1] = _outData[0][0];
		_outData[2] = _outData[0][1];
		
		return _outData;
	} 
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { 
		var disp = getInputData(3);
		var vec  = getSingleValue(0,, true);
		var bbox = drawGetBbox(xx, yy, _s);
		
		var v0 = array_safe_get_fast(vec, 0);
		var v1 = array_safe_get_fast(vec, 1);
		
		if(disp == 0 || inputs[0].value_from != noone || inputs[1].value_from != noone) {
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
		if(point_in_rectangle(v0, v1, wd_minx, wd_miny, wd_maxx, wd_maxy)) { // draw pin
			var pin_dx = bbox.x0 + bbox.w * pin_x;
			var pin_dy = bbox.y1 - bbox.h * pin_y;
			draw_sprite_ext(THEME.node_coor_pin, 0, pin_dx, pin_dy, 1, 1, 0, c_white, 1);
		} 
		
		if(wd_dragging) { 
			var mx = wd_minx + (_mx - bbox.x0) / bbox.w * (wd_maxx - wd_minx);
			var my = wd_maxy - (_my - bbox.y0) / bbox.h * (wd_maxy - wd_miny);
			
			if(key_mod_press(CTRL)) {
				mx = round(mx);
				my = round(my);
			}
			
			var _i0 = inputs[0].setValue(mx);
			var _i1 = inputs[1].setValue(my);
			if(_i0 || _i1) UNDO_HOLDING = true;
				
			if(mouse_release(mb_left)) {
				wd_dragging  = false;
				UNDO_HOLDING = false;
			}
		
		} else if(wd_panning) { 
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
		
		}
		
		if(_hover && point_in_rectangle(_mx, _my, bbox.x0, bbox.y0, bbox.x1, bbox.y1)) { 
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
			
			if(mouse_press(mb_right, _focus))
				menuCall("node_vec2_coordinate", coordinate_menu);
			
		} 
		
		draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
		var str	= $"[{v0}, {v1}]";
		var ss	= min(1, string_scale(str, bbox.w - 16 * _s, bbox.h));
		draw_text_transformed(bbox.xc, bbox.y1 - 4, str, ss, ss, 0);
	} 
} 