function addonContextGenerator(_addon, _function) constructor {
	self._addon = _addon;
	self._function = _function;
	
	static populate = function() { 
		var _items = lua_call(_addon.thread, _function); 
		var arr = [];
		
		for( var i = 0, n = array_length(_items); i < n; i++ ) {
			var _item = _items[i];
			if(_item == -1) 
				array_push(arr, -1);
			else {
				if(struct_has(_item, "callback")) {
					var _addonItem = new addonContextItem(_addon, _item.name, _item.callback);
					array_push(arr, _addonItem.menu_item);
				} else if(struct_has(_item, "content")) {
					var _subArr = []
					for( var j = 0; j < array_length(_item.content); j++ ) {
						var _it = _item.content[j];
						if(_it == -1) 
							array_push(_subArr, -1);
						else if(struct_has(_it, "callback")) {
							var _addonItem = new addonContextItem(_addon, _it.name, _it.callback);
							array_push(_subArr, _addonItem.menu_item);
						}
					}
					
					var _addonItem = new addonContextSubMenu(_item.name, _subArr);
					array_push(arr, _addonItem.menu_item);
				}
			}			
		}
		
		return arr;
	}
}

function addonContextItem(_addon, _name, _function) constructor {
	self._addon    = _addon;
	self._name     = _name;
	self._function = _function;
	
	menu_item = menuItem(_name, function(_data) { lua_call(_addon.thread, self._function, lua_byref(_data.context, true)); });
}

function addonContextSubMenu(_name, _content) constructor {
	self.name    = _name;
	self.content = _content;
	
	menu_item = menuItem(name, function(_dat) { return submenuCall(_dat, content); }).setIsShelf();
}

function getAddon(_addonName) { return ADDON_MAP[$ _addonName]; }

function loadAddon(_addonName, _openDialog = true) { 
	var _addon = getAddon(_addonName);
	if(_addon) _addon.activate(_openDialog);
}

function unloadAddon(_addonName, _openDialog = true) { 
	var _addon = getAddon(_addonName);
	if(_addon) _addon.deactivate(_openDialog);
}