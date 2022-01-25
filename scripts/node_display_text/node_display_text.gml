function Node_create_Display_Text(_x, _y) {
	var node = new Node_Display_Text(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Display_Text(_x, _y) : Node(_x, _y) constructor {
	name = "Display text";
	w = 240;
	h = 160;
	min_h = 0;
	bg_spr		= s_node_frame_bg;
	bg_sel_spr	= s_node_frame_bg_active;
	
	size_dragging = false;
	size_dragging_w = w;
	size_dragging_h = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height = false;
	name_hover = false;
	draw_scale = 1;
	
	inputs[| 0] = nodeValue(0, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 1] = nodeValue(1, "Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "Text");
	
	inputs[| 2] = nodeValue(2, "Style", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Header", "Sub header", "Normal"])
	
	inputs[| 3] = nodeValue(3, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.75)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
	
	input_display_list = [1, 
		["Styling", false], 2, 0, 3];
	
	static drawNodeBase = function(xx, yy, _s) {
		var color  = inputs[| 0].getValue();
		var txt = inputs[| 1].getValue();
		if(txt == "") txt = "..."
		var sty = inputs[| 2].getValue();
		var alp = inputs[| 3].getValue();
		var font = f_p1;
		switch(sty) {
			case 0 : font = f_h3; break;
			case 1 : font = f_h5; break;
			case 2 : font = f_p1; break;
		}
		
		draw_set_alpha(alp);
		draw_set_text(font, fa_left, fa_top, color);
		draw_text_transformed(xx + 4, yy + 4, txt, _s, _s, 0);
		draw_set_alpha(1);
		
		draw_scale = _s;
		w = string_width(txt) + 8;
		h = string_height(txt) + 8;
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		if(active_draw_index > -1) {
			draw_sprite_stretched(bg_sel_spr, active_draw_index, xx, yy, w * _s, h * _s);
			active_draw_index = -1;
		}
		
		drawNodeBase(xx, yy, _s);
		return noone;
	}
}