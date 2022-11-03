/// @description init
event_inherited();

#region data
	dialog_w = ui(600);
	dialog_h = ui(360);
	
	dialog_resizable = true;
	destroy_on_click_out = true;
	
	onResize = function() {
		sp_noti.resize(dialog_w - ui(80), dialog_h - ui(88));
	}
	
	current_page = 0;
	filter = NOTI_TYPE.log | NOTI_TYPE.warning | NOTI_TYPE.error;
	
	sp_noti = new scrollPane(dialog_w - ui(80), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		var hh = 32;
		var yy = _y;
		var txw = sp_noti.w - ui(48 + 16 + 20);
		
		for( var i = 0; i < ds_list_size(STATUSES); i++ ) {
			var noti = STATUSES[| i];
			if(noti.type & filter == 0) continue;
			
			var _w = sp_noti.w - ui(12);
			var _h = ui(8) + string_height_ext(noti.txt, -1, txw) + ui(8);
			
			draw_sprite_stretched_ext(s_node_name, 0, 0, yy + ui(2), _w, _h - ui(4), c_ui_blue_grey, 1);
			
			if(noti.life_max > 0) {
				var _nwx = sp_noti.w - ui(12) - ui(44);
				var _nw  = _nwx * noti.life / noti.life_max;
				
				draw_sprite_stretched_ext(s_node_name, 0, ui(44), yy + ui(2), _nw, _h - ui(4), c_ui_blue_ltgrey, 0.5);
			}
			
			draw_sprite_stretched_ext(s_node_name, 0, 0, yy + ui(2), ui(48), _h - ui(4), noti.color, 1);
			
			if(noti.icon)
				draw_sprite_ui(noti.icon, 1, ui(24), yy + _h / 2);
			
			draw_set_text(f_p1, fa_left, fa_center, c_ui_blue_white);
			draw_text_ext(ui(48 + 16), yy + _h / 2, noti.txt, -1, txw);
			
			if(noti.onClick != noone && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + _h - ui(4))) {
				draw_sprite_stretched_ext(s_node_active, 0, 0, yy + ui(2), _w, _h - ui(4), c_white, 1);
				
				if(mouse_check_button_pressed(mb_left))
					noti.onClick();
			}
			
			yy += _h;
			hh += _h;
		}
		
		return hh;
	})
#endregion