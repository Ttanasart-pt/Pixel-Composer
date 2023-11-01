#region context menu
	globalvar CONTEXT_MENU_CALLBACK;
	CONTEXT_MENU_CALLBACK = ds_map_create();
	
	function menuCall(menu_id = "", _x = mouse_mx + ui(4), _y = mouse_my + ui(4), menu = [], align = fa_left, context = noone) {
		var dia = dialogCall(o_dialog_menubox, _x, _y);
		if(menu_id != "" && ds_map_exists(CONTEXT_MENU_CALLBACK, menu_id)) {
			var callbacks = CONTEXT_MENU_CALLBACK[? menu_id];
			
			for( var i = 0, n = array_length(callbacks); i < n; i++ ) 
				array_append(menu, callbacks[i].populate());
		}
		
		dia.menu_id = menu_id;
		dia.context = context;
		dia.setMenu(menu, align);
		return dia;
	}

	function submenuCall(_data, menu = []) {
		var dia = instance_create_depth(_data.x - ui(4), _data.y, _data.depth - 1, o_dialog_menubox);
		dia.context = _data.context;
		dia.setMenu(menu);
		
		if(_data.x - ui(4) + dia.dialog_w > WIN_W - ui(2))
			dia.dialog_x = _data._x - dia.dialog_w + ui(4);
		
		return dia;
	}
	
	function menuItem(name, func, spr = noone, hotkey = noone, toggle = noone) {
		gml_pragma("forceinline");
		return new MenuItem(name, func, spr, hotkey, toggle);
	}
	
	function MenuItem(name, func, spr = noone, hotkey = noone, toggle = noone) constructor {
		active = true;
		self.name	= name;
		self.func	= func;
		self.spr	= spr;
		self.hotkey = hotkey;
		self.toggle = toggle;
		color   = c_white;
		isShelf = false;
		
		shiftMenu = noone;
		
		static setIsShelf = function() {
			gml_pragma("forceinline");
			isShelf = true;
			return self;
		}
		
		static setActive = function(active) {
			gml_pragma("forceinline");
			self.active = active;
			return self;
		}
		
		static setColor = function(color) {
			gml_pragma("forceinline");
			self.color = color;
			return self;
		}
		
		static setShiftMenu = function(shiftMenu) {
			gml_pragma("forceinline");
			self.shiftMenu = shiftMenu;
			return self;
		}
	
		static deactivate = function() {
			gml_pragma("forceinline");
			active = false;
			return self;
		}
	}

	function menuItemGroup(name, group) {
		return new MenuItemGroup(name, group);
	}
	
	function MenuItemGroup(name, group) constructor {
		active = true;
		self.name	= name;
		self.group  = group;
		
		spacing = ui(36);
	}
#endregion