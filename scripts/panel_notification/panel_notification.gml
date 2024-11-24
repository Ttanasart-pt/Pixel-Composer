#region funtion calls
	function __fnInit_Notification() {
		registerFunction("Notifications", "Clear log messages",			"",   MOD_KEY.none,	notification_clear_all		).setMenu("noti_clear_all");
		registerFunction("Notifications", "Clear warning messages",		"",   MOD_KEY.none,	notification_clear_log		).setMenu("noti_clear_log");
		registerFunction("Notifications", "Clear all notifications",	"",   MOD_KEY.none,	notification_clear_warning	).setMenu("noti_clear_warning");
		
		registerFunction("Notifications", "Open log file",				"",   MOD_KEY.none,	notification_open_log		).setMenu("noti_open_log");
		
	}
	
	function notification_clear_all()		{ CALL("notification_clear_all");     ds_list_clear(STATUSES); }
	function notification_clear_log()		{ CALL("notification_clear_log");     for( var i = ds_list_size(STATUSES) - 1; i >= 0; i-- ) if(STATUSES[| i].type == NOTI_TYPE.log) ds_list_delete(STATUSES, i);     }
	function notification_clear_warning()	{ CALL("notification_clear_warning"); for( var i = ds_list_size(STATUSES) - 1; i >= 0; i-- ) if(STATUSES[| i].type == NOTI_TYPE.warning) ds_list_delete(STATUSES, i); }
	
	function notification_open_log()  		{ CALL("notification_open_log");	  shellOpenExplorer(DIRECTORY + "log/log.txt"); }
	
#endregion

function Panel_Notification() : PanelContent() constructor {
	title   = __txt("Notifications");
	w       = ui(720);
	h       = ui(480);
	padding = 8;
	
	current_page   = 0;
	filter         = NOTI_TYPE.log | NOTI_TYPE.warning | NOTI_TYPE.error;
	noti_selecting = noone;
	
	show_time = false;
	
	rightClickMenu = [ 
		MENU_ITEMS.noti_clear_all,
		MENU_ITEMS.noti_clear_log,
		MENU_ITEMS.noti_clear_warning,
		-1,
		menuItem(__txt("Toggle timestamp"), function() /*=>*/ { show_time = !show_time }, noone, noone, function() /*=>*/ {return show_time}),
		-1,
		MENU_ITEMS.noti_open_log,
	];
	
	function onResize() {
		sp_noti.resize(w - ui(padding + padding), h - ui(padding + padding));
	}
	
	sp_noti = new scrollPane(w - ui(padding + padding), h - ui(padding + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var hh  = ui(8);
		var yy  = _y;
		var txw = sp_noti.surface_w - ui(48);
		if(show_time) txw -= ui(68);
		
		var amo = ds_list_size(STATUSES);
		var pad = THEME_VALUE.panel_notification_padding;
		
		draw_set_font(f_p3);
		var timeW = string_width("00:00:00");
		
		for( var i = 0; i < amo; i++ ) {
			var index = amo - 1 - i;
			var noti = STATUSES[| index];
			
			if(is_undefined(noti))      continue;
			if(noti.type & filter == 0) continue;
			
			draw_set_font(f_p3);
			var _w = sp_noti.surface_w;
			var _h = ui(12) + string_height_ext(noti.txt, -1, txw);
			_h += pad * 2;
			
			if(i) {
				draw_set_color(COLORS._main_icon);
				draw_set_alpha(.15);
				draw_line(ui(16), yy - ui(1), _w - ui(16), yy - ui(1));
				draw_set_alpha(1);
			}
			
			if(yy >= -_h && yy <= sp_noti.h) {
				
				if(pHOVER && pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + _h)) {
					sp_noti.hover_content = true;
					draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, yy, _w, _h, CDEF.main_dkblack, 1);
					
					if(noti.tooltip != "")
						TOOLTIP = noti.tooltip;
				
					if(noti.onClick != noone && mouse_press(mb_left, pFOCUS))
						noti.onClick();
				
					if(mouse_press(mb_right, pFOCUS)) {
						noti_selecting = noti;
						
						var dia = menuCall("notification_menu", [ 
							menuItem(__txtx("noti_copy_message",   "Copy notification message"), function() { clipboard_set_text(noti_selecting.txt);   }), 
							menuItem(__txtx("noti_delete_message", "Delete notification"),       function() { ds_list_remove(STATUSES, noti_selecting); }), 
						]);
						
					}
				}
				
				if(noti.life_max > 0) {
					var _nwx = sp_noti.w - ui(12) - ui(40);
					var _nw  = _nwx * noti.life / noti.life_max;
				
					draw_sprite_stretched_ext(THEME.s_box_r2, 0, ui(40), yy, _nw, _h, CDEF.main_mdblack, 1);
				}
			
				if(noti.icon_end != noone)
					draw_sprite_ui(noti.icon_end, 1, _w - ui(24), yy + _h / 2,,,, COLORS._main_icon);
			
				var ic = noti.icon;
				if(noti.icon == noone) {
					switch(noti.type) {
						case NOTI_TYPE.log :	 ic = THEME.noti_icon_log;     break;	
						case NOTI_TYPE.warning : ic = THEME.noti_icon_warning; break;	
						case NOTI_TYPE.error :	 ic = THEME.noti_icon_error;   break;	
					}
				}
			
				draw_sprite_ui(ic, 1, ui(16), yy + _h / 2, .85, .85);
				
				var tx = ui(32);
				
				if(show_time) {
					tx += timeW + ui(8);
				
					draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub_inner);
					draw_text_line(tx - ui(4), yy + _h / 2, noti.time, -1, txw);
				}
				
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_inner);
				draw_text_line(tx + ui(4), yy + _h / 2, noti.txt, -1, txw);
				
				if(noti.amount > 1) {
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
					var bw = max( ui(32), string_width(noti.amount) + ui(10) );
					var bh = ui(28);
					
					var bx = _w - ui(0) - bw;
					var by = yy + ui(0) + ui(1);
					
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_accent);
					draw_text(bx + bw / 2, by + bh / 2, noti.amount);
				}
			}
			
			yy += _h + ui(2);
			hh += _h + ui(2);
		}
		
		return hh;
	});
	
	function drawContent(panel) { 
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_noti.setFocusHover(pFOCUS, pHOVER);
		sp_noti.draw(px, py, mx - px, my - py);
		
		if(mouse_press(mb_right, pFOCUS)) {
			menuCall("notification_log_menu", rightClickMenu);
		}
	}
}