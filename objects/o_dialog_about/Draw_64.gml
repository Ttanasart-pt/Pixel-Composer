/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region about
	var cx = dialog_x + dialog_w / 2;
	
	draw_sprite(icon_64, 0, cx, dialog_y + 56);
	draw_set_text(f_h3, fa_center, fa_top, c_ui_orange);
	draw_text(cx, dialog_y + 96, "Pixel Composer");
	
	draw_set_text(f_p0, fa_center, fa_top, c_ui_blue_ltgrey);
	draw_text(cx, dialog_y + 132, "2021, MakhamDev");
	
	var thank_y = dialog_y + 180;
	
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 24, thank_y - 8, dialog_w - 48, thank_h + 16);
	sc_thank.active = FOCUS == self;
	sc_thank.draw(dialog_x + 32, thank_y);
#endregion