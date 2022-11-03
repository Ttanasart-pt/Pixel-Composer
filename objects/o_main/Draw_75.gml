/// @description tooltip filedrop
#region tooltip
	if(TOOLTIP != "") {
		draw_set_text(f_p0, fa_left, fa_top, c_white);
		
		var mx = mouse_mx + ui(16);
		var my = mouse_my + ui(16);
		
		var tw = string_width(TOOLTIP);
		var th = string_height(TOOLTIP);
		
		if(mouse_mx + tw + ui(16) > WIN_W)
			mx = max(0, mouse_mx - ui(16) - tw);
		if(mouse_my + th + ui(16) > WIN_H)
			my = max(mouse_my - ui(16) - th);
		
		draw_sprite_stretched(s_textbox, 0, mx - ui(8), my - ui(8), tw + ui(16), th + ui(16));
		draw_text(mx, my, TOOLTIP);
	}
	TOOLTIP = "";
#endregion