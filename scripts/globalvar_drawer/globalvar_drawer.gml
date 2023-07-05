function globalvar_viewer_init() {
	var_editing = false;
}

function globalvar_viewer_draw(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry) {
	var hh   = 0;
	var lb_h = line_get_height(f_p0) + ui(8);
	var padd = ui(8);
			
	if(var_editing) {
		var del = noone;
		if(ds_list_size(GLOBAL_NODE.inputs)) {
			yy += ui(8);
			hh += ui(8);
		}
		
		var wd_x  = xx;
		var wd_w  = ww;
		
		for( var j = 0; j < ds_list_size(GLOBAL_NODE.inputs); j++ ) {
			var _inpu = GLOBAL_NODE.inputs[| j];
			var _edit = _inpu.editor;
			var wd_h  = ui(32);
						
			if(j) {
				draw_set_color(merge_color(c_black, COLORS.panel_toolbar_separator, 0.75));
				draw_line_round(wd_x + ui(8), yy, wd_x + wd_w - ui(16), yy, 4);
							
				yy += ui(10);
				hh += ui(10);
			}
						
			_edit.tb_name.setFocusHover(focus, hover);
			_edit.sc_type.setFocusHover(focus, hover);
			_edit.sc_disp.setFocusHover(focus, hover);
						
			_edit.tb_name.draw(wd_x, yy, wd_w - wd_h - ui(4), wd_h, _inpu.name, _m, TEXTBOX_INPUT.text);
			if(buttonInstant(THEME.button_hide, wd_x + wd_w - wd_h, yy + ui(2), wd_h, wd_h, _m, focus, hover,, THEME.icon_delete,, COLORS._main_value_negative) == 2) 
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
					
		if(del != noone)
			ds_list_delete(GLOBAL_NODE.inputs, del);
	} else {
		for( var j = 0; j < ds_list_size(GLOBAL_NODE.inputs); j++ ) {
			var widg    = drawWidget(xx, yy, ww, _m, GLOBAL_NODE.inputs[| j], true, focus, hover, _scrollPane, rx, ry);
			var widH    = widg[0];
			var mbRight = widg[1];
						
			if(hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + widH))
				_HOVERING_ELEMENT = GLOBAL_NODE.inputs[| j];
						
			yy += lb_h + widH + padd;
			hh += lb_h + widH + padd;
		}
	}
	
	return hh;
}