/// @description init
if !ready exit;
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, WIN_W, WIN_H, false);
draw_set_alpha(1);

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region text
	draw_set_text(f_h5, fa_left, fa_top, c_ui_blue_grey);
	draw_text(dialog_x + 24, dialog_y + 24, "Project modified");
	
	draw_set_text(f_p0, fa_left, fa_top, c_white);
	draw_text(dialog_x + 24, dialog_y + 54, "Save progress before exit?");
	
	var bw = 96, bh = 32;
	var bx1 = dialog_x + dialog_w - 16;
	var by1 = dialog_y + dialog_h - 16;
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	draw_set_text(f_p1, fa_center, fa_center, c_white);
	var b = buttonInstant(s_button, bx0, by0, bw, bh, [mouse_mx, mouse_my], FOCUS == self, HOVER == self);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Cancel");
	if(b == 2) 
		instance_destroy();
	
	bx0 -= bw + 12;
	var b = buttonInstant(s_button, bx0, by0, bw, bh, [mouse_mx, mouse_my], FOCUS == self, HOVER == self);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Don't save");
	if(b == 2) {
		PREF_SAVE();
		game_end();
	}
	
	bx0 -= bw + 12;
	var b = buttonInstant(s_button, bx0, by0, bw, bh, [mouse_mx, mouse_my], FOCUS == self, HOVER == self);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Save");
	if(b == 2) {
		SAVE();
		PREF_SAVE();
		game_end();
	}
#endregion