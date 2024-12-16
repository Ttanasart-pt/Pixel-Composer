/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	
	draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, dialog_x + 3, dialog_y + 3, dialog_w - 6, title_height + 2, COLORS._main_icon_light, 1);
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_cut(dialog_x + ui(10), dialog_y + ui(8), "Patreon connect", dialog_w - ui(32 + 32));
	
	var _bx = dialog_x + dialog_w - ui(28);
	var _by = dialog_y + ui(8);
	var _bs = ui(20);
	
	if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mouse_mx, mouse_my ], sHOVER, sFOCUS, "", THEME.window_exit) == 2) {
		DIALOG_POSTDRAW
		onDestroy();
		instance_destroy();
	}
	
	if(sFOCUS) DIALOG_DRAW_FOCUS
#endregion

#region patreon login
	var cx = dialog_x + dialog_w / 2;
	var yy = dialog_y + title_height + ui(16);
	
	draw_sprite(s_patreon_banner, 0, cx, yy);
	
	var _ty = yy + ui(120);
	
	if(IS_PATREON) {
		var _bw = ui(100);
		var _bh = ui(32);
		var _bx = cx - _bw / 2;
		var _by = dialog_y + dialog_h - ui(16 + 32);
		
		draw_set_text(f_p1, fa_center, fa_center, COLORS._main_value_positive);
		draw_text(cx, _ty, txt);
		
		if(buttonInstant(THEME.button_def, _bx, _by, _bw, _bh, mouse_ui, sHOVER, sFOCUS) == 2) {
			var _path = DIRECTORY + "patreon";
			file_delete(_path);
			IS_PATREON = false;
			
			instance_destroy();
		}
		
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		draw_text(cx, _by + _bh / 2, "Unredeem");
		
	} else {
		draw_set_text(f_p1, fa_center, fa_center, status == 0? COLORS._main_text : COLORS._main_value_negative);
		draw_text(cx, _ty, txt);
		
		var _tw = dialog_w - ui(32);
		var _th = TEXTBOX_HEIGHT + ui(4);
		var _tx = cx - _tw / 2;
		var _ty = dialog_y + dialog_h - ui(16) - _th;
		
		if(page == 0) {
			tb_code.setFocusHover(sFOCUS, sHOVER);
			tb_code.draw(_tx, _ty, _tw, _th, "");
			
		} else if(status == 0) {
			draw_sprite_ext(THEME.loading_s, 0, cx, _ty + _th / 2, 1, 1, current_time, COLORS._main_icon, 1);
		}
	}
#endregion