function Panel_History() : PanelContent() constructor {
	title = __txt("History");
	w     = ui(400);
	h     = ui(480);
	w_min = 320;
	h_min = 320;
	auto_pin = true;
	
	hold     = false;
	hovering = -1;
		
	redo_list  = ds_list_create();
	undo_list  = ds_list_create();
	click_hold = noone;
	
	sep_y    = 0;
	sep_y_to = 0;
	
	function refreshList() {
		ds_list_clear(redo_list);
		ds_list_clear(undo_list);
		
		while(!ds_stack_empty(REDO_STACK))
			ds_list_insert(redo_list, 0, ds_stack_pop(REDO_STACK));
	
		for( var i = 0; i < ds_list_size(redo_list); i++ )
			ds_stack_push(REDO_STACK, redo_list[| i]);
	
		while(!ds_stack_empty(UNDO_STACK))
			ds_list_add(undo_list, ds_stack_pop(UNDO_STACK));
	
		for( var i = ds_list_size(undo_list) - 1; i >= 0; i-- )
			ds_stack_push(UNDO_STACK, undo_list[| i]);
		
	}
	refreshList();

	onResize = function() { sc_history.resize(w - padding * 2, h - padding * 2); }
	
	sc_history = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS._main_text, 0);
		
		if((ds_list_size(redo_list) != ds_stack_size(REDO_STACK)) || (ds_list_size(undo_list) != ds_stack_size(UNDO_STACK)))
			refreshList();
		
		draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
		
		var _h = 0, hh;
		var yy = _y + ui(8);
		
		var ww  = sc_history.surface_w;
		var lw  = sc_history.surface_w - ui(32 + 2);
		var spc = ui(4);
		var pad = ui(2);
		var lh  = line_get_height() + spc;
		
		var red = ds_list_size(redo_list);
		var amo = ds_list_size(redo_list) + ds_list_size(undo_list) + 1;
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
			if(i < red)	item = redo_list[| i];
			else		item = undo_list[| i - red - 1];
			
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
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub, .5);
					draw_text_add(ui(32 + 12), _ty, string(array_length(item) - 3) + __txtx("more_actions", " more actions..."));
					draw_set_alpha(1);
					
				} else {
					draw_set_text(f_p3, fa_left, fa_center, i == hovering? COLORS._main_text : COLORS._main_text_sub);
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
			draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text_sub);
			draw_text_transformed(ui(0), sep_y + ui(2 + 8), __txt("Past"), 1, 1, 90);
		}
		
		if(red > 0) {
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_transformed(ui(0), sep_y + ui(2 - 8), __txt("Future"), 1, 1, 90);
		}
		
		if(mouse_release(mb_left)) 
			click_hold = noone;
		hovering = _hover;
		
		if(action > -1) {
			if(action < red) {
				repeat(red - action) REDO();
				
			} else {
				repeat(action - red) UNDO();
				
			}
			hovering = -1;
		}
		
		return _h + ui(64);
	})
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sc_history.setFocusHover(pFOCUS, pHOVER);
		sc_history.draw(px, py, mx - px, my - py);
	}
}