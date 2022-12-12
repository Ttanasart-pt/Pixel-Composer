function Node_create_Frame(_x, _y) {
	var node = new Node_Frame(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Frame(_x, _y) : Node(_x, _y) constructor {
	name = "Empty frame";
	w = 240;
	h = 160;
	bg_spr		= THEME.node_frame_bg;
	
	size_dragging = false;
	size_dragging_w = w;
	size_dragging_h = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover = false;
	
	inputs[| 0] = nodeValue(0, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 240, 160 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
		
	
	static step = function() {
		var si = inputs[| 0].getValue();
		w = si[0];
		h = si[1];
		
		color  = inputs[| 1].getValue();
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, color, 0.75);
		draw_set_text(f_h5, fa_right, fa_bottom, COLORS._main_text);
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
		var x0 = xx + w * _s - 16 * _s;
		var y0 = yy + h * _s - 16 * _s;
		draw_sprite_ext(THEME.node_resize, 0, x1 - 4 * _s, y1 - 4 * _s, 1, 1, 0, c_white, 0.5);
		if(!name_hover && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			draw_sprite_ext(THEME.node_resize, 0, x1 - 4 * _s, y1 - 4 * _s, 1, 1, 0, c_white, 1);
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
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x + w * _s;
		var yy = y * _s + _y + h * _s;
		draw_set_font(f_h5);
		var ww = (string_width(name) + 16) / _s;
		var hh = (string_height(name) + 16) / _s;
		
		var _x0 = xx - ww;
		var _y0 = yy - hh;
		
		var hover = point_in_rectangle(_mx, _my, _x0, _y0, xx, yy) && !point_in_rectangle(_mx, _my, xx - 16 * _s, yy - 16 * _s, xx, yy);
		name_hover = hover;
		//print(string(_my) + ", " + string(_y0));
		
		return hover;
	}
}