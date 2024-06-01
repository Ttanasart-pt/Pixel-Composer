/// @description init
event_inherited();

#region data
	menu_id = "";
	
	destroy_on_click_out = false;
	draggable    = false;
	mouse_inside = false;
	selecting    = -1;
	
	alarm[0]  = -1;
	menu      = 1;
	hght      = ui(36);
	
	tooltips  = [];
	show_icon = false;
	context   = noone;
	
	_hovering_ch  = true;
	init_pressing = false;
	
	setFocus(self.id);
	
	function setMenu(_menu, align = fa_left) {
		with(_p_dialog) { if(on_top) continue; other.depth = min(depth - 1, other.depth); }
		
		menu = _menu;
		dialog_x = x;
		dialog_y = y;
		
		show_icon = false;
		dialog_w = 0;
		dialog_h = 0;
		
		for( var i = 0, n = array_length(children); i < n; i++ ) 
			instance_destroy(children[i]);
		children = [];
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		for(var i = 0; i < array_length(menu); i++) {
			var _menuItem = menu[i];
			if(_menuItem == -1) {
				dialog_h += ui(8);
				continue;
			}
			
			draw_set_font(f_p0);
			var ww = string_width(_menuItem.name) + ui(64);
			
			if(instanceof(_menuItem) == "MenuItemGroup") {
				var amo = array_length(_menuItem.group);
				ww = max(ww, ui(16) + amo * (_menuItem.spacing + ui(4)));
				dialog_h += hght;
			} 
			
			if(instanceof(_menuItem) == "MenuItem") {
				if(_menuItem.hotkey != noone) {
					var _key = find_hotkey(_menuItem.hotkey[0], _menuItem.hotkey[1]);
					if(_key) {
						draw_set_font(f_p1);
						var ss = key_get_name(_key.key, _key.modi);	
						ww += string_width(ss) + ui(16);
					}
				} 
				
				if(_menuItem.spr != noone)
					show_icon = true;
				if(_menuItem.toggle != noone)
					show_icon = true;
			}
			
			dialog_w = max(dialog_w, ww);
			dialog_h += hght;
		}
		
		if(show_icon)
			dialog_w += ui(32);
		
		dialog_y = min(dialog_y, WIN_H - dialog_h - 2);
		
		switch(align) {
			case fa_left:	dialog_x = round(min(dialog_x, WIN_W - dialog_w - 2)); break;
			case fa_center: dialog_x = round(min(dialog_x - dialog_w / 2, WIN_W - dialog_w - 2)); break;
			case fa_right:	dialog_x = round(max(dialog_x - dialog_w, 2)); break;
		}
		
		mouse_inside = point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h);
		ready = true;
	}
#endregion