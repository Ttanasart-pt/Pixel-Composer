#region
	globalvar HOTKEYS_CUSTOM;
	HOTKEYS_CUSTOM  = {
		"Node_Canvas": {
			"Selection": new hotkeySimple("S"),
			"Pencil":	 new hotkeySimple("B"),
			"Eraser":	 new hotkeySimple("E"),
			"Rectangle": new hotkeySimple("N"),
			"Ellipse":	 new hotkeySimple("M"),
			"Fill":		 new hotkeySimple("F"),
		}
	};
#endregion

#region hotkeys	
	function hotkeySimple(_key) constructor {
		self.key = _key;
	}
	
	function hotkeyObject(_context, _name, _key, _mod = MOD_KEY.none, _action = noone) constructor {
		context	= _context;
		name	= _name;
		key		= _key;
		modi	= _mod;
		action	= _action;
		
		dKey	= _key;
		dModi	= _mod;
		
		static serialize = function() {
			var ll = ds_list_create();
			ll[| 0] = context;
			ll[| 1] = name;
			ll[| 2] = key;
			ll[| 3] = modi;
			return ll;
		}
		
		static deserialize = function(ll) {
			key  = ll[| 2];
			modi = ll[| 3];
		}
	}
	
	function addHotkey(_context, _name, _key, _mod, _action) {
		if(is_string(_key)) {
			var ind = key_get_index(_key);
			_key = ind? ind : ord(_key);
		}
		
		var key = new hotkeyObject(_context, _name, _key, _mod, _action);
		
		if(!ds_map_exists(HOTKEYS, _context)) {
			HOTKEYS[? _context] = ds_list_create();
			if(!ds_list_exist(HOTKEY_CONTEXT, _context))
				ds_list_add(HOTKEY_CONTEXT, _context);
		}
		
		for(var i = 0; i < ds_list_size(HOTKEYS[? _context]); i++) {
			var hotkey	= HOTKEYS[? _context][| i];
			if(hotkey.name == key.name) {
				delete HOTKEYS[? _context][| i];
				HOTKEYS[? _context][| i] = key;
				return;
			}
		}
		
		if(_context == "")
			ds_list_insert(HOTKEYS[? _context], 0, key);
		else
			ds_list_add(HOTKEYS[? _context], key);
	}
#endregion

#region functions
	function getHotkey(_group, _key, _def = "") {
		gml_pragma("forceinline");
		
		if(!struct_has(HOTKEYS_CUSTOM, _group)) return def;
		
		var _grp = HOTKEYS_CUSTOM[$ _group];
		return struct_try_get(_grp, _key, _def);
	}
#endregion