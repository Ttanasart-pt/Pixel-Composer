/// @description init
event_inherited();

#region data
	dialog_w = ui(720);
	dialog_h = ui(360);
	
	dialog_resizable = true;
	destroy_on_click_out = true;
	
	onResize = function() {
		sp_noti.resize(dialog_w - ui(80), dialog_h - ui(88));
	}
	
	current_page = 0;
	filter = NOTI_TYPE.log | NOTI_TYPE.warning | NOTI_TYPE.error;
	
	sp_noti = new scrollPane(dialog_w - ui(80), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = 32;
		var yy = _y;
		var txw = sp_noti.w - ui(48 + 48 + 20);
		var amo = ds_list_size(STATUSES);
		
		draw_set_font(f_p3);
		var timeW = string_width("00:00");
		
		for( var i = 0; i < ds_list_size(STATUSES); i++ ) {
			var index = amo - 1 - i;
			var noti = STATUSES[| index];
			if(noti.type & filter == 0) continue;
			
			var _w = sp_noti.w - ui(12);
			var _h = ui(8) + string_height_ext(noti.txt, -1, txw) + ui(8);
			
			draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(2), _w, _h - ui(4), COLORS.dialog_notification_bg, 1);
			
			if(noti.life_max > 0) {
				var _nwx = sp_noti.w - ui(12) - ui(40);
				var _nw  = _nwx * noti.life / noti.life_max;
				
				draw_sprite_stretched_ext(THEME.group_label, 0, ui(40), yy + ui(2), _nw, _h - ui(4), COLORS.dialog_notification_icon_bg, 1);
			}
			
			draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(2), ui(48), _h - ui(4), noti.color, 1);
			
			var ic = noti.icon;
			if(noti.icon == noone) {
				switch(noti.type) {
					case NOTI_TYPE.log :	 ic = THEME.noti_icon_log; break;	
					case NOTI_TYPE.warning : ic = THEME.noti_icon_warning; break;	
					case NOTI_TYPE.error :	 ic = THEME.noti_icon_error; break;	
				}
			}
			
			draw_sprite_ui(ic, 1, ui(24), yy + _h / 2);
			
			var tx = ui(48) + timeW + ui(12);
			
			draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub);
			draw_text_ext(tx - ui(4), yy + _h / 2, noti.time, -1, txw);
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			draw_text_ext(tx + ui(4), yy + _h / 2, noti.txt, -1, txw);
			
			if(noti.onClick != noone && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + _h - ui(4))) {
				draw_sprite_stretched_ext(THEME.node_active, 0, 0, yy + ui(2), _w, _h - ui(4), COLORS._main_accent, 1);
				
				if(mouse_check_button_pressed(mb_left))
					noti.onClick();
			}
			
			yy += _h;
			hh += _h;
		}
		
		return hh;
	})
#endregion