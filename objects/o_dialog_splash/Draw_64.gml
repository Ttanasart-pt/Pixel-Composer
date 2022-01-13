/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region content
	draw_sprite(icon_64, 0, dialog_x + 56, dialog_y + 56);
	draw_set_text(f_h5, fa_left, fa_bottom, c_ui_orange);
	draw_text(dialog_x + 56 + 40, dialog_y + 70, "Pixel Composer");
	
	var bx = dialog_x + 256;
	var by = dialog_y + 40;
	var txt = "v. " + VERSION_STRING;
	draw_set_text(f_p0, fa_center, fa_center, c_ui_blue_grey);
	var ww = string_width(txt) + 16;
	if(buttonInstant(s_button_hide, bx, by, ww, 36, [mouse_mx, mouse_my], FOCUS == self, HOVER == self) == 2) {
		dialogCall(o_dialog_release_note, WIN_W / 2, WIN_H / 2);
	}
	draw_text(bx + ww / 2, by + 18, txt);
	
	var bx = dialog_x + dialog_w - 16 - 36;
	var by = dialog_y + 16;
	if(buttonInstant(s_button_hide, bx, by, 36, 36, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "", s_gear_24) == 2) {
		dialogCall(o_dialog_preference, WIN_W / 2, WIN_H / 2);
	}
	
	var x0 = dialog_x + 16;
	var x1 = x0 + 288;
	var y0 = dialog_y + 128;
	var y1 = dialog_y + dialog_h - 16;
	
	draw_set_text(f_p0, fa_left, fa_bottom, c_ui_blue_grey);
	draw_text(x0, y0 - 4, "Recent files");
	draw_sprite_stretched(s_ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	sp_recent.active = FOCUS == self;
	sp_recent.draw(x0 + 6, y0);
	
	x0 = x1 + 16;
	x1 = dialog_x + dialog_w - 16;
	
	draw_set_text(f_p0, fa_left, fa_bottom, c_ui_blue_grey);
	draw_text(x0, y0 - 4, "Sample projects");
	draw_sprite_stretched(s_ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	sp_sample.active = FOCUS == self;
	sp_sample.draw(x0 + 6, y0);
	
	draw_set_text(f_p1, fa_right, fa_bottom, c_ui_blue_grey);
	draw_text(x1 - 75 - 8, y0 - 4, "Art by ");
	draw_sprite_ext(s_kenney, 0, x1, y0 - 4, 1, 1, 0, c_white, 0.5);
#endregion