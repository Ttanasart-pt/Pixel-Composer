/// @description tooltip filedrop
#region tooltip
	if(TOOLTIP != "") {
		draw_set_text(f_p0, fa_left, fa_top, c_white);
		
		var mx = mouse_mx + 16;
		var my = mouse_my + 16;
		
		var tw = string_width(TOOLTIP);
		var th = string_height(TOOLTIP);
		
		if(mouse_mx + tw > WIN_W - 32)
			mx = mouse_mx - 16 - tw;
		if(mouse_my + th > WIN_H - 32)
			my = mouse_my - 16 - th;
		
		draw_sprite_stretched(s_textbox, 0, mx - 8, my - 8, tw + 16, th + 16);
		draw_text(mx, my, TOOLTIP);
	}
	TOOLTIP = "";
#endregion