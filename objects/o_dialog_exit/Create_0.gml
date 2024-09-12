/// @description init
event_inherited();

#region data
	project = PROJECT;
	
	dialog_w = ui(440);
	dialog_h = ui(140);
	
	function resetPosition() {
		if(!active) return;
		dialog_x = xstart - dialog_w / 2;
		dialog_y = ystart - dialog_h / 2;
		
		dialog_x = round(clamp(dialog_x, 2, WIN_SW - dialog_w - 2));
		dialog_y = round(clamp(dialog_y, 2, WIN_SH - dialog_h - 2));
		
		if(PREFERENCES.multi_window) {
			var _wx = WIN_X + dialog_x;
			var _wy = WIN_Y + dialog_y;
			
			var _cfg = winwin_config_ext("Exit", winwin_kind_borderless, false, false);
			window   = winwin_create_ext(_wx, _wy, dialog_w, dialog_h, _cfg);
			
			dialog_x = 0;
			dialog_y = 0;
		}
	}
	
#endregion