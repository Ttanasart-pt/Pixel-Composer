/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region content
	var icx = dialog_x + ui(56);
	var icy = dialog_y + ui(56);
	draw_sprite_ui_uniform(THEME.icon_64, 0, icx, icy);
	draw_sprite_ui_uniform(s_title, 0, dialog_x + ui(56 + 48 - 4), dialog_y + ui(56 + 4 - 32), .4 * THEME_SCALE);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_sub);
	var bhf = THEME.button_hide_fill;
	var m   = mouse_ui;
	var foc = sFOCUS;
	var hov = sHOVER;
	
	var bx  = dialog_x + ui(56 + 48);
	var by  = dialog_y + ui(56 + 4);
	var txt = VERSION_STRING;
	var ww  = string_width(txt) + ui(8);
	var hh  = line_get_height(, 4);
	if(buttonInstant(bhf, bx - ui(4), by - ui(2), ww, hh, m, hov, foc) == 2)
		dialogCall(o_dialog_release_note, WIN_W / 2, WIN_H / 2);
	
	draw_text(bx, by, txt);
	
	var bs = ui(32);
	var bx = dialog_x + dialog_w - ui(16) - bs;
	var by = dialog_y + ui(16);
	if(buttonInstant(bhf, bx, by, bs, bs, m, hov, foc, __txt("Preferences"), THEME.gear) == 2)
		dialogPanelCall(new Panel_Preference());
	
	bx -= bs + ui(4);
	if(buttonInstant(bhf, bx, by, bs, bs, m, hov, foc, __txt("Show on startup"), THEME.icon_splash_show_on_start, PREFERENCES.show_splash) == 2) {
		PREFERENCES.show_splash = !PREFERENCES.show_splash;
		PREF_SAVE();
	}
	
	var x0 = dialog_x + ui(16);
	var x1 = x0 + recent_width;
	var y0 = dialog_y + ui(128);
	var y1 = dialog_y + dialog_h - ui(16);
	
	draw_set_text(f_p2, fa_left, fa_bottom, COLORS._main_text_sub);
	draw_text(x0, y0 - ui(4), __txt("Recent files"));
	
	sp_recent.setFocusHover(sFOCUS, sHOVER);
	sp_recent.rx = x0 + ui(6);
	sp_recent.ry = y0;
	sp_recent.draw(x0 + ui(6), y0);
	draw_sprite_stretched_ext(THEME.ui_panel, 1, x0, y0, x1 - x0, y1 - y0, COLORS.panel_frame);
	
	var bs  = ui(28);
	var bx  = x1 - bs;
	var by  = y0 - bs - ui(4);
	var cc  = COLORS._main_value_negative;
	var txt = __txtx("splash_clear_recent", "Clear recent files");
	if(buttonInstant(bhf, bx, by, bs, bs, m, hov, foc, txt, THEME.icon_delete, 0, cc) == 2) {
		ds_list_clear(RECENT_FILES);
		RECENT_SAVE();
	}
	
	bx -= bs + ui(1);
	cc  = crashed? COLORS._main_accent : COLORS._main_icon;
	txt = __txtx("splash_open_autosave", "Open autosave folder");
	if(buttonInstant(bhf, bx, by, bs, bs, m, hov, foc, txt, THEME.save_auto, 0, cc, 1, .75) == 2) {
		shellOpenExplorer(DIRECTORY + "autosave");
	}
	
	if(crashed) {
		draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text);
		
		var crw = string_width(txt) + ui(12);
		var crh = string_height(txt) + ui(8);
		var crc = bx + bs / 2;
		var crx = crc - crw / 2;
		var cry = by - ui(6) - crh + sin(current_time / 250) * 4;
		
		draw_sprite_stretched(THEME.textbox, 3, crx, cry, crw, crh);
		draw_sprite_stretched(THEME.textbox, 0, crx, cry, crw, crh);
		draw_sprite_ui(THEME.textbox_arrow, 0,  crc, cry + crh - 1);
		draw_text_add(crc, cry + crh - ui(4), txt);
	}
	
	bx -= bs + ui(1);
	cc  = COLORS._main_icon;
	txt = __txtx("splash_show_thumbnail", "Toggle thumbnail");
	if(buttonInstant(bhf, bx, by, bs, bs, m, hov, foc, txt, THEME.image_20, PREFERENCES.splash_show_thumbnail, cc, 1, .8) == 2) {
		PREFERENCES.splash_show_thumbnail = !PREFERENCES.splash_show_thumbnail;
		PREF_SAVE();
	}
	
	var expandAction = false;
	var expand = PREFERENCES.splash_expand_recent;
	
	switch(pages[project_page]) {
		case "Welcome Files" :
		case "Workshop" :
			if(buttonInstant(THEME.button_hide_fill, x1, (y0 + y1) / 2 - ui(32), ui(16), ui(32), mouse_ui, sHOVER, sFOCUS,, THEME.arrow, expand? 2 : 0) == 2) {
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
				amo = array_length(STEAM_PROJECTS);  
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
			
			if(mouse_press(mb_left, sFOCUS)) {
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
		var _scis = gpu_get_scissor();
		gpu_set_scissor(bx + ui(8), y0 - ui(32), _tabW - ui(16), ui(32));
		draw_text_add(_btx, y0 - ui(4), dtxt);
		gpu_set_scissor(_scis);
		
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
	
	var bs = ui(32);
	var bx = x1 - ui(32);
	var by = y0 - ui(36);
	
	switch(pages[project_page]) {
		case "Welcome Files" :
			sp_sample.setFocusHover(sFOCUS, sHOVER);
			sp_sample.draw(x0 + ui(6), y0 + 1);
			
			var _txt = __txt("Open Welcome Folder...");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, _txt, THEME.dPath_open) == 2)
				shellOpenExplorer($"{DIRECTORY}Welcome files");
			
			// bx -= bs + ui(4);
			// var _txt = __txt("Edit Welcome Folders");
			// var _bc  = welcome_editing? COLORS._main_value_positive : COLORS._main_icon;
			// if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, _txt, THEME.gear, 0, _bc) == 2)
			// 	welcome_editing = !welcome_editing;
				
			if(STEAM_ENABLED) {
				bx -= bs + ui(4);
				var _txt = __txtx("workshop_open", "Open Steam Workshop");
				if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, _txt, THEME.steam) == 2) {
					dialogPanelCall(new Panel_Steam_Workshop());
					instance_destroy();
				}
			}
			break;
			
		case "Workshop" : 
			sp_sample.setFocusHover(sFOCUS, sHOVER);
			sp_sample.draw(x0 + ui(6), y0 + 1);
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Refresh"), THEME.refresh_icon) == 2)
				steamUCGload();
				
			bx -= bs + ui(4);
			var _txt = __txtx("workshop_open", "Open Steam Workshop");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, _txt, THEME.steam) == 2) {
				dialogPanelCall(new Panel_Steam_Workshop());
				instance_destroy();
			}
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