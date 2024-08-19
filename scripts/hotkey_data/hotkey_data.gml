globalvar HOTKEYS_CUSTOM;

function __initHotKey() {
	HOTKEYS_CUSTOM  = {};
	
	hotkeySimple("Node_Canvas",         	"Selection",            "S");
	hotkeySimple("Node_Canvas",         	"Magic Selection",      "W");
	hotkeySimple("Node_Canvas",         	"Pencil",               "B");
	hotkeySimple("Node_Canvas",         	"Eraser",               "E");
	hotkeySimple("Node_Canvas",         	"Rectangle",            "N");
	hotkeySimple("Node_Canvas",         	"Ellipse",              "M");
	hotkeySimple("Node_Canvas",         	"Iso Cube",             "");
	hotkeySimple("Node_Canvas",         	"Curve",                "");
	hotkeySimple("Node_Canvas",         	"Freeform",             "Q");
	hotkeySimple("Node_Canvas",         	"Fill",                 "G");
	hotkeySimple("Node_Canvas",         	"Outline",              "O", MOD_KEY.alt);
	hotkeySimple("Node_Canvas",         	"Extrude",              "E", MOD_KEY.alt);
	hotkeySimple("Node_Canvas",         	"Inset",                "I", MOD_KEY.alt);
	hotkeySimple("Node_Canvas",         	"Skew",                 "S", MOD_KEY.alt);
	hotkeySimple("Node_Canvas",         	"Corner",               "C", MOD_KEY.alt);
	  
	hotkeySimple("Node_Mesh_Warp",          "Edit control point",   "V");
	hotkeySimple("Node_Mesh_Warp",          "Pin mesh",             "P");
	hotkeySimple("Node_Mesh_Warp",          "Mesh edit",            "M");
	hotkeySimple("Node_Mesh_Warp",          "Anchor remove",        "E");
	 
	hotkeySimple("Node_Armature",           "Move",                 "V");
	hotkeySimple("Node_Armature",           "Scale",                "S");
	hotkeySimple("Node_Armature",           "Add bones",            "A");
	hotkeySimple("Node_Armature",           "Remove bones",         "E");
	hotkeySimple("Node_Armature",           "Detach bones",         "D");
	hotkeySimple("Node_Armature",           "IK",                   "K");
	           
	hotkeySimple("Node_Path",               "Transform",            "T");
	hotkeySimple("Node_Path",               "Anchor add / remove",  "A");
	hotkeySimple("Node_Path",               "Edit Control point",   "C");
	hotkeySimple("Node_Path",               "Draw path",            "B");
	hotkeySimple("Node_Path",               "Rectangle path",       "N");
	hotkeySimple("Node_Path",               "Circle path",          "M");
	
	hotkeySimple("Node_Rigid_Object",       "Mesh edit",            "A");
	hotkeySimple("Node_Rigid_Object",       "Anchor remove",        "E");
	            
	hotkeySimple("Node_Strand_Create",      "Push",                 "P");
	hotkeySimple("Node_Strand_Create",      "Comb",                 "C");
	hotkeySimple("Node_Strand_Create",      "Stretch",              "S");
	hotkeySimple("Node_Strand_Create",      "Shorten",              "D");
	hotkeySimple("Node_Strand_Create",      "Grab",                 "G");
	
	hotkeySimple("Node_Path_Anchor",        "Adjust control point", "A");
	       
	hotkeySimple("Node_3D_Object",          "Transform",            "G");
	hotkeySimple("Node_3D_Object",          "Rotate",               "R");
	hotkeySimple("Node_3D_Object",          "Scale",                "S");
	                  
	hotkeySimple("Node_3D_Camera",          "Move Target",          "T");
}

function getToolHotkey(_group, _key) {
	INLINE
	
	if(!struct_has(HOTKEYS_CUSTOM, _group)) return noone;
	
	var _grp = HOTKEYS_CUSTOM[$ _group];
	if(!struct_has(_grp, _key)) return noone;
	
	return _grp[$ _key];
}

function hotkeySimple(_context, _name, _key, modi = MOD_KEY.none) {	return new HotkeySimple(_context, _name, _key, modi); }
function HotkeySimple(_context, _name, _key, modi = MOD_KEY.none) constructor {
	context	= _context;
	name	= _name;
	
	self.key  = key_get_index(_key);
	self.modi = modi;
	
	dKey  = key;
	dModi = modi;
	
	if(!struct_has(HOTKEYS_CUSTOM, context)) HOTKEYS_CUSTOM[$ context] = {};
	HOTKEYS_CUSTOM[$ context][$ name] = self;
	
	static isPressing = function() { 
		if(is_string(key)) key = key_get_index(key);
		return key == noone? false : key_press(key, modi); 
	}
	
	static getName = function() {
		if(is_string(key)) key = key_get_index(key);
		return key_get_name(key, modi);
	}
	
	static serialize   = function()   {  return { context, name, key, modi } }
	static deserialize = function(ll) { if(!is_struct(ll)) return; key = ll.key; modi = ll.modi; }
	
	var _loadKey = $"{context}_{name}";
	if(struct_has(HOTKEYS_DATA, _loadKey)) deserialize(HOTKEYS_DATA[$ _loadKey]);
}

function hotkeyObject(_context, _name, _key, _mod = MOD_KEY.none, _action = noone) constructor {
	context	= _context;
	name	= _name;
	key		= _key;
	modi	= _mod;
	action	= _action;
	
	dKey	= _key;
	dModi	= _mod;
	
	static full_name = function() { return string_to_var(context == ""? $"global.{name}" : $"{context}.{name}"); }
	
	static serialize   = function()   {  return { context, name, key, modi } }
	static deserialize = function(ll) { if(!is_struct(ll)) return; key = ll.key; modi = ll.modi; }
	
	var _loadKey = $"{context}_{name}";
	if(struct_has(HOTKEYS_DATA, _loadKey)) deserialize(HOTKEYS_DATA[$ _loadKey]);
}

function addHotkey(_context, _name, _key, _mod, _action) {
	if(is_string(_key)) _key = key_get_index(_key);
	
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
	
	if(_context == "") ds_list_insert(HOTKEYS[? _context], 0, key);
	else			   ds_list_add(HOTKEYS[? _context], key);
	
	return key;
}

function find_hotkey(_context, _name) {
	if(!ds_map_exists(HOTKEYS, _context)) return noone;
	
	for(var j = 0; j < ds_list_size(HOTKEYS[? _context]); j++) {
		if(HOTKEYS[? _context][| j].name == _name)
			return HOTKEYS[? _context][| j];
	}
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
		hotkey.modi  = _mod_prs;
		hotkey.key   = 0;
		var press    = false;
		
		for(var a = 0; a < array_length(vk_list); a++) {
			if(!keyboard_check_pressed(vk_list[a])) continue;
			hotkey.key = vk_list[a];
			press = true; 
			break;
		}
								
		if(!press) {
			var k   = ds_map_find_first(global.KEY_STRING_MAP);
			var amo = ds_map_size(global.KEY_STRING_MAP);
			
			repeat(amo) {
				if(!keyboard_check_pressed(k)) {
					k = ds_map_find_next(global.KEY_STRING_MAP, k);
					continue;
				}
				hotkey.key	= k;
				press = true;
				break;
			}
		}
		
		PREF_SAVE();
	}
}

function hotkey_draw(keyStr, _x, _y, _status = 0) {
	if(keyStr == "") return;
	
	var bc = c_white;
	var tc = c_white;
	
	switch(_status) {
		case 0 :
			bc = CDEF.main_dkgrey;
			tc = COLORS._main_text_sub;
			break;
		
		case 1 :
			bc = CDEF.main_ltgrey;
			tc = CDEF.main_ltgrey;
			break;
			
		case 2 :
			bc = COLORS._main_accent;
			tc = COLORS._main_text_accent;
			break;
			
	}
	
	draw_set_text(f_p1, fa_right, fa_center, tc);
	var _tw = string_width( keyStr);
	var _th = string_height(keyStr);
	
	draw_sprite_stretched_ext(THEME.ui_panel, 1, _x - _tw - ui(4), _y - _th / 2 - ui(3), _tw + ui(8), _th + ui(3), bc);
	draw_text(_x, _y, keyStr);
}

function hotkey_serialize() {
	var _context = [];
	for(var i = 0, n = ds_list_size(HOTKEY_CONTEXT); i < n; i++) {
		var ll = HOTKEYS[? HOTKEY_CONTEXT[| i]];
		
		for(var j = 0, m = ds_list_size(ll); j < m; j++) {
			var _hk = ll[| j];
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
	
	json_save_struct(DIRECTORY + "hotkeys.json", { context: _context, node: _node });
}

function hotkey_deserialize() {
	HOTKEYS_DATA = {};
	var path = DIRECTORY + "hotkeys.json";
	if(!file_exists(path)) return;
	
	var map = json_load_struct(path);
	if(!is_struct(map)) return;
	
	if(struct_has(map, "context")) {
		var _ctx = map.context;
		for(var i = 0; i < array_length(_ctx); i++) {
			var key_list    = _ctx[i];
			var _context	= key_list.context;
			var name		= key_list.name;
			
			HOTKEYS_DATA[$ $"{_context}_{name}"] = key_list;
		}
	}
	
	if(struct_has(map, "node")) {
		var _ctx = map.node;
		for(var i = 0; i < array_length(_ctx); i++) {
			var key_list    = _ctx[i];
			var _context	= key_list.context;
			var name		= key_list.name;
			
			HOTKEYS_DATA[$ $"{_context}_{name}"] = key_list;
		}
	}
}