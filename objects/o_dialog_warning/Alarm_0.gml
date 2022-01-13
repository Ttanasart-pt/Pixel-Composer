/// @description init
#region size
	draw_set_font(f_p0);
	
	var ww = string_width(warning_text);
	var hh = string_height(warning_text);
	
	dialog_w = ww + 48;
	dialog_h = hh + 48;
#endregion

event_inherited();

