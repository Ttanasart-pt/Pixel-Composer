globalvar HOTKEYS_DATA, HOTKEYS_CUSTOM, HOTKEY_MAP;
#macro FN_NODE_TOOL_INVOKE if(!variable_global_exists("__FN_NODE_TOOL") || variable_global_get("__FN_NODE_TOOL") == undefined) variable_global_set("__FN_NODE_TOOL", []); \
array_push(global.__FN_NODE_TOOL, function()
	
function __initHotKey() {
	HOTKEYS_CUSTOM = {};
	
    for( var i = 0, n = array_length(global.__FN_NODE_TOOL); i < n; i++ ) 
    	global.__FN_NODE_TOOL[i]();
}

	////- Classes

function KeyCombination(_key = "", _modi = MOD_KEY.none) constructor {
	_K = key_get_index(_key);
	_M = _modi;
	
	static isPressing = function(hold = false) /*=>*/ {return _K > 0 || _M != MOD_KEY.none? key_press(_K, _M, hold) : false};
	static toString   = function() /*=>*/ {return key_get_name(_K, _M)};
	
	static set     = function(k,m) /*=>*/ { _K = k;    _M = m;    return self; }
	static setKey  = function(k)   /*=>*/ { _K = k._K; _M = k._M; return self; }
	static hasKey  = function()    /*=>*/ {return _K > 0 || _M > 0};
	static isEqual = function(k)   /*=>*/ {return _K == k._K && _M == k._M};
	
	////- Serialize
	
	static serialize   = function( ) /*=>*/ { return { key: _K, modi: _M } }
	static deserialize = function(m) /*=>*/ { _K = m.key; _M = m.modi; }
}

function Hotkey(_context, _name, _key = "", _mod = MOD_KEY.none, _action = noone, _param = noone) constructor {
	context   = _context;
	name      = _name;
	
	dkey = new KeyCombination(_key, _mod);
	key  = new KeyCombination(_key, _mod);
	keys = undefined; // alternative keys?
	
	rawAction = _action;
	param     = _param;
	
	interrupt = false;
	fnObject  = undefined;
	
	static set          = function(k,m) /*=>*/ {return key.set(k,m)};
	static setParam     = function(p) /*=>*/ { param = p;        return self; }
	static setAction    = function(a) /*=>*/ { rawAction = a;    return self; }
	static setInterrupt = function( ) /*=>*/ { interrupt = true; return self; }
	static setFn        = function(f) /*=>*/ { fnObject  = f;    return self; }
	
	static hasKey = function() /*=>*/ {return key.hasKey()};
	
	static action = function() {
		if(param == noone) rawAction();
		else rawAction(param);
		
		if(key.hasKey())
		switch(context) {
			case "Graph":     PANEL_GRAPH.setActionTooltip(name);     break;
			case "Preview":   PANEL_PREVIEW.setActionTooltip(name);   break;
			case "Animation": PANEL_ANIMATION.setActionTooltip(name); break;
		}
	}
	
	static getKeyName  = function() /*=>*/ {return key.toString()};
	static getNameFull = function() /*=>*/ {return string_to_var(context == 0? $"global.{name}" : $"{context}.{name}")};
	
	static isPressing  = function(h=0) /*=>*/ { return key.isPressing(h);
		if(key.isPressing(h)) return true;
		return keys != undefined && array_any(keys, function(k,i) /*=>*/ {return k.isPressing(h)});
	}
	
	static isModified  = function() /*=>*/ {return !key.isEqual(dkey)};
	
	static reset  = function(r=0) /*=>*/ { key.setKey(dkey); if(r) PREF_SAVE(); }
	static modify = function()    /*=>*/ { keyboard_lastchar = key._K; return self; }
	
	static toString = function() /*=>*/ {return $"{getNameFull()}: {getKeyName()}"};
	
	////- Serialize
	
	static serialize = function() /*=>*/ { 
		var m = { context, name };
		m.fname = getNameFull();
		m.keyd  = key.serialize();
		
		if(keys != undefined)
			m.keys = array_map(keys, function(k,i) /*=>*/ {return k.serialize()});
		
		return m;
	}
	
	static deserialize = function(l) /*=>*/ { 
		if(!is_struct(l)) return self; 
		
		if(has(l, "keyd"))
			 key.deserialize(l.keyd);
		else key.set(l.key, l.modi)
		
		if(has(l, "keys"))
			keys = array_map(l.keys, function(k,i) /*=>*/ {return new KeyCombination().deserialize(k)});
		
		return self; 
	}
	
	if(VERSION >= 1_18_10_1) deserialize(HOTKEYS_DATA[$ getNameFull()]);
}

function hotkeyCustom(_context, _name, _key = "", _mod = MOD_KEY.none) { 
	var _hk = new Hotkey(_context, _name, _key, _mod);
	
	if(!struct_has(HOTKEYS_CUSTOM, _context)) HOTKEYS_CUSTOM[$ _context] = {};
	HOTKEYS_CUSTOM[$ _context][$ _name] = _hk;
	
	return _hk;
}

	////- Actions

function addHotkey(_context, _name, _key, _mod, _action, _param = noone) {
	var hotkey = new Hotkey(_context, _name, _key, _mod, _action, _param);
	
	if(!struct_has(HOTKEYS, _context)) {
		HOTKEYS[$ _context] = [];
		array_push_unique(HOTKEY_CONTEXT, _context);
	}
	
	for(var i = 0; i < array_length(HOTKEYS[$ _context]); i++) {
		var _hotkey = HOTKEYS[$ _context][i];
		if(_hotkey.name == hotkey.name) {
			delete HOTKEYS[$ _context][i];
			HOTKEYS[$ _context][i] = hotkey;
			return hotkey;
		}
	}
	
	if(_context == "") array_insert(HOTKEYS[$ _context], 0, hotkey);
	else			   array_push(HOTKEYS[$ _context], hotkey);
	
	return hotkey;
}

function find_hotkey(_context, _name) {
	if(_context == "") _context = 0;
	if(!struct_has(HOTKEYS, _context)) return getToolHotkey(_context, _name);
	
	__name = string_lower(_name);
	var hk = HOTKEYS[$ _context];
	var i  = array_find_index(hk, function(h) /*=>*/ {return string_lower(h.name) == __name});
	return i == -1? noone : hk[i];
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
		hotkey.set(0,0);
		PREF_SAVE();
		
	} else if(keyboard_check_pressed(vk_anykey)) {
		hotkey.set(keyboard_lastkey, _mod_prs);
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
			if(!_hk.isModified()) continue;
			
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
			if(_hk.isModified()) continue;
			
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

	////- ACTION-BASED SYSTEM

function hotkey_refresh() {
	HOTKEY_MAP = {};
	
	var conts = struct_get_names(HOTKEYS);
	
	for( var i = 0, n = array_length(conts); i < n; i++ ) {
		var _ctx = conts[i];
		var list = HOTKEYS[$ _ctx];
		
		for( var i = 0, n = array_length(list); i < n; i++ ) {
			var h = list[i];
			if(!h.hasKey()) continue;
			
			var kname = h.getKeyName();
			if(!has(HOTKEY_MAP, kname))
				HOTKEY_MAP[$ kname] = [];
				
			array_push(HOTKEY_MAP[$ kname], h);
		}
	}
}

function hotkey_check(_str) {
	if(!has(HOTKEY_MAP, _str)) return;
	
	var _toAct   = [];
	var _toActIn = undefined;
	
	var _list = HOTKEY_MAP[$ _str];
	for( var i = 0, n = array_length(_list); i < n; i++ ) {
		var h = _list[i];
		
		if(h.isPressing()) {
			if(h.key == noone) h.action(); // Modifier action trigger immediately
			else if(h.interrupt) _toActIn = h;
			else array_push(_toAct, h);
		}
	}
}