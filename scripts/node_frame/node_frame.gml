global.__FRAME_LABEL_SCALE = 1;

function Node_Frame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Frame";
	w = 240;
	h = 160;
	alpha  = 1;
	bg_spr = THEME.node_frame_bg;
	  
	size_dragging    = false;
	size_dragging_w  = w;
	size_dragging_h  = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height    = false;
	name_hover     = false;
	hover_progress = 0;
	
	color = c_white;
	alpha = 1;
	scale = 1;
	label_color = false;
	
	inputs[| 0] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 240, 160 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white )
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
	
	static onValueUpdate = function(index = 3) { #region
		global.__FRAME_LABEL_SCALE = getInputData(3);
	} #endregion
	
	static step = function() { #region
		var si = getInputData(0);
		w = si[0];
		h = si[1];
		
		color = getInputData(1);
		alpha = getInputData(2);
		scale = getInputData(3);
		label_color = getInputData(4);
	} #endregion
	
	static drawNodeBase = function(xx, yy, _s) { #region
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, color, alpha);
		var txt = display_name == ""? name : display_name;
		
		hover_progress = lerp_float(hover_progress, name_hover, 2);
		
		draw_set_text(f_h5, fa_left, fa_top, merge_color(COLORS._main_text, color, label_color));
		draw_set_alpha(clamp(alpha + name_hover * 0.5, 0, 1));
		draw_text_cut(xx + 8 + 16 * hover_progress, yy + 4 * _s, txt, (w - 8) * _s - 24, scale);
		draw_set_alpha(1);
	} #endregion
	
	draw_scale = 1;
	static drawNodeBG = function(_x, _y, _mx, _my, _s) { #region
		draw_scale = _s;
		
		if(size_dragging) {
			w = size_dragging_w + (mouse_mx - size_dragging_mx) / _s;
			h = size_dragging_h + (mouse_my - size_dragging_my) / _s;
			if(!key_mod_press(CTRL)) {
				w = round(w / 32) * 32;
				h = round(h / 32) * 32;
			}
			
			if(mouse_release(mb_left)) {
				size_dragging = false;
				inputs[| 0].setValue([ w, h ]);
			}
		}
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		drawNodeBase(xx, yy, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, x * _s + _x, y * _s + _y, w * _s, h * _s, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		var x1 = xx + w * _s;
		var y1 = yy + h * _s;
		var x0 = x1 - 16;
		var y0 = y1 - 16;
		var ics = 0.5;
		
		if(name_hover) draw_sprite_ext(THEME.node_move, 0, xx + 4, yy + 4 * _s, ics, ics * scale, 0, color, 0.4);
		
		if(point_in_rectangle(_mx, _my, xx, yy, x1, y1) || size_dragging)
			draw_sprite_ext(THEME.node_resize, 0, x1 - 4, y1 - 4, ics, ics, 0, c_white, 0.5);
		
		if(!name_hover && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			draw_sprite_ext(THEME.node_resize, 0, x1 - 4, y1 - 4, ics, ics, 0, c_white, 1);
			PANEL_GRAPH.drag_locking = true;
			
			if(mouse_press(mb_left)) {
				size_dragging	= true;
				size_dragging_w = w;
				size_dragging_h = h;
				size_dragging_mx = mouse_mx;
				size_dragging_my = mouse_my;
			}
		}
		return noone;
	} #endregion
	
	static pointIn = function(_x, _y, _mx, _my, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var txt = display_name == ""? name : display_name;
		draw_set_font(f_h5);
		var ww  = string_width(txt) + 24 + 8;
		var hh  = string_height("l") + 8;
		
		var hover = point_in_rectangle(_mx, _my, xx, yy, xx + ww, yy + hh);
		name_hover = hover;
		
		return hover;
	} #endregion
}