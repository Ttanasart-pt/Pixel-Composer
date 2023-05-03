function addonContextGenerator(_addon, _function) constructor {
	self._addon = _addon;
	self._function = _function;
	
	static populate = function() { 
		var _items = lua_call(_addon.thread, _function); 
		var arr = [];
		
		for( var i = 0; i < array_length(_items); i++ ) {
			var _item = _items[i];
			if(_item == -1) 
				array_push(arr, -1);
			else {
				var _addonItem = new addonContextItem(_addon, _item.name, _item.callback);
				array_push(arr, _addonItem.menu_item);
			}
		}
		
		return arr;
	}
}

function addonContextItem(_addon, _name, _function) constructor {
	self._addon = _addon;
	self._name  = _name;
	self._function = _function;
	
	menu_item = menuItem(_name, function() { lua_call(_addon.thread, self._function); })
		.setColor(COLORS._main_accent);
}

function addonTrigger(_addon) {
	var _name = filename_name_only(_addon);
	with(_addon_custom) {
		if(name != _name) 
			continue;
		
		instance_destroy();
		return;
	}
	
	var addonPath = DIRECTORY + "Addons\\" + _name;
	with(instance_create(0, 0, _addon_custom))
		init(addonPath);
}

function addonActivated(_addon) {
	var _name = filename_name_only(_addon);
	with(_addon_custom) if(name == _name) return true;
	return false;
}