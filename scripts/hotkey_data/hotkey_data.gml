globalvar HOTKEYS_DATA, HOTKEYS_CUSTOM;
#macro FN_NODE_TOOL_INVOKE if(!variable_global_exists("__FN_NODE_TOOL") || variable_global_get("__FN_NODE_TOOL") == undefined) variable_global_set("__FN_NODE_TOOL", []); \
array_push(global.__FN_NODE_TOOL, function()
	
function __initHotKey() {
	HOTKEYS_CUSTOM = {};
	
    for( var i = 0, n = array_length(global.__FN_NODE_TOOL); i < n; i++ ) 
    	global.__FN_NODE_TOOL[i]();
}

	////- Classes

function Hotkey(_context, _name, _key = "", _mod = MOD_KEY.none, _action = noone, _param = noone) constructor {
	context   = _context;
	name      = _name;
	
	key       = key_get_index(_key);
	dKey      = key;
	
	modi      = _mod;
	dModi     = modi;
	
	rawAction = _action;
	param     = _param;
	
	static setParam = function(p) /*=>*/ { param = p; return self; }
	
	static action = function() {
		if(param == noone) rawAction();
		else rawAction(param);
		
		if(key)
		switch(context) {
			case "Graph":   PANEL_GRAPH.setActionTooltip(name);   break;
			case "Preview": PANEL_PREVIEW.setActionTooltip(name); break;
		}
	}
	
	static getName     = function() /*=>*/ {return key_get_name(key, modi)};
	static getNameFull = function() /*=>*/ {return string_to_var(context == 0? $"global.{name}" : $"{context}.{name}")};
	
	static isPressing  = function(h=0) /*=>*/ {return key <= 0 && modi == 0? false : key_press(key, modi, h)};
	static isModified  = function()    /*=>*/ {return key != dKey || modi != dModi};
	
	static equal  = function(h)   /*=>*/ {return key == h.key && modi == h.modi};
	static reset  = function(r=0) /*=>*/ { key = dKey; modi = dModi; if(r) PREF_SAVE(); }
	static modify = function()    /*=>*/ { keyboard_lastchar = key; return self; }
	
	static toString = function() /*=>*/ {return $"{getNameFull()}: {getName()} [{key}+{modi}]"};
	
	////- Serialize
	
	static serialize = function() /*=>*/ { return { context, name, key, modi, fname : getNameFull() } }
	
	static deserialize = function(l) /*=>*/ { 
		if(!is_struct(l)) return self; 
		key  = l.key; 
		modi = l.modi; 
		return self; 
	}
	
	if(VERSION >= 1_18_10_1) deserialize(HOTKEYS_DATA[$ getNameFull()]);
}

function hotkeyTool(_context, _name, _key = "", _mod = MOD_KEY.none) { 
	var _hk = new Hotkey(_context, _name, _key, _mod);
	
	if(!struct_has(HOTKEYS_CUSTOM, _context)) HOTKEYS_CUSTOM[$ _context] = {};
	HOTKEYS_CUSTOM[$ _context][$ _name] = _hk;
	
	return _hk;
}

	////- Actions

function addHotkey(_context, _name, _key, _mod, _action) {
	var key = new Hotkey(_context, _name, _key, _mod, _action);
	
	if(!struct_has(HOTKEYS, _context)) {
		HOTKEYS[$ _context] = [];
		array_push_unique(HOTKEY_CONTEXT, _context);
	}
	
	for(var i = 0; i < array_length(HOTKEYS[$ _context]); i++) {
		var hotkey = HOTKEYS[$ _context][i];
		if(hotkey.name == key.name) {
			delete HOTKEYS[$ _context][i];
			HOTKEYS[$ _context][i] = key;
			return key;
		}
	}
	
	if(_context == "") array_insert(HOTKEYS[$ _context], 0, key);
	else			   array_push(HOTKEYS[$ _context], key);
	
	return key;
}

function find_hotkey(_context, _name) {
	if(!struct_has(HOTKEYS, _context)) return getToolHotkey(_context, _name);
	
	for(var j = 0; j < array_length(HOTKEYS[$ _context]); j++) {
		if(HOTKEYS[$ _context][j].name == _name)
			return HOTKEYS[$ _context][j];
	}
	
	return noone;
}

function getToolHotkey(_group, _key) {
	INLINE
	
	if(!struct_has(HOTKEYS_CUSTOM, _group)) return noone;
	
	var _grp = HOTKEYS_CUSTOM[$ _group];
	if(!struct_has(_grp, _key)) return noone;
	
	return _grp[$ _key];
}

function hotkey_editing(hotkey) {
	static vk_list = [ 
		vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
	];
	
	HOTKEY_BLOCK = true;
	var _mod_prs = 0;
	
	if(keyboard_check(vk_control))	_mod_prs |= MOD_KEY.ctrl;
	if(keyboard_check(vk_shift))	_mod_prs |= MOD_KEY.shift;
	if(keyboard_check(vk_alt))		_mod_prs |= MOD_KEY.alt;
	
	if(keyboard_check_pressed(vk_escape)) {
		hotkey.key  = 0;
		hotkey.modi = 0;
		
		PREF_SAVE();
		
	} else if(keyboard_check_pressed(vk_anykey)) {
		hotkey.modi = _mod_prs;
		hotkey.key  = keyboard_lastkey;
		
		PREF_SAVE();
	}
}

function hotkey_draw(keyStr, _x, _y, _status = 0) {
	if(keyStr == "") return;
	
	var bc = c_white;
	var tc = c_white;
	
	switch(_status) {
		case 0 : bc = CDEF.main_dkgrey;    tc = COLORS._main_text_sub;    break;
		case 1 : bc = CDEF.main_ltgrey;    tc = CDEF.main_ltgrey;         break;
		case 2 : bc = COLORS._main_accent; tc = COLORS._main_text_accent; break;
	}
	
	draw_set_text(f_p2, fa_right, fa_center, tc);
	draw_text(_x, _y - ui(2), keyStr);
}

function hotkey_serialize() {
	var _context = [];
	for(var i = 0, n = array_length(HOTKEY_CONTEXT); i < n; i++) {
		var ll = HOTKEYS[$ HOTKEY_CONTEXT[i]];
		
		for(var j = 0, m = array_length(ll); j < m; j++) {
			var _hk = ll[j];
			if(_hk.dKey == _hk.key && _hk.dModi == _hk.modi) continue;
			array_push(_context, _hk.serialize());
		}
	}
	
	var _node = [];
	var _cust = variable_struct_get_names(HOTKEYS_CUSTOM);
	for(var i = 0, n = array_length(_cust); i < n; i++) {
		var nd = _cust[i];
		var nl = HOTKEYS_CUSTOM[$ nd];
		var kk = variable_struct_get_names(nl);
		
		for (var j = 0, m = array_length(kk); j < m; j++) {
			var _nm = kk[j];
			var _hk = nl[$ _nm];
			
			if(_hk.dKey == _hk.key && _hk.dModi == _hk.modi) continue;
			array_push(_node, _hk.serialize());
		}
	}
	
	var _graph = {};
	for( var i = 0, n = array_length(GRAPH_ADD_NODE_KEYS); i < n; i++ ) {
		var _ky = GRAPH_ADD_NODE_KEYS[i];
		_graph[$ _ky.name] = _ky.serialize();
	}
	
	json_save_struct(PREFERENCES_DIR + "hotkeys.json", { context: _context, node: _node, graph: _graph });
}

function hotkey_deserialize() {
	HOTKEYS_DATA = {};
	
	var path = PREFERENCES_DIR + "hotkeys.json";
	if(!file_exists(path)) return;
	
	var map = json_load_struct(path);
	if(!is_struct(map)) return;
	
	var fn = function(n) /*=>*/ { HOTKEYS_DATA[$ string_to_var(n.context == 0? $"global.{n.name}" : $"{n.context}.{n.name}")] = n; };
	
	if(struct_has(map, "context")) array_foreach(map.context, fn);
	if(struct_has(map, "node"))    array_foreach(map.node,    fn);
	if(struct_has(map, "graph"))   HOTKEYS_DATA.graph = map.graph;
}