globalvar HOTKEYS_CUSTOM;

function __initHotKey() {
	HOTKEYS_CUSTOM  = {
		"Node_Canvas": {
			"Selection":		new hotkeySimple("S"),
			"Magic Selection":	new hotkeySimple("W"),
			"Pencil":	 new hotkeySimple("B"),
			"Eraser":	 new hotkeySimple("E"),
			"Rectangle": new hotkeySimple("N"),
			"Ellipse":	 new hotkeySimple("M"),
			"Iso Cube":	 new hotkeySimple(""),
			"Curve":	 new hotkeySimple(""),
			"Freeform":	 new hotkeySimple("Q"),
			"Fill":		 new hotkeySimple("G"),
			
			"Outline":	 new hotkeySimple("O", MOD_KEY.alt),
			"Extrude":	 new hotkeySimple("E", MOD_KEY.alt),
			"Inset":	 new hotkeySimple("I", MOD_KEY.alt),
			"Skew":		 new hotkeySimple("S", MOD_KEY.alt),
			"Corner":	 new hotkeySimple("C", MOD_KEY.alt),
		},
		
		"Node_Mesh_Warp": {
			"Edit control point": new hotkeySimple("V"),
			"Pin mesh":			  new hotkeySimple("P"),
			"Mesh edit":		  new hotkeySimple("M"),
			"Anchor remove":	  new hotkeySimple("E"),
		},
		
		"Node_Armature": {
			"Move":			new hotkeySimple("V"),
			"Scale":		new hotkeySimple("S"),
			"Add bones":	new hotkeySimple("A"),
			"Remove bones":	new hotkeySimple("E"),
			"Detach bones":	new hotkeySimple("D"),
			"IK":			new hotkeySimple("K"),
		},
		
		"Node_Path": {
			"Transform":			new hotkeySimple("T"),
			"Anchor add / remove":	new hotkeySimple("A"),
			"Edit Control point":	new hotkeySimple("C"),
			"Draw path":			new hotkeySimple("B"),
			"Rectangle path":		new hotkeySimple("N"),
			"Circle path":			new hotkeySimple("M"),
		},
		
		"Node_Rigid_Object": {
			"Mesh edit":		new hotkeySimple("A"),
			"Anchor remove":	new hotkeySimple("E"),
		},
		
		"Node_Strand_Create": {
			"Push":		new hotkeySimple("P"),
			"Comb":		new hotkeySimple("C"),
			"Stretch":	new hotkeySimple("S"),
			"Shorten":	new hotkeySimple("D"),
			"Grab":		new hotkeySimple("G"),
		},
		
		"Node_Path_Anchor": {
			"Adjust control point":		new hotkeySimple("A"),
		},
		
		"Node_3D_Object": {
			"Transform":	new hotkeySimple("G"),
			"Rotate":		new hotkeySimple("R"),
			"Scale":		new hotkeySimple("S"),
		},
		
		"Node_3D_Camera": {
			"Move Target":	new hotkeySimple("T"),
		},
		
	};
}

function getToolHotkey(_group, _key) {
	INLINE
	
	if(!struct_has(HOTKEYS_CUSTOM, _group)) return noone;
	
	var _grp = HOTKEYS_CUSTOM[$ _group];
	if(!struct_has(_grp, _key)) return noone;
	
	return _grp[$ _key];
}
	
function hotkeySimple(_key, modi = MOD_KEY.none) constructor {
	self.key  = key_get_index(_key);
	self.modi = modi;
	
	dKey  = key;
	dModi = modi;
	
	static isPressing = function() { 
		if(is_string(key)) key = key_get_index(key);
		return key == noone? false : key_press(key, modi); 
	}
	
	static getName = function() {
		if(is_string(key)) key = key_get_index(key);
		return key_get_name(key, modi);
	}
}

function hotkeyObject(_context, _name, _key, _mod = MOD_KEY.none, _action = noone) constructor {
	context	= _context;
	name	= _name;
	key		= _key;
	modi	= _mod;
	action	= _action;
	
	dKey	= _key;
	dModi	= _mod;
	
	static serialize = function() { return { context, name, key, modi }; }
	
	static deserialize = function(ll) {
		key  = is_struct(ll)? ll.key  : ll[2];
		modi = is_struct(ll)? ll.modi : ll[3];
	}
	
	var _loadKey = $"{context}_{name}";
	if(struct_has(HOTKEYS_DATA, _loadKey))
		deserialize(HOTKEYS_DATA[$ _loadKey]);
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
		var press = false;
		
		for(var a = 0; a < array_length(vk_list); a++) {
			if(!keyboard_check_pressed(vk_list[a])) continue;
			hotkey.key = vk_list[a];
			press = true; 
			break;
		}
								
		if(!press) {
			var k = ds_map_find_first(global.KEY_STRING_MAP);
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