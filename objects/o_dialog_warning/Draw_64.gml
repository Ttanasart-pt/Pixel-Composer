/// @description init
if !ready exit;

#region base UI
	var aa = 1;
	
	if(anim == -1) {
		if(--life <= 0) {
			life = 300;
			anim = 0;
		}
		
		aa *= 1 - life / 15;
		dialog_y -= UI_SCALE;
		
	} else if(anim == 0) {
		if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h)) {
			aa = 1.25;
		} else if(--life < 0) {
			life = 30;
			anim = 1;
		}
		
	} else {
		if(--life <= 0)
			instance_destroy();
		aa *= life / 30;
		dialog_y -= UI_SCALE;
	}
	
	draw_sprite_stretched_ext(THEME.textbox,        3, dialog_x, dialog_y, dialog_w, dialog_h, color, aa * .75);
	draw_sprite_stretched_ext(THEME.textbox,        0, dialog_x, dialog_y, dialog_w, dialog_h, color, aa * 1);
	draw_sprite_stretched_ext(THEME.textbox_header, 0, dialog_x, dialog_y, ui(32),   dialog_h, color, aa * 1);
#endregion

#region text
	if(icon == noone) icon = THEME.noti_icon_warning;
	draw_sprite_ui(icon, 1, dialog_x + ui(16), dialog_y + dialog_h / 2, 1, 1, 0, c_white, aa);
	
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text, aa);
	draw_text_line(dialog_x + ui(32) + padding, dialog_y + padding, text, -1, dialog_w - padding * 2 - ui(32));
	draw_set_alpha(1);
#endregion