global.__FRAME_LABEL_SCALE = 1;

function Node_Frame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Frame";
	w      = 240;
	h      = 160;
	bg_spr = THEME.node_frame_bg;
	
	size_dragging    = false;
	size_dragging_w  = w;
	size_dragging_h  = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height      = false;
	name_hover       = false;
	hover_progress   = 0;
	
	color  = c_white;
	alpha  = 1;
	scale  = 1;
	lcolor = false;
	
	tb_name	= new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { setDisplayName(txt); });
	tb_name.font   = f_p2;
	tb_name.hide   = true;
	tb_name.align  = fa_center;
	
	name_height  = 18;
	
	draw_x0 = 0;
	draw_y0 = 0;
	draw_x1 = 0;
	draw_y1 = 0;
	
	
	inputs[| 0] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 240, 160 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, cola(c_white) )
		.rejectArray();
	
	inputs[| 2] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.75 )
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Label size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, global.__FRAME_LABEL_SCALE )
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
		
	inputs[| 4] = nodeValue("Blend label", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	input_display_list = [ 0, 1, 3, 4 ];
	
	static onValueUpdate = function(index = 3) { global.__FRAME_LABEL_SCALE = getInputData(3); }
	
	static step = function() {
		previewable = true;
		
		var sz = getInputData(0);
		w = sz[0];
		h = sz[1];
		
		color  = getInputData(1);
		alpha  = _color_get_alpha(color);
		
		scale  = getInputData(3);
		lcolor = getInputData(4);
	}
	
	static drawNodeBase = function(xx, yy, _s, _panel) {
		var px0 =  3;
		var py0 =  3;
		var px1 = -3 + _panel.w;
		var py1 = -0 + _panel.h - _panel.toolbar_height;
		
		var _yy = yy - name_height;
		
		var x0 =  xx;
		var y0 = _yy;
		var x1 =  xx + w * _s;
		var y1 = _yy + name_height + h * _s;
		
		draw_x0 = max(x0, px0);
		draw_x1 = min(x1, px1);
		draw_y0 = max(y0, py0);
		draw_y1 = min(y1, py1);
		
		var _h  = max(draw_y1 - draw_y0, name_height);
		
		if(y0 > 0)	draw_y1 = draw_y0 + _h;
		else		draw_y0 = draw_y1 - _h;
		
		if(draw_x1 - draw_x0 < 4) return;
		
		draw_sprite_stretched_ext(bg_spr, 0, x0, y0, x1 - x0, y1 - y0, color, alpha);
	}
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, _dparam, _panel) {
		
		if(draw_x1 - draw_x0 < 4) return;
		
		var _w  = draw_x1 - draw_x0;
		var _h  = draw_y1 - draw_y0;
		var txt = renamed? display_name : name;
		
		draw_sprite_stretched_ext(bg_spr, 1, draw_x0, draw_y0, _w, _h, color, alpha * .50);
		
		if(WIDGET_CURRENT == tb_name) {
			var nh = 24;
			draw_sprite_stretched_ext(bg_spr, 2, draw_x0, draw_y0, _w, nh, color, alpha * .75);
			
			tb_name.setFocusHover(PANEL_GRAPH.pFOCUS, PANEL_GRAPH.pHOVER);
			tb_name.draw(draw_x0, draw_y0, _w, nh, txt, [ _mx, _my ]);
			
		} else {
			draw_sprite_stretched_ext(bg_spr, 2, draw_x0, draw_y0, _w, name_height, color, alpha * .75);
			
			draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text);
			draw_text_cut((draw_x0 + draw_x1) / 2, draw_y0 + name_height + 1, txt, _w - 4);
			// draw_text_ext_add((draw_x0 + draw_x1) / 2, draw_y0 + name_height + 1, txt, -1, _w - 4);
			// name_height = max(18, string_height_ext(txt, -1, _w - 4));
			
			if(point_in_rectangle(_mx, _my, draw_x0, draw_y0, draw_x0 + _w, draw_y0 + name_height)) {
				if(PANEL_GRAPH.pFOCUS && DOUBLE_CLICK)
					tb_name.activate(txt);
			}
		}
		
		draw_sprite_stretched_add(bg_spr, 1, draw_x0, draw_y0, _w, _h, c_white, .20);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_spr, 1, draw_x0, draw_y0, _w, _h, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		drawBadge(_x, _y, _s);
	}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, _dparam, _panel) {
		
		if(size_dragging) {
			w = size_dragging_w + (mouse_mx - size_dragging_mx) / _s;
			h = size_dragging_h + (mouse_my - size_dragging_my) / _s;
			
			if(!key_mod_press(CTRL)) {
				w = value_snap(w, 16);
				h = value_snap(h, 16);
			}
			
			if(mouse_release(mb_left)) {
				size_dragging = false;
				inputs[| 0].setValue([ w, h ]);
			}
		}
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		drawNodeBase(xx, yy, _s, _panel);
		
		var x1  = xx + w * _s;
		var y1  = yy + h * _s;
		var x0  = x1 - 16;
		var y0  = y1 - 16;
		var ics = 0.5;
		var shf = 8 + 8 * ics;
		
		if(w * _s < 32 || h * _s < 32) return point_in_rectangle(_mx, _my, xx, yy, x1, y1);
		
		if(point_in_rectangle(_mx, _my, xx, yy, x1, y1) || size_dragging)
			draw_sprite_ext_add(THEME.node_resize, 0, x1 - shf, y1 - shf, ics, ics, 0, c_white, 0.15);
		
		if(!name_hover && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			draw_sprite_ext_add(THEME.node_resize, 0, x1 - shf, y1 - shf, ics, ics, 0, c_white, 0.30);
			PANEL_GRAPH.drag_locking = true;
			
			if(mouse_press(mb_left)) {
				size_dragging	 = true;
				size_dragging_w  = w;
				size_dragging_h  = h;
				size_dragging_mx = mouse_mx;
				size_dragging_my = mouse_my;
			}
		}
		
		return point_in_rectangle(_mx, _my, xx, yy, x1, y1);
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var y0 = yy - name_height;
		
		var hover  = point_in_rectangle(_mx, _my, xx, y0, xx + w * _s, yy);
		name_hover = hover;
		
		return hover;
	}
}