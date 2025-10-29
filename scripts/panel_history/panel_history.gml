function Panel_History() : PanelContent() constructor {
	title = __txt("History");
	w     = ui(320);
	h     = ui(480);
	w_min = 320;
	h_min = 320;
	auto_pin = true;
	
	hold     = false;
	hovering = -1;
		
	redo_list  = [];
	undo_list  = [];
	click_hold = noone;
	
	sep_y    = 0;
	sep_y_to = 0;
	
	font = f_p4;
	
	function refreshList() {
		redo_list = ds_stack_to_array(REDO_STACK);
		undo_list = array_reverse(ds_stack_to_array(UNDO_STACK));
	}
	refreshList();

	sc_history = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS._main_text, 0);
		
		if((array_length(redo_list) != ds_stack_size(REDO_STACK)) || (array_length(undo_list) != ds_stack_size(UNDO_STACK)))
			refreshList();
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		
		var _h = 0, hh;
		var yy = _y + ui(8);
		
		var ww  = sc_history.surface_w;
		var lw  = sc_history.surface_w - ui(32 + 2);
		var spc = ui(2);
		var pad = ui(4);
		var lh  = line_get_height() + spc;
		
		var red = array_length(redo_list);
		var amo = array_length(redo_list) + array_length(undo_list) + 1;
		var _hover = -1;
		var action = -1;
		var connect_line_st = 0;
		var connect_line_ed = 0;
		
		draw_set_color(COLORS._main_icon);
		draw_line_round(0, sep_y, sc_history.surface_w, sep_y, 2);
		
		for( var i = 0; i < amo; i++ ) {
			if(i == red) {
				sep_y_to = yy;
				connect_line_st = sep_y;
				
				_h += spc + pad;
				yy += spc + pad;
				continue;
			}
			
			var item;
			if(i < red)	item = redo_list[i];
			else		item = undo_list[i - red - 1];
			
			var itamo   = array_length(item);
			var amoDisp = itamo;
			if(itamo > 3) {
				itamo   = 3;
				amoDisp = 4;
			}
			hh = amoDisp * lh + pad;
			
			BLEND_OVERRIDE
			draw_sprite_stretched_ext(THEME.node_bg, 0, ui(32), yy, lw, hh, COLORS._main_icon, 1);
			BLEND_NORMAL
			
			if(pHOVER && sc_history.hover && point_in_rectangle(_m[0], _m[1], ui(32), yy - spc / 2, ww, yy + hh + spc / 2 - 1)) {
				sc_history.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_bg, 1, ui(32), yy, lw, hh, COLORS._main_icon, 1);
				_hover = i;
				
				if(array_length(item) > itamo) {
					TOOLTIP = "";
					for( var j = 0; j < array_length(item); j++ ) 
						TOOLTIP += (j? "\n" : "") + item[j].toString();
				}
				
				if(mouse_click(mb_left) && click_hold != item) {
					click_hold = item;
					action = i;
				}
			}
			
			var _cc = i == hovering? COLORS._main_accent : COLORS._main_icon_dark;
			var _yc = yy + hh / 2;
			
			if(i == hovering) connect_line_ed = _yc;
			
			for( var j = 0; j < amoDisp; j++ ) {
				var _ty = yy + lh * (j + 0.5);
				if(j == 3) {
					draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub, .5);
					draw_text_add(ui(32 + 12), _ty, string(array_length(item) - 3) + __txtx("more_actions", " more actions..."));
					draw_set_alpha(1);
					
				} else {
					draw_set_text(font, fa_left, fa_center, i == hovering? COLORS._main_text : COLORS._main_text_sub);
					draw_text_add(ui(32 + 12), _ty, item[j].toString());
				}
			}
			
			_h += hh + spc;
			yy += hh + spc;
		}
		
		if(hovering > -1) {
			var _c0x = ui(20);
			var _c0y = connect_line_st;
			var _c1x = ui(20);
			var _c1y = connect_line_ed;
			var _c2x = ui(32) - 1;
			var _c2y = connect_line_ed;
			var _cr  = ui(4);
			
			draw_set_color(COLORS._main_icon);
			draw_line_round(_c0x, _c0y, _c1x, _c1y + _cr * sign(_c0y - _c1y), 1);
			draw_line_round(_c1x + _cr, _c1y, _c2x, _c2y, 1);
			draw_corner(_c1x, _c1y + _cr * sign(_c0y - _c1y), _c1x, _c1y, _c1x + _cr, _c1y, 1, COLORS._main_icon);
		}
		
		sep_y = lerp_float(sep_y, sep_y_to, 2);
		
		if(red < amo - 1) {
			draw_set_text(font, fa_right, fa_top, COLORS._main_text_sub);
			draw_text_transformed(ui(0), sep_y + ui(2 + 8), __txt("Past"), 1, 1, 90);
		}
		
		if(red > 0) {
			draw_set_text(font, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_transformed(ui(0), sep_y + ui(2 - 8), __txt("Future"), 1, 1, 90);
		}
		
		if(mouse_release(mb_left)) 
			click_hold = noone;
		hovering = _hover;
		
		if(action > -1) {
			var _st = abs(red - action);
			
			if(action < red) repeat(_st) REDO();
			else             repeat(_st) UNDO();
			
			hovering = -1;
		}
		
		return _h + ui(64);
	})
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var sp = padding - ui(8);
		var bw = w - sp * 2;
		var bh = ui(24);
		
		var px = padding;
		var py = padding;
		var pw = w - px - padding;
		var ph = h - py - padding - bh - ui(4);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_history.verify(pw, ph);
		sc_history.setFocusHover(pFOCUS, pHOVER);
		sc_history.draw(px, py, mx - px, my - py);
		
		var _bx  = sp;
		var _by  = h - bh - sp;
		var _hov = pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + bw, _by + bh);
		
		draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, _by, bw, bh, _hov? COLORS._main_value_negative : COLORS._main_icon, .3 + _hov * .1);
		draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, bw, bh, _hov? COLORS._main_value_negative : COLORS._main_icon, .6 + _hov * .25);
		draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_negative : COLORS._main_icon);
		draw_text_add(_bx + bw / 2, _by + bh / 2, __txt("Clear History"));
		
		if(mouse_press(mb_left, pFOCUS && _hov)) {
			ds_stack_clear(REDO_STACK);
			ds_stack_clear(UNDO_STACK);
		}
		
	}
}