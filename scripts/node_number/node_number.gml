function Node_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name = "Number";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w				= 96;
	min_h			= 32 + 24 * 1;
	draw_padding	= 4;
	display_output	= 0;
	
	wd_slider = new slider(0, 1, 0.01, function(val) { inputs[| 0].setValue(val); } );
	wd_slider.spr   = THEME.node_slider;
	
	slider_value    = -1;
	slider_surface  = -1;
	slider_dragging = false;
	slider_mx = 0;
	slider_sx = 0;
	slider_m  = 0;
	
	rotator_surface  = -1;
	rotator_dragging = false;
	rotator_s = 0;
	rotator_p = 0;
	rotator_m = 0;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Number", "Slider", "Rotator" ], update_hover: false });
	
	inputs[| 3] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 4] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.01)
	
	inputs[| 5] = nodeValue("Clamp to range", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	outputs[| 0] = nodeValue("Number", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var __ax = getInputData(0);
		if(is_array(__ax)) return;
		
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static step = function() { #region
		var int  = getInputData(1);
		var disp = getInputData(2);
		
		var _h = min_h;
		
		w	  = 96;	
		min_h = 56; 
		
		switch(disp) {
			case 0 : 
				inputs[| 3].setVisible(false);
				inputs[| 4].setVisible(false);
				inputs[| 5].setVisible(false);
				break;
			case 1 : 
				if(inputs[| 0].isLeaf()) {
					w	  = 160;
					min_h = 96;
				}
				inputs[| 3].setVisible(true);
				inputs[| 4].setVisible(true);
				inputs[| 5].setVisible(true);
				break;
			case 2 : 
				if(inputs[| 0].isLeaf()) {
					w	  = 128;
					min_h = 128;		 
				}
				inputs[| 3].setVisible(false);
				inputs[| 4].setVisible(false);
				inputs[| 5].setVisible(false);
				break;
		}
		
		if(_h != min_h) setHeight();
		
		for( var i = 0; i < 1; i++ ) {
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
			inputs[| i].editWidget.setSlidable(int? 0.1 : 0.01);
		}
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _res = _data[1]? round(_data[0]) : _data[0];
		display_output = _res;
		return _res; 
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var val  = getInputData(0);
		var _int = getInputData(1);
		var disp = getInputData(2);
		var rang = getInputData(3);
		var stp  = getInputData(4);
		var cmp  = getInputData(5);
		var _col = getColor();
		
		if(inputs[| 0].value_from != noone || disp == 0) { #region
			draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
			var str	= string(val);
			var ss	= string_scale(str, bbox.w, bbox.h);
			draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
			return;
		} #endregion
		
		switch(disp) {
			case 1 : #region
				draw_set_text(f_h2, fa_center, fa_center, _col);
				draw_text_transformed(bbox.xc, bbox.y0 + 16 * _s, _int? round(val) : val, _s * 0.5, _s * 0.5, 0);
				
				var sl_w = bbox.w - 8 * _s;
				var sl_h = _s * 40;
				
				var sl_x0 = bbox.x0 + 4 * _s;
				var sl_x1 = sl_x0 + sl_w;
				var sl_y0 = (bbox.y0 + (24 * _s) + bbox.y1) / 2 - sl_h / 2;
				var sl_y1 = sl_y0 + sl_h;
				
				var c0   = (draggable && !slider_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
				var c1   = colorMultiply(CDEF.main_dkgrey, _col);
				
				var _minn = rang[0];
				var _maxx = rang[1];
					
				slider_surface = surface_verify(slider_surface, sl_w, sl_h);
				slider_value   = slider_value == -1? val : lerp_float(slider_value, val, 2.5);
				
				surface_set_shader(slider_surface, sh_ui_slider);
					shader_set_color("c0", c0);
					shader_set_color("c1", c1);
					shader_set_dim("dimension", slider_surface);
					shader_set_f("mouseProg", animation_curve_eval(ac_ripple, slider_m));
					shader_set_f("prog", clamp((slider_value - _minn) / (_maxx - _minn), 0.1, 0.9));
					
					draw_sprite_stretched(s_fx_pixel, 0, 0, 0, sl_w, sl_h);
				surface_reset_shader();
				
				draw_surface(slider_surface, sl_x0, sl_y0);
				
				if(slider_dragging) {
					slider_m = lerp_float(slider_m, 1, 4);
					
					var _valM = (_mx - sl_x0) / (sl_x1 - sl_x0);
					var _valL = lerp(_minn, _maxx, _valM);
					    _valL = value_snap(_valL, stp);
					if(cmp) _valL = clamp(_valL, _minn, _maxx);
					
					if(inputs[| 0].setValue(_valL))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						slider_dragging = false;
						UNDO_HOLDING    = false;
					}
				} else 
					slider_m = lerp_float(slider_m, 0, 5);
				
				draggable = true;
				if(_hover && point_in_rectangle(_mx, _my, sl_x0, sl_y0, sl_x1, sl_y1)) {
					if(mouse_press(mb_left, _focus) && is_real(val)) {
						slider_dragging = true;
						slider_mx = _mx;
						slider_sx = val;
					}
					
					draggable = false;
				}
				
				break; #endregion
			case 2 : #region
				var _ss  = min(bbox.w, bbox.h);
				var c0   = (draggable && !rotator_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
				var c1   = colorMultiply(CDEF.main_dkgrey, _col);
				var _dst = point_distance(_mx, _my, bbox.xc, bbox.yc);
				var _x0  = bbox.xc - _ss / 2;
				var _y0  = bbox.yc - _ss / 2;
				
				rotator_surface = surface_verify(rotator_surface, _ss, _ss);
				
				surface_set_shader(rotator_surface, sh_ui_rotator);
					shader_set_color("c0", c0);
					shader_set_color("c1", c1);
					shader_set_f("angle", degtorad(val));
					shader_set_f("mouse", (_mx - _x0) / _ss, (_my - _y0) / _ss);
					shader_set_f("mouseProg", animation_curve_eval(ac_ripple, rotator_m));
					
					draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _ss, _ss);
				surface_reset_shader();
				
				draw_surface(rotator_surface, _x0, _y0);
				
				if(rotator_dragging) {
					rotator_m = lerp_float(rotator_m, 1, 4);
					var dir = point_direction(bbox.xc, bbox.yc, _mx, _my);
					var dx  = angle_difference(dir, rotator_p);
					rotator_p = dir;
					
					if(inputs[| 0].setValue(val + dx))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						rotator_dragging = false;
						UNDO_HOLDING     = false;
					}
				} else 
					rotator_m = lerp_float(rotator_m, 0, 5);
				
				draggable = true;
				if(_hover && point_in_circle(_mx, _my, bbox.xc, bbox.yc, _ss / 2)) {
					if(mouse_press(mb_left, _focus) && is_real(val)) {
						rotator_dragging = true;
						rotator_s = val;
						rotator_p = point_direction(bbox.xc, bbox.yc, _mx, _my);
					}
					
					draggable = false;
				}
				
				draw_set_text(f_h3, fa_center, fa_center, colorMultiply(CDEF.main_white, _col));
				draw_text_transformed(bbox.xc, bbox.yc, _int? round(val) : string_format(val, -1, 2), _s * .5, _s * .5, 0);
				break; #endregion
		}
	} #endregion
} #endregion

function Node_Vector2(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name = "Vector2";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 2;
	draw_padding = 4;
	
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
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
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
		
		var _h = min_h;
		w	  = 96;	
		min_h = 80; 
				
		if(disp == 1 && inputs[| 0].isLeaf() && inputs[| 1].isLeaf()) {
			w	  = 160;
			min_h = 160;
		}
		
		if(min_h != _h) setHeight();
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
		
		var v0 = array_safe_get(vec, 0);
		var v1 = array_safe_get(vec, 1);
		
		if(disp == 0 || inputs[| 0].value_from != noone || inputs[| 1].value_from != noone) {
			draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
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
		
		draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text);
		var str	= $"[{v0}, {v1}]";
		var ss	= min(1, string_scale(str, bbox.w - 16 * _s, bbox.h));
		draw_text_transformed(bbox.xc, bbox.y1 - 4, str, ss, ss, 0);
	} #endregion
} #endregion

function Node_Vector3(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name = "Vector3";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 3;
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 3] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() { #region
		var int = getInputData(3);
		for( var i = 0; i < 3; i++ ) {
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
			inputs[| i].editWidget.setSlidable(int? 0.1 : 0.01);
		}
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var vec = [ _data[0], _data[1], _data[2] ];
		for( var i = 0, n = array_length(vec); i < n; i++ ) 
			vec[i] = _data[3]? round(vec[i]) : vec[i];
			
		return vec; 
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var v0 = array_safe_get(vec, 0);
		var v1 = array_safe_get(vec, 1);
		var v2 = array_safe_get(vec, 2);

		var str	= $"{v0}\n{v1}\n{v2}";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
} #endregion

function Node_Vector4(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name = "Vector4";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 4;
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 3] = nodeValue("w", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 4] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	static step = function() { #region
		var int = getInputData(4);
		for( var i = 0; i < 4; i++ ) {
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
			inputs[| i].editWidget.setSlidable(int? 0.1 : 0.01);
		}
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var vec = [ _data[0], _data[1], _data[2], _data[3] ];
		for( var i = 0, n = array_length(vec); i < n; i++ ) 
			vec[i] = _data[4]? round(vec[i]) : vec[i];
			
		return vec; 
	} #endregion 
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var v0 = array_safe_get(vec, 0);
		var v1 = array_safe_get(vec, 1);
		var v2 = array_safe_get(vec, 2);
		var v3 = array_safe_get(vec, 3);
		
		var str	= $"{v0}\n{v1}\n{v2}\n{v3}";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
} #endregion

function Node_Vector_Split(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name = "Vector Split";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32;
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue("z", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 3] = nodeValue("w", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static step = function() { #region
		if(inputs[| 0].isLeaf()) return;
		var type = VALUE_TYPE.float;
		if(inputs[| 0].value_from.type == VALUE_TYPE.integer)
			type = VALUE_TYPE.integer;
		
		inputs[| 0].setType(type);
		for( var i = 0; i < 4; i++ )
			outputs[| i].setType(type);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		return array_safe_get(_data[0], _output_index);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
		var str = "";
		for( var i = 0; i < 4; i++ )
			if(outputs[| i].visible) str += $"{outputs[| i].getValue()}\n";
		
		str = string_trim(str);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	 = string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
} #endregion