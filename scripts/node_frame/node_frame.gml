function Node_create_Frame(_x, _y) {
	var node = new Node_Frame(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Frame(_x, _y) : Node(_x, _y) constructor {
	name = "Empty frame";
	w = 240;
	h = 160;
	bg_spr		= s_node_frame_bg;
	bg_sel_spr	= s_node_frame_bg_active;
	
	size_dragging = false;
	size_dragging_w = w;
	size_dragging_h = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover = false;
	
	inputs[| 0] = nodeValue(0, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 240, 160 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	inputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white )
		.setVisible(false);
	
	static step = function() {
		var si = inputs[| 0].getValue();
		w = si[0];
		h = si[1];
		
		color  = inputs[| 1].getValue();
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, color, 0.75);
		draw_set_text(f_h5, fa_right, fa_bottom, c_white);
		draw_set_alpha(name_hover? 0.5 : 0.25);
		draw_text_cut(xx + w * _s - 8, yy + h * _s - 8, name, w * _s);
		draw_set_alpha(1);
	}
	
	draw_scale = 1;
	static drawNode = function(_x, _y, _mx, _my, _s) {
		draw_scale = _s;
		if(group != PANEL_GRAPH.getCurrentContext()) return;
		
		if(size_dragging) {
			w = size_dragging_w + (mouse_mx - size_dragging_mx) / _s;
			h = size_dragging_h + (mouse_my - size_dragging_my) / _s;
			w = round(w / 32) * 32;
			h = round(h / 32) * 32;
			
			if(mouse_check_button_released(mb_left)) {
				size_dragging = false;
				inputs[| 0].setValue([ w, h ]);
			}
		}
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		drawNodeBase(xx, yy, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched(bg_sel_spr, active_draw_index, x * _s + _x, y * _s + _y, w * _s, h * _s);
			active_draw_index = -1;
		}
		
		var _re_x = (x + w - 4) * _s + _x;
		var _re_y = (y + h - 4) * _s + _y;
		draw_sprite_ext(s_node_resize, 0, _re_x, _re_y, 1, 1, 0, c_white, 0.5);
		if(!name_hover && point_in_rectangle(_mx, _my, _re_x - 16 * _s, _re_y - 16 * _s, _re_x + 4 * _s, _re_y + 4 * _s)) {
			draw_sprite_ext(s_node_resize, 0, _re_x, _re_y, 1, 1, 0, c_white, 1);
			PANEL_GRAPH.node_hovering = -1;
			
			if(mouse_check_button_pressed(mb_left)) {
				size_dragging	= true;
				size_dragging_w = w;
				size_dragging_h = h;
				size_dragging_mx = mouse_mx;
				size_dragging_my = mouse_my;
			}
		}
		return noone;
	}
	
	static pointIn = function(_mx, _my) {
		var xx    = x + w;
		var yy    = y + h;
		draw_set_font(f_h5);
		var ww = (string_width(name) + 16) / draw_scale;
		var hh = (string_height(name) + 16) / draw_scale;
		
		var _x0 = max(x + 16, xx - ww);
		var _y0 = max(y + 16, yy - hh);
		
		var hover = point_in_rectangle(_mx, _my, _x0, _y0, xx - 32, yy);
		name_hover = hover;
		
		return hover;
	}
}