/// @description tooltip filedrop
#region tooltip
	if(TOOLTIP != "") {
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		
		var tw = string_width(TOOLTIP);
		var th = string_height(TOOLTIP);
		
		var mx = min(mouse_mx + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_my + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		draw_text(mx + ui(8), my + ui(8), TOOLTIP);
	}
	TOOLTIP = "";
#endregion