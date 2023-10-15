function Node_Note(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "New Note";
	w = 240;
	h = 160;
	alpha  = 1;
	bg_spr     = THEME.node_note_bg;
	bg_sel_spr = THEME.node_note_selecting;
	
	size_dragging = false;
	size_dragging_w = w;
	size_dragging_h = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover  = false;
	hover_progress = 0;
	
	color	   = c_white;
	text_color = c_black;
	alpha      = 1;
	content    = "";
	attributes.expand = true;
	
	inputs[| 0] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 240, 160 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 1] = nodeValue("BG Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, CDEF.yellow )
		.rejectArray();
	
	inputs[| 2] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Content", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
		.rejectArray();
	
	inputs[| 4] = nodeValue("Text Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black )
		.rejectArray();
	
	input_display_list = [ 3, 0, 4, 1, 2 ];
		
	static move = function(_x, _y, _s) { #region
		if(x == _x && y == _y) return;
		
		var dx = x - _x;
		var dy = y - _y;
		
		x += dx / _s;
		y += dy / _s; 
		
		if(!LOADING) PROJECT.modified = true;
	} #endregion
	
	static step = function() {
		var si = getInputData(0);
		w = si[0];
		h = si[1];
		
		color = getInputData(1);
		alpha = getInputData(2);
		content = getInputData(3);
	}
	
	static drawNodeBase = function(xx, yy) {
		if(!attributes.expand) return false;
		
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w, h, color, alpha);
		hover_progress = lerp_float(hover_progress, name_hover, 2);
		
		draw_set_text(f_p0, fa_left, fa_top, text_color);
		draw_text_ext_add(round(xx + 8), round(yy + 18), content, -1, w - 16);
		
		draw_sprite_ext(THEME.node_note_pin, attributes.expand, xx + 10, yy + 10, 1, 1, 0, color, 1);
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		if(size_dragging) {
			w = max(32, size_dragging_w + (mouse_mx - size_dragging_mx));
			h = max(32, size_dragging_h + (mouse_my - size_dragging_my));
			if(!key_mod_press(CTRL)) {
				w = max(32, round(w / 32) * 32);
				h = max(32, round(h / 32) * 32);
			}
			
			if(mouse_release(mb_left)) {
				size_dragging = false;
				inputs[| 0].setValue([ w, h ]);
			}
		}
		
		var xx = x;
		var yy = y;
		
		var x0 = xx;
		var y0 = yy;
		var x1 = x0 + 16;
		var y1 = y0 + 16;
		
		if(point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			if(!attributes.expand) TOOLTIP = content;
			
			if(mouse_press(mb_left))
				attributes.expand = !attributes.expand;
		}
		
		if(!attributes.expand) {
			draw_sprite_ext(THEME.node_note_pin, attributes.expand, xx + 10, yy + 10, 1, 1, 0, color, 1);
			return false;
		}
		
		drawNodeBase(xx, yy, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, w, h, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		var x1 = xx + w;
		var y1 = yy + h;
		var x0 = x1 - 16;
		var y0 = y1 - 16;
		var cc = merge_color(color, c_black, 0.25);
		
		if(point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			draw_sprite_ext(THEME.node_note_resize, 1, x1, y1, 1, 1, 0, cc, 1);
			PANEL_GRAPH.drag_locking = true;
			
			if(mouse_press(mb_left)) {
				size_dragging	 = true;
				size_dragging_w  = w;
				size_dragging_h  = h;
				size_dragging_mx = mouse_mx;
				size_dragging_my = mouse_my;
			}
		} else draw_sprite_ext(THEME.node_note_resize, 0, x1, y1, 1, 1, 0, cc, 1);
		
		return noone;
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		if(!attributes.expand) return false;
		
		var xx = x;
		var yy = y;
		
		var x1 = xx + w;
		var y1 = yy + h;
		var x0 = x1 - 16;
		var y0 = y1 - 16;
		
		var hover = point_in_rectangle(_mx, _my, xx, yy, xx + w, yy + h) && !point_in_rectangle(_mx, _my, x0, y0, x1, y1);
		name_hover = hover;
		
		return hover;
	}
	
	static drawBadge = function(_x, _y, _s) { #region
		if(!active) return;
		if(!attributes.expand) return false;
		
		var xx = x + w;
		var yy = y;
		
		badgePreview = lerp_float(badgePreview, !!previewing, 2);
		badgeInspect = lerp_float(badgeInspect,   inspecting, 2);
		
		if(badgePreview > 0) {
			draw_sprite_ext(THEME.node_state, 0, xx, yy, badgePreview, badgePreview, 0, c_white, 1);
			xx -= 28 * badgePreview;
		}
		
		if(badgeInspect > 0) {
			draw_sprite_ext(THEME.node_state, 1, xx, yy, badgeInspect, badgeInspect, 0, c_white, 1);
			xx -= 28 * badgeInspect;
		}
		
		if(isTool) {
			draw_sprite_ext(THEME.node_state, 2, xx, yy, 1, 1, 0, c_white, 1);
			xx -= 28 * 2;
		}
		
		inspecting = false;
		previewing = 0;
	} #endregion
}