/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS) DIALOG_DRAW_FOCUS
#endregion

#region content
	draw_sprite_ui_uniform(THEME.icon_64, 0, dialog_x + ui(56), dialog_y + ui(56));
	draw_set_text(_f_ico_h5, fa_left, fa_bottom, COLORS._main_text_accent);
	draw_text(dialog_x + ui(56 + 48), dialog_y + ui(56 + 4), "Pixel Composer");
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_sub);
	var bx  = dialog_x + ui(56 + 48);
	var by  = dialog_y + ui(56 + 4);
	var txt = VERSION_STRING;
	var ww  = string_width(txt) + ui(8);
	var hh  = line_get_height(, 4);
	if(buttonInstant(THEME.button_hide_fill, bx - ui(4), by - ui(2), ww, hh, mouse_ui, sFOCUS, sHOVER) == 2)
		dialogCall(o_dialog_release_note, WIN_W / 2, WIN_H / 2);
	
	draw_text(bx, by, txt);
	
	var bs = ui(32);
	var bx = dialog_x + dialog_w - ui(16) - bs;
	var by = dialog_y + ui(16);
	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txt("Preferences"), THEME.gear) == 2) {
		dialogCall(o_dialog_preference, WIN_W / 2, WIN_H / 2);
	}
	
	bx -= bs + ui(4);
	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txt("Show on startup"), THEME.icon_splash_show_on_start, PREFERENCES.show_splash) == 2) {
		PREFERENCES.show_splash = !PREFERENCES.show_splash;
		PREF_SAVE();
	}
	
	var x0 = dialog_x + ui(16);
	var x1 = x0 + recent_width;
	var y0 = dialog_y + ui(128);
	var y1 = dialog_y + dialog_h - ui(16);
	
	draw_set_text(f_p0, fa_left, fa_bottom, COLORS._main_text_sub);
	draw_text(x0, y0 - ui(4), __txt("Recent files"));
	
	sp_recent.setFocusHover(sFOCUS, sHOVER);
	sp_recent.draw(x0 + ui(6), y0);
	draw_sprite_stretched_ext(THEME.ui_panel, 1, x0, y0, x1 - x0, y1 - y0, COLORS.panel_frame);
	
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
	var expand = PREFERENCES.splash_expand_recent;
	
	switch(pages[project_page]) {
		case "Welcome Files" :
		case "Workshop" :
			if(buttonInstant(THEME.button_hide_fill, x1, (y0 + y1) / 2 - ui(32), ui(16), ui(32), mouse_ui, sFOCUS, sHOVER,, THEME.arrow, expand? 2 : 0) == 2) {
				PREFERENCES.splash_expand_recent = !PREFERENCES.splash_expand_recent;
				expandAction = true;
			}
			break;
	}
	
	x0 = x1 + ui(16);
	x1 = dialog_x + dialog_w - ui(16);
	bx = x0;
	
	var tab_cover = noone;
	var th = ui(36) + THEME_VALUE.panel_tab_extend;
	
	for( var i = 0, n = array_length(pages); i < n; i++ ) {
		draw_set_text(f_p0, fa_left, fa_bottom, project_page == i? COLORS._main_text : COLORS._main_text_sub);
		var txt  = pages[i];
		var dtxt = __txt(txt);
		var amo  = 0;
		var tw   = ui(16) + string_width(dtxt);
		
		switch(txt) {
			case "Workshop" :
				amo = ds_list_size(STEAM_PROJECTS);  
				break;
				
			case "Contests" :
			case "News" :
				dtxt = ""; 
				tw   = ui(32 + 8);
				amo  = 0;
				break;
		}
		
		if(amo) tw += ui(8) + string_width(amo) + ui(6);
		
		var _x1 = min(bx + tw, x1);
		var _tabW = _x1 - bx;
		
		if(project_page == i) {
			draw_sprite_stretched_ext(THEME.ui_panel_tab, 1, bx, y0 - ui(32), _tabW, th, COLORS.panel_tab, 1);
			tab_cover = BBOX().fromWH(bx, y0, tw, THEME_VALUE.panel_tab_extend);
			
		} else if(point_in_rectangle(mouse_mx, mouse_my, bx, y0 - ui(32), bx + _tabW, y0)) {
			
			draw_sprite_stretched_ext(THEME.ui_panel_tab, 0, bx, y0 - ui(32), _tabW, th, COLORS.panel_tab_hover, 1);
			draw_sprite_stretched_add(THEME.ui_panel_tab, 0, bx, y0 - ui(32), _tabW, th, COLORS.panel_tab_hover, 0.1);
			
			if(mouse_click(mb_left, sFOCUS)) {
				project_page = i;
				
				if(txt == "Contests" && PREFERENCES.splash_expand_recent) {
					PREFERENCES.splash_expand_recent = false;
					expandAction = true;
				}
			}
		} else
			draw_sprite_stretched_ext(THEME.ui_panel_tab, 0, bx, y0 - ui(32), _tabW, th, COLORS.panel_tab_inactive, 1);
		
		var _btx = bx + ui(8);
		var cc   = COLORS._main_text_sub;
		if(project_page == i) cc = COLORS._main_text;
		
		switch(txt) {
			case "Contests" :
				if(project_page == i) cc = CDEF.yellow;
				
				draw_sprite_ui(THEME.trophy, 0, _btx + ui(12), y0 - ui(14),,,, COLORS._main_icon);
				_btx += ui(32);
				break;
				
			case "News" :
				if(project_page == i) cc = CDEF.cyan;
				
				draw_sprite_ui(THEME.globe, 0, _btx + ui(12), y0 - ui(16),,,, COLORS._main_icon);
				_btx += ui(32);
				break;
		}
		
		draw_set_color(cc);
		draw_text_cut(_btx, y0 - ui(4), dtxt, _tabW - ui(16));
		
		_btx += ui(8) + string_width(dtxt);
		
		if(amo && _x1 + ui(32) < x1) {
			var _btw = string_width(amo) + ui(8);
			var _bth = ui(22);
			var _btc = COLORS._main_icon_light;
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _btx, y0 - ui(26), _btw, _bth, _btc, 1);
			draw_sprite_stretched_add(THEME.ui_panel, 1, _btx, y0 - ui(26), _btw, _bth, _btc, 0.1);
			
			_btx += ui(4);
			draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text(_btx, y0 - ui(6), amo);
		}
		
		bx += _tabW;
	}
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	draw_sprite_stretched_ext(THEME.ui_panel, 1, x0, y0, x1 - x0, y1 - y0, COLORS.panel_frame);
	draw_sprite_bbox(THEME.ui_panel_tab, 3, tab_cover);
	
	switch(pages[project_page]) {
		case "Welcome Files" :
			sp_sample.setFocusHover(sFOCUS, sHOVER);
			sp_sample.draw(x0 + ui(6), y0);
			break;
			
		case "Workshop" : 
			sp_sample.setFocusHover(sFOCUS, sHOVER);
			sp_sample.draw(x0 + ui(6), y0);
			
			var bs = ui(32);
			var bx = x1 - ui(32);
			var by = y0 - ui(36);
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txtx("workshop_open", "Open Steam Workshop"), THEME.steam) == 2)
				steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/");
		
			bx -= bs + ui(4);
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txt("Refresh"), THEME.refresh_icon) == 2)
				steamUCGload();
			break;
			
		case "Contests" : 
			sp_contest.setFocusHover(sFOCUS, sHOVER);
			sp_contest.draw(x0 + ui(6), y0 + 1);
			break;
			
		case "News" : 
			sp_news.setFocusHover(sFOCUS, sHOVER);
			sp_news.draw(x0 + ui(6), y0 + 1);
			break;
	}
	
	if(expandAction) {
		recent_width = PREFERENCES.splash_expand_recent? ui(564) : ui(288);
		resize();
	}
#endregion