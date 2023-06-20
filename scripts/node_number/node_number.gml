function Node_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Number";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 1;
	draw_padding = 4;
	
	wd_slider = new slider(0, 1, 0.01, function(val) { inputs[| 0].setValue(val); } );
	wd_slider.spr   = THEME.node_slider;
	
	wd_rotator = new rotator( function(val) { inputs[| 0].setValue(val); } );
	wd_rotator.spr_bg   = THEME.node_rotator_bg;
	wd_rotator.spr_knob = THEME.node_rotator_knob;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Number", "Slider", "Rotator" ], { update_hover: false });
	
	inputs[| 3] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 4] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.01)
	
	outputs[| 0] = nodeValue("Number", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var __ax = inputs[| 0].getValue();
		if(is_array(__ax)) return;
		
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	function step() {
		var int  = inputs[| 1].getValue();
		var disp = inputs[| 2].getValue();
		
		w	  = 96;	
		min_h = 56; 
				
		switch(disp) {
			case 0 : 
				inputs[| 3].setVisible(false);
				inputs[| 4].setVisible(false);
				break;
			case 1 : 
				if(inputs[| 0].value_from == noone) {
					w	  = 160;
					min_h = 96;			 
				}
				inputs[| 3].setVisible(true);
				inputs[| 4].setVisible(true);
				break;
			case 2 : 
				if(inputs[| 0].value_from == noone) {
					w	  = 128;
					min_h = 128;		 
				}
				inputs[| 3].setVisible(false);
				inputs[| 4].setVisible(false);
				break;
		}
		
		for( var i = 0; i < 1; i++ ) {
			inputs[| i].type  = int? VALUE_TYPE.integer : VALUE_TYPE.float;
			inputs[| i].editWidget.slide_speed = int? 1 : 0.1;
		}
		
		outputs[| 0].type = int? VALUE_TYPE.integer : VALUE_TYPE.float;
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		return _data[1]? round(_data[0]) : _data[0]; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var val  = getSingleValue(0,, true);
		var disp = inputs[| 2].getValue();
		var rang = inputs[| 3].getValue();
		var stp  = inputs[| 4].getValue();
		
		if(inputs[| 0].value_from != noone || disp == 0) {
			draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
			var str	= string(val);
			var ss	= string_scale(str, bbox.w, bbox.h);
			draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
			return;
		}
		
		switch(disp) {
			case 1 : 
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
				var str	= string(getSingleValue(0,, true));
				var ss	= min(1, string_scale(str, bbox.w, 20));
				draw_text_transformed(bbox.xc, bbox.y0 + 20 / 2, str, ss, ss, 0);
				
				var sl_x = bbox.x0 + 12 * _s;
				var sl_y = bbox.y0 + (20 + 8 * _s);
				var sl_w = bbox.w  - 24 * _s;
				var sl_h = bbox.h  - (20 + 8 * _s);
				
				wd_slider.minn		= rang[0];
				wd_slider.maxx		= rang[1];
				wd_slider.step		= stp;
				wd_slider.handle_w  = 24 * _s;
				
				if(sl_h > 8) {
					wd_slider.setActiveFocus(_focus, _hover);
					wd_slider.draw(sl_x, sl_y, sl_w, sl_h, val, [_mx, _my], 0);
					draggable = !wd_slider.dragging;
				}
				break;
			case 2 : 
				wd_rotator.scale = _s;
				wd_rotator.setActiveFocus(_focus, _hover);
				wd_rotator.draw(bbox.xc, bbox.yc - 48 * _s, val, [_mx, _my], false);
				
				draggable = !wd_rotator.dragging;
				break;
		}
	}
}

function Node_Vector2(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
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
	
	inputs[| 4] = nodeValue("Reset to center", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function () { 
			wd_minx		= -1;
			wd_miny		= -1;
			wd_maxx		=  1;
			wd_maxy		=  1;
		}, "To center" ]);
	
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
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var __ax = inputs[| 0].getValue();
		var __ay = inputs[| 1].getValue();
		
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
	}
	
	function step() {
		var int  = inputs[| 2].getValue();
		var disp = inputs[| 3].getValue();
		
		for( var i = 0; i < 2; i++ ) {
			inputs[| i].type  = int? VALUE_TYPE.integer : VALUE_TYPE.float;
			inputs[| i].editWidget.slide_speed = int? 1 : 0.1;
		}
		
		inputs[| 4].setVisible(disp == 1, disp == 1);
		outputs[| 0].type = int? VALUE_TYPE.integer : VALUE_TYPE.float;
		
		w	  = 96;	
		min_h = 80; 
				
		if(disp == 1 && inputs[| 0].value_from == noone && inputs[| 1].value_from == noone) {
			w	  = 160;
			min_h = 160;
		}
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var vec = [ _data[0], _data[1] ];
		for( var i = 0; i < array_length(vec); i++ ) 
			vec[i] = _data[2]? round(vec[i]) : vec[i];
			
		return vec;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var disp = inputs[| 3].getValue();
		var vec  = getSingleValue(0,, true);
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(disp == 0 || inputs[| 0].value_from != noone || inputs[| 1].value_from != noone) {
			draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
			var str	= string(vec[0]) + "\n" + string(vec[1]);
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
		
		var pin_x   = (vec[0] - wd_minx) / (wd_maxx - wd_minx);
		var pin_y   = (vec[1] - wd_miny) / (wd_maxy - wd_miny);
		if(point_in_rectangle(vec[0], vec[1], wd_minx, wd_miny, wd_maxx, wd_maxy)) {
			var pin_dx  = bbox.x0 + bbox.w * pin_x;
			var pin_dy  = bbox.y1 - bbox.h * pin_y;
			draw_sprite_ext(THEME.node_coor_pin, 0, pin_dx, pin_dy, 1, 1, 0, c_white, 1);
		}
		
		if(wd_dragging) {
			var mx = wd_minx + (_mx - bbox.x0) / bbox.w * (wd_maxx - wd_minx);
			var my = wd_maxy - (_my - bbox.y0) / bbox.h * (wd_maxy - wd_miny);
				
			if(key_mod_press(CTRL)) {
				mx = round(mx);
				my = round(my);
			}
				
			inputs[| 0].setValue(mx);
			inputs[| 1].setValue(my);
				
			if(mouse_release(mb_left)) 
				wd_dragging = false;
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
				wd_panning = false;
		}
		
		if(point_in_rectangle(_mx, _my, bbox.x0, bbox.y0, bbox.x1, bbox.y1)) {
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
		}
		
		draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text);
		var str	= "[" + string(vec[0]) + ", " + string(vec[1]) + "]";
		draw_text(bbox.xc, bbox.y1 - 4, str);
	}
}

function Node_Vector3(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
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
	
	function step() {
		var int = inputs[| 3].getValue();
		for( var i = 0; i < 3; i++ ) {
			inputs[| i].type  = int? VALUE_TYPE.integer : VALUE_TYPE.float;
			inputs[| i].editWidget.slide_speed = int? 1 : 0.1;
		}
		
		outputs[| 0].type = int? VALUE_TYPE.integer : VALUE_TYPE.float;
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var vec = [ _data[0], _data[1], _data[2] ];
		for( var i = 0; i < array_length(vec); i++ ) 
			vec[i] = _data[3]? round(vec[i]) : vec[i];
			
		return vec; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var str	= string(vec[0]) + "\n" + string(vec[1]) + "\n" + string(vec[2]);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}

function Node_Vector4(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
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
		
	function step() {
		var int = inputs[| 4].getValue();
		for( var i = 0; i < 4; i++ ) {
			inputs[| i].type  = int? VALUE_TYPE.integer : VALUE_TYPE.float;
			inputs[| i].editWidget.slide_speed = int? 1 : 0.1;
		}
		
		outputs[| 0].type = int? VALUE_TYPE.integer : VALUE_TYPE.float;
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var vec = [ _data[0], _data[1], _data[2], _data[3] ];
		for( var i = 0; i < array_length(vec); i++ ) 
			vec[i] = _data[4]? round(vec[i]) : vec[i];
			
		return vec; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var str	= string(vec[0]) + "\n" + string(vec[1]) + "\n" + string(vec[2]) + "\n" + string(vec[3]);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}

function Node_Vector_Split(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector Split";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 4;
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue("z", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 3] = nodeValue("w", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static step = function() {
		if(inputs[| 0].value_from == noone) return;
		var type = VALUE_TYPE.float;
		if(inputs[| 0].value_from.type == VALUE_TYPE.integer)
			type = VALUE_TYPE.integer;
		
		inputs[| 0].type = type;
		for( var i = 0; i < 4; i++ ) 
			outputs[| i].type = type;
	}
	
	function process_data(_output, _data, _output_index, _array_index = 0) { 
		return array_safe_get(_data[0], _output_index);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h1, fa_center, fa_center, COLORS._main_text);
		var str	= string(outputs[| 0].getValue()) + "\n" + string(outputs[| 1].getValue()) 
			+ "\n" + string(outputs[| 2].getValue()) + "\n" + string(outputs[| 3].getValue());
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}