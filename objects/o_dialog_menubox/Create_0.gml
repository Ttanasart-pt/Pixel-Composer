/// @description init
event_inherited();

#region data
	destroy_on_click_out = false;
	draggable   		 = false;
	mouse_init_inside	 = false;
	selecting   		 = -1;
	parentPanel          = noone; 
	context              = noone;
	
	menu_id   = "";
	menu      = 1;
	align     = fa_left;
	tooltips  = [];
	show_icon = false;
	font      = f_p3;
	hght      = line_get_height(font, 8);
	menu_building = true;
	
	submenu   = noone;
	submenuIt = noone;
	
	_hovering_ch = true;
	init_press_l = mouse_press(mb_left);
	
	alarm[0] = -1;
	setFocus(self.id);
#endregion

#region menu
	item_sel_submenu = noone;
	remove_parents   = true;
	close_on_trigger = true;
	selecting_menu   = noone;
	hk_editing       = noone;
	
	function addMenu(_menu) {
		array_append(menu, _menu);
		setMenu(menu, align);
		return self;
	}
	
	function setMenu(_menu, _align = fa_left) {
		if(!sHOVER) init_rclick = mouse_rclick();
		with(_p_dialog) { if(on_top) continue; other.depth = min(depth - 1, other.depth); }
		
		title    = menu_id;
		menu     = _menu;
		align    = _align;
		dialog_x = x;
		dialog_y = y;
		
		show_icon = false;
		dialog_w = 0;
		dialog_h = 0;
		
		if(submenu != noone) instance_destroy(submenu);
		submenu  = noone;
		tooltips = [];
		
		draw_set_text(font, fa_center, fa_center, COLORS._main_text);
		for( var i = 0, n = array_length(menu); i < n; i++ ) {
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
			var _key = _menuItem.hoykeyObject;
			
			draw_set_font(font);
			var _kw = _key? string_width(key_get_name(_key.key, _key.modi)) + ui(16) : 0;
			
			if(is(_menuItem, MenuItemGroup)) {
				var amo = array_length(_menuItem.group);
				ww = max(ww + _kw * 2, ui(16) + amo * (_menuItem.spacing + ui(4)));
				dialog_h += hght;
			} 
			
			if(is(_menuItem, MenuItem)) {
				ww += _kw;
				
				var _txt     = _menuItem.name;
				var _nodeKey = string_pos(">", _txt)? string_copy(_txt, 1, string_pos(">", _txt) - 1) : _txt;
				var _node    = struct_try_get(ALL_NODES, _nodeKey, noone);
				
				if(_node != noone) show_icon = true;
				if(_menuItem.getSpr() != noone || _menuItem.toggle != noone) show_icon = true;
			}
			
			dialog_w = max(dialog_w, ww);
			dialog_h += hght;
		}
		
		dialog_w += show_icon * ui(32);
		
		var _mon  = winMan_getData();
		var _maxw = WIN_W;
		var _maxh = WIN_H;
		
		dialog_y = min(dialog_y, _maxh - dialog_h - 2);
		
		switch(_align) {
			case fa_left:	dialog_x = round(min(dialog_x, _maxw - dialog_w - 2)); break;
			case fa_center: dialog_x = round(min(dialog_x - dialog_w / 2, _maxw - dialog_w - 2)); break;
			case fa_right:	dialog_x = round(max(dialog_x - dialog_w, 2)); break;
		}
		
		mouse_init_inside = point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h);
		ready = true;
		
	}
	
	function getContextPanel() { return is(context, PanelContent)? context.panel : context; }
	
	function setTooltip(_tooltips) { tooltips = _tooltips; return self; }
#endregion