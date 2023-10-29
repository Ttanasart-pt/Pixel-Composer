function globalvar_viewer_init() {
	var_editing = false;
	
	var_dragging = noone;
	var_drag_insert = 0;
}

function globalvar_viewer_draw(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry) {
	var hh   = 0;
	var lb_h = line_get_height(f_p0) + ui(8);
	var padd = ui(8);
	
	var _node = PROJECT.globalNode;
	
	if(var_editing) {
		var del = noone;
		if(ds_list_size(_node.inputs)) {
			yy += ui(8);
			hh += ui(8);
		}
		
		var wd_x  = xx;
		var wd_w  = ww;
		
		var _len = ds_list_size(_node.inputs);
		var _ins = var_drag_insert;
		var_drag_insert = _len;
		
		for( var j = 0; j < _len; j++ ) {
			var _inpu = _node.inputs[| j];
			var _edit = _inpu.editor;
			var wd_h  = ui(32);
			
			if(var_dragging != noone) {
				if(_m[1] < yy + wd_h && var_drag_insert == _len) 
					var_drag_insert = j;
				
				if(j == _ins) {
					draw_set_color(COLORS._main_icon);
					draw_line_round(wd_x + ui(8), yy, wd_x + wd_w - ui(16), yy, 4);
				}
				
				if(var_dragging == j)
					continue;
				
				yy += ui(10);
				hh += ui(10);
			} else if(j) {
				draw_set_color(merge_color(c_black, COLORS.panel_toolbar_separator, 0.75));
				draw_line_round(wd_x + ui(8), yy, wd_x + wd_w - ui(16), yy, 4);
						
				yy += ui(10);
				hh += ui(10);
			}
			
			var bx = wd_x + ui(10);
			var by = yy + ui(16);
			if(hover && point_in_rectangle(_m[0], _m[1], bx - ui(12), by - ui(12), bx + ui(12), by + ui(12))) {
				draw_sprite_stretched_ext(THEME.group_label, 0, bx - ui(12), by - ui(12), ui(24), ui(24), COLORS._main_icon_light, 1);
				
				if(mouse_press(mb_left, focus)) {
					var_dragging = j;
				}
			} else 
				draw_sprite_stretched_ext(THEME.group_label, 0, bx - ui(12), by - ui(12), ui(24), ui(24), COLORS._main_icon_light, 0.75);
			
			draw_sprite_ext(THEME.hamburger, 0, bx, by, 0.5, 0.5, 0, COLORS._main_icon_light, 1);
			
			_edit.tb_name.setFocusHover(focus, hover);
			_edit.sc_type.setFocusHover(focus, hover);
			_edit.sc_disp.setFocusHover(focus, hover);
			
			_edit.tb_name.draw(wd_x + ui(32), yy, wd_w - wd_h - ui(32 + 4), wd_h, _inpu.name, _m, TEXTBOX_INPUT.text);
			if(buttonInstant(THEME.button_hide, wd_x + wd_w - wd_h, yy, wd_h, wd_h, _m, focus, hover,, THEME.icon_delete,, COLORS._main_value_negative) == 2) 
				del = j;
			yy += wd_h + ui(8);
			hh += wd_h + ui(8);
						
			_edit.sc_type.draw(wd_x, yy, wd_w / 2 - ui(2), wd_h, _edit.val_type_name[_edit.type_index], _m, rx, ry);
			_edit.sc_disp.draw(wd_x + wd_w / 2 + ui(2), yy, wd_w / 2 - ui(2), wd_h, _edit.sc_disp.data_list[_edit.disp_index], _m, rx, ry);
						
			yy += wd_h + ui(4);
			hh += wd_h + ui(4);
						
			var wd_h = _inpu.editor.draw(wd_x, yy, wd_w, _m, focus, hover);
						
			yy += wd_h + ui(4);
			hh += wd_h + ui(4);
		}
		
		if(var_dragging != noone) {
			if(var_drag_insert == _len) {
				draw_set_color(COLORS._main_icon);
				draw_line_round(wd_x + ui(8), yy, wd_x + wd_w - ui(16), yy, 4);
				
				yy += ui(10);
				hh += ui(10);
			}
			
			if(mouse_release(mb_left)) {
				var _inp = _node.inputs[| var_dragging];
				ds_list_delete(_node.inputs, var_dragging);
				
				if(var_drag_insert > var_dragging) var_drag_insert--;
				ds_list_insert(_node.inputs, var_drag_insert, _inp);
				
				var_dragging = noone;
			}
		}
					
		if(del != noone)
			ds_list_delete(_node.inputs, del);
	} else {
		for( var j = 0; j < ds_list_size(_node.inputs); j++ ) {
			var widg    = drawWidget(xx, yy, ww, _m, _node.inputs[| j], true, focus, hover, _scrollPane, rx, ry);
			var widH    = widg[0];
			var mbRight = widg[1];
						
			if(hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + widH))
				_HOVERING_ELEMENT = _node.inputs[| j];
			
			yy += lb_h + widH + padd;
			hh += lb_h + widH + padd;
		}
	}
	
	return hh;
}