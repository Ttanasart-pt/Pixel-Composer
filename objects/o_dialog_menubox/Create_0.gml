/// @description init
event_inherited();

#region data
	destroy_on_click_out = false;
	draggable   		 = false;
	mouse_init_inside	 = false;
	mouse_init_r_pressed = mouse_click(mb_right);
	selecting   		 = -1;
	
	menu_id    = "";
	alarm[0]   = -1;
	menu       = 1;
	font       = f_p1;
	hght       = line_get_height(font, 10);
	tooltips   = [];
	show_icon  = false;
	context    = noone;
	submenu    = noone;
	
	_hovering_ch  = true;
	init_pressing = false;
	
	setFocus(self.id);
	
	item_sel_submenu = noone;
	remove_parents = true;
	selecting_menu = noone;
	hk_editing     = noone;
	
	function setMenu(_menu, align = fa_left) {
		with(_p_dialog) { if(on_top) continue; other.depth = min(depth - 1, other.depth); }
		
		menu = _menu;
		dialog_x = x;
		dialog_y = y;
		
		show_icon = false;
		dialog_w = 0;
		dialog_h = 0;
		
		if(submenu != noone) instance_destroy(submenu);
		submenu  = noone;
		tooltips = [];
		
		draw_set_text(font, fa_center, fa_center, COLORS._main_text);
		for(var i = 0; i < array_length(menu); i++) {
			var _menuItem = menu[i];
			
			if(_menuItem == -1) {
				dialog_h += ui(8);
				continue;
			}
			
			if(is_string(_menuItem)) {
				draw_set_font(f_p3);
				dialog_w =  max(dialog_w, string_width(_menuItem) + ui(24));
				dialog_h += string_height(_menuItem) + ui(8);
				continue;
			}
			
			draw_set_font(font);
			var ww   = string_width(_menuItem.name) + ui(64);
			var _key = _menuItem.hotkey != noone? find_hotkey(_menuItem.hotkey[0], _menuItem.hotkey[1]) : noone;
			
			draw_set_font(font);
			var _kw = _key? string_width(key_get_name(_key.key, _key.modi)) + ui(16) : 0;
			
			if(instanceof(_menuItem) == "MenuItemGroup") {
				var amo = array_length(_menuItem.group);
				ww = max(ww + _kw * 2, ui(16) + amo * (_menuItem.spacing + ui(4)));
				dialog_h += hght;
			} 
			
			if(instanceof(_menuItem) == "MenuItem") {
				ww += _kw;
				if(_menuItem.spr != noone || _menuItem.toggle != noone) show_icon = true;
			}
			
			dialog_w = max(dialog_w, ww);
			dialog_h += hght;
		}
		
		if(show_icon)
			dialog_w += ui(32);
		
		var _mon  = winMan_getData();
		var _maxw = PREFERENCES.multi_window? _mon[6] - WIN_X : WIN_W;
		var _maxh = PREFERENCES.multi_window? _mon[7] - WIN_Y : WIN_H;
		
		dialog_y = min(dialog_y, _maxh - dialog_h - 2);
		
		switch(align) {
			case fa_left:	dialog_x = round(min(dialog_x, _maxw - dialog_w - 2)); break;
			case fa_center: dialog_x = round(min(dialog_x - dialog_w / 2, _maxw - dialog_w - 2)); break;
			case fa_right:	dialog_x = round(max(dialog_x - dialog_w, 2)); break;
		}
		
		mouse_init_inside = point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h);
		ready = true;
		
		if(PREFERENCES.multi_window) {
			var _wx = winwin_get_x_safe(WINDOW_ACTIVE) + dialog_x;
			var _wy = winwin_get_y_safe(WINDOW_ACTIVE) + dialog_y;
			
			if(window == noone) {
				var _wconfig = new winwin_config();
				    _wconfig.kind            = winwin_kind_borderless;
				    _wconfig.caption         = "";
				    _wconfig.topmost         = true;
				    _wconfig.per_pixel_alpha = true;
				    _wconfig.resize          = false;
				    _wconfig.owner           = winwin_main;
				    _wconfig.taskbar_button  = false;
				    _wconfig.close_button    = false;
				
				window   = winwin_create(_wx, _wy, dialog_w, dialog_h, _wconfig);
			} else {
				winwin_set_position_safe(window, _wx, _wy);
				winwin_set_size_safe(window, dialog_w, dialog_h);
			}
			
			dialog_x = 0;
			dialog_y = 0;
			
		} else if(winwin_exists(window)) {
			winwin_destroy(window);
		}
	}
#endregion