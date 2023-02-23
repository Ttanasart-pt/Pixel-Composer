/// @description init
event_inherited();

#region data
	draggable = false;
	destroy_on_click_out = false;
	selecting = -1;
	
	alarm[0] = -1;
	menu = 1;
	hght = ui(36);
	children = ds_list_create();
	ds_list_add(children, self);
	
	show_icon = false;
	
	function setMenu(_menu, align = fa_left) {
		menu = _menu;
		dialog_x = x;
		dialog_y = y;
		
		show_icon = false;
		dialog_w = 0;
		dialog_h = 0;
		
		while(ds_list_size(children) > 1) {
			var ch = children[| 1];
			instance_destroy(children[| 1]);
			ds_list_delete(children, 1);
		}
		
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
				ww = max(ww, ui(16) + amo * (hght + ui(4)));
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
			}
			
			dialog_w = max(dialog_w, ww);
			dialog_h += hght;
		}
		
		if(show_icon)
			dialog_w += ui(32);
		
		dialog_y = min(dialog_y, WIN_H - dialog_h);
		
		switch(align) {
			case fa_left:	dialog_x = round(min(dialog_x, WIN_W - dialog_w)); break;
			case fa_center: dialog_x = round(min(dialog_x - dialog_w / 2, WIN_W - dialog_w)); break;
		}
		
		ready = true;
	}
#endregion