/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region content
	draw_sprite_ui_uniform(THEME.icon_64, 0, dialog_x + ui(56), dialog_y + ui(56));
	draw_set_text(f_h5, fa_left, fa_center, COLORS._main_text_accent);
	draw_text(dialog_x + ui(56 + 48), dialog_y + ui(56), "Pixel Composer");
	
	var bx = dialog_x + ui(56 + 48) + string_width("Pixel Composer") + ui(16);
	var by = dialog_y + ui(56);
	var txt = "v. " + VERSION_STRING;
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
	var ww = string_width(txt) + ui(16);
	var hh = line_get_height(, 16);
	if(buttonInstant(THEME.button_hide, bx, by - hh / 2, ww, hh, mouse_ui, sFOCUS, sHOVER) == 2) {
		dialogCall(o_dialog_release_note, WIN_W / 2, WIN_H / 2);
	}
	draw_text(bx + ui(8), by, txt);
	
	var bx = dialog_x + dialog_w - ui(52);
	var by = dialog_y + ui(16);
	if(buttonInstant(THEME.button_hide, bx, by, ui(36), ui(36), mouse_ui, sFOCUS, sHOVER, __txt("Preferences"), THEME.gear) == 2) {
		dialogCall(o_dialog_preference, WIN_W / 2, WIN_H / 2);
	}
	
	bx -= ui(40);
	if(buttonInstant(THEME.button_hide, bx, by, ui(36), ui(36), mouse_ui, sFOCUS, sHOVER, __txt("Show on startup"), THEME.icon_splash_show_on_start, PREF_MAP[? "show_splash"]) == 2) {
		PREF_MAP[? "show_splash"] = !PREF_MAP[? "show_splash"];
		PREF_SAVE();
	}
	
	var x0 = dialog_x + ui(16);
	var x1 = x0 + recent_width;
	var y0 = dialog_y + ui(128);
	var y1 = dialog_y + dialog_h - ui(16);
	
	draw_set_text(f_p0, fa_left, fa_bottom, COLORS._main_text_sub);
	draw_text(x0, y0 - ui(4), __txt("Recent files"));
	draw_sprite_stretched(THEME.ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	sp_recent.setActiveFocus(sFOCUS, sHOVER);
	sp_recent.draw(x0 + ui(6), y0);
	
	var bx  = x1 - ui(28);
	var by  = y0 - ui(28 + 4);
	var txt = __txtx("splash_clear_recent", "Clear recent files");
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, txt, THEME.icon_delete,, COLORS._main_value_negative) == 2) {
		ds_list_clear(RECENT_FILES);
		RECENT_SAVE();
	}
	
	bx -= ui(28 + 4);
	txt = recent_thumbnail? __txtx("splash_hide_thumbnail", "Hide thumbnail") : __txtx("splash_show_thumbnail", "Show thumbnail");
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, txt, THEME.splash_thumbnail, recent_thumbnail) == 2) {
		recent_thumbnail = !recent_thumbnail;
	}
	bx -= ui(28 + 4);
	txt = __txtx("splash_open_autosave", "Open autosave folder");
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, txt, THEME.save_auto, 0) == 2) {
		shellOpenExplorer(DIRECTORY + "autosave");
	}
	
	var expandAction = false;
	var expand = PREF_MAP[? "splash_expand_recent"];
	
	switch(pages[project_page]) {
		case "Sample projects" :
		case "Workshop" :
			if(buttonInstant(THEME.button_hide_fill, x1, (y0 + y1) / 2 - ui(32), ui(16), ui(32), mouse_ui, sFOCUS, sHOVER,, THEME.arrow, expand? 2 : 0) == 2) {
				PREF_MAP[? "splash_expand_recent"] = !PREF_MAP[? "splash_expand_recent"];
				expandAction = true;
			}
			break;
	}
	
	x0 = x1 + ui(16);
	x1 = dialog_x + dialog_w - ui(16);
	
	bx = x0;
	
	for( var i = 0; i < array_length(pages); i++ ) {
		draw_set_text(f_p0, fa_left, fa_bottom, project_page == i? COLORS._main_text : COLORS._main_text_sub);
		var txt  = pages[i];
		var dtxt = __txt(txt);
		var amo  = noone;
		
		switch(txt) {
			case "Sample projects" : amo = ds_list_size(SAMPLE_PROJECTS); break;
			case "Workshop" :		 amo = ds_list_size(STEAM_PROJECTS);  break;
			case "Contests" :		 amo = array_length(contests);		  break;
		}
		
		var tw = ui(16) + string_width(dtxt);
		if(amo) tw += ui(8) + string_width(amo) + ui(8);
		
		if(txt == "Contests") 
			tw += ui(32);
		
		if(project_page == i) 
			draw_sprite_stretched(THEME.ui_panel_bg, 0, bx, y0 - ui(32), tw, ui(40));
		else if(point_in_rectangle(mouse_mx, mouse_my, bx, y0 - ui(32), bx + tw, y0)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, bx, y0 - ui(32), tw, ui(40), c_white, 0.5);
			
			if(mouse_click(mb_left, sFOCUS)) {
				project_page = i;
				
				if(txt == "Contests" && PREF_MAP[? "splash_expand_recent"]) {
					PREF_MAP[? "splash_expand_recent"] = false;
					expandAction = true;
				}
			}
		}
			
		var _btx = bx + ui(8);
		if(txt == "Contests") {
			draw_sprite_ui(THEME.trophy, 0, _btx + ui(16), y0 - ui(14),,,, CDEF.yellow);
			_btx += ui(32);
		}
		
		if(txt == "Contests") draw_set_color(project_page == i? CDEF.yellow : COLORS._main_text_sub );
		draw_text(_btx, y0 - ui(4), dtxt);
		
		_btx += ui(8) + string_width(dtxt);
		
		if(amo) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _btx, y0 - ui(26), string_width(amo) + ui(8), ui(24), COLORS._main_icon, 0.5);
		
			_btx += ui(4);
			
			if(txt == "Contests") draw_set_color(CDEF.yellow);
			else				  draw_set_color(COLORS._main_text_sub);
			draw_text(_btx, y0 - ui(4), amo);
		}
		
		bx += tw;
	}
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	
	switch(pages[project_page]) {
		case "Sample projects" :
			sp_sample.setActiveFocus(sFOCUS, sHOVER);
			sp_sample.draw(x0 + ui(6), y0);
	
			if(!expand) {
				draw_set_text(f_p1, fa_right, fa_bottom, COLORS._main_text_sub);
				draw_text(x1 - ui(82), y0 - ui(4), __txt("Art by") + " ");
				draw_sprite_ui_uniform(s_kenney, 0, x1, y0 - ui(4), 2, c_white, 0.5);
			}
			break;
		case "Workshop" : 
			sp_sample.setActiveFocus(sFOCUS, sHOVER);
			sp_sample.draw(x0 + ui(6), y0);
	
			var bx = x1 - ui(32);
			var by = y0 - ui(32);
		
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), mouse_ui, sFOCUS, sHOVER, __txtx("workshop_open", "Open Steam Workshop"), THEME.steam) == 2)
				steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/");
		
			bx -= ui(36);
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), mouse_ui, sFOCUS, sHOVER, __txt("Refresh"), THEME.refresh) == 2)
				steamUCGload();
			break;
		case "Contests" : 
			sp_contest.setActiveFocus(sFOCUS, sHOVER);
			sp_contest.draw(x0 + ui(6), y0);
			break;
	}
	
	if(expandAction) {
		recent_width = PREF_MAP[? "splash_expand_recent"]? ui(564) : ui(288);
		resize();
	}
#endregion