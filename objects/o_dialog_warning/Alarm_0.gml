/// @description init
#region size
	draw_set_font(f_p2);
	
	var ww = string_width_ext(warning_text, -1, 1000);
	var hh = string_height_ext(warning_text, -1, ww);
	
	dialog_w = ww + padding * 2 + ui(32);
	dialog_h = hh + padding * 2;
	
	dialog_x = clamp(x, 0, WIN_W - dialog_w);
	dialog_y = clamp(y, 0, WIN_H - dialog_h);
#endregion

event_inherited();

