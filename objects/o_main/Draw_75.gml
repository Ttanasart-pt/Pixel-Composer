/// @description tooltip filedrop
#region tooltip
	if(TOOLTIP != "") {
		draw_set_text(f_p0, fa_left, fa_top, c_white);
		var _w = string_width(TOOLTIP);
		
		var mx = mouse_mx + 16;
		var my = mouse_my + 16;
		
		var tw = clamp(_w, 400, WIN_W - mx - 32);
		var th = string_height_ext(TOOLTIP, -1, tw);
		tw = string_width_ext(TOOLTIP, -1, tw);
		
		if(mouse_mx + tw > WIN_W - 32)
			mx = mouse_mx - 16 - tw;
		if(mouse_my + th > WIN_H - 32)
			my = mouse_my - 16 - th;
		
		draw_sprite_stretched(s_textbox, 0, mx - 8, my - 8, tw + 16, th + 16);
		draw_text_ext(mx, my, TOOLTIP, -1, tw);
	}
	TOOLTIP = "";
#endregion

#region file drop
	file_dnd_set_files(file_dnd_pattern, file_dnd_allowfiles, file_dnd_allowdirs, file_dnd_allowmulti);
	file_dnd_filelist = file_dnd_get_files();
	
	file_dnd_set_enabled(true);
	
	if(file_dnd_filelist != "") {
		file_dropping = file_dnd_filelist;
		if(string_pos("\n", file_dropping) == 1) 
			file_dropping = string_replace(file_dropping, "\n", "");
		
		alarm[3] = 2;
		
		file_dnd_set_enabled(false);
		file_dnd_filelist = "";
	}
#endregion