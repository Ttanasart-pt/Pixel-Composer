#region data
	globalvar CONTEXT_MENU_CALLBACK, FOCUS_BEFORE;
	
	CONTEXT_MENU_CALLBACK = ds_map_create();
	FOCUS_BEFORE = noone;
#endregion

function menuCall(menu_id = "", menu = [], _x = 0, _y = 0, align = fa_left, context = noone) {
	if(array_empty(menu)) return noone;
	
	_x = _x == 0? mouse_mx + ui(4) : _x;
	_y = _y == 0? mouse_my + ui(4) : _y;
	
	FOCUS_BEFORE = FOCUS;
	
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

function pieMenuCall(menu_id = "", _x = mouse_mx, _y = mouse_my, menu = [], context = noone) {
	var dia = instance_create(_x, _y, o_pie_menu);
	if(menu_id != "" && ds_map_exists(CONTEXT_MENU_CALLBACK, menu_id)) {
		var callbacks = CONTEXT_MENU_CALLBACK[? menu_id];
		
		for( var i = 0, n = array_length(callbacks); i < n; i++ ) 
			array_append(menu, callbacks[i].populate());
	}
	
	dia.menu_id = menu_id;
	dia.context = context;
	dia.setMenu(menu);
	return dia;
}

function submenuCall(_data = undefined, menu = []) {
	if(is_undefined(_data)) return menuCall("", menu);
	
	var dia = instance_create_depth(_data.x - ui(4), _data.y, _data.depth - 1, o_dialog_menubox);
	dia.context	   = _data.context;
	dia.setMenu(menu);
	
	if(_data.x - ui(4) + dia.dialog_w > WIN_W - ui(2))
		dia.dialog_x = _data._x - dia.dialog_w + ui(4);
	
	return dia;
}

function fileNameCall(path, onModify, _x = mouse_mx + 8, _y = mouse_my + 8) {
	var dia = dialogCall(o_dialog_file_name, _x, _y);
	dia.onModify = onModify;
	dia.path     = string_trim_end(path, [ "\\", "/" ]) + "/";
	
	return dia;
}

function menuItem(     name, func, spr = noone, hotkey = noone, toggle = noone, params = noone) { return new MenuItem(name, func, spr, hotkey, toggle, params); }
function menuItemShelf(name, func, spr = noone, hotkey = noone, toggle = noone, params = noone) { return new MenuItem(name, func, spr, hotkey, toggle, params).setIsShelf(); }

function MenuItem(_name, _func, _spr = noone, _hotkey = noone, _toggle = noone, _params = noone) constructor {
	active	= true;
	name	= _name;
	func	= _func;
	spr		= _spr;
	hotkey	= _hotkey;
	toggle	= _toggle;
	params	= _params;
	color	= c_white;
	
	isShelf      = false;
	shelfObject  = noone;
	shiftMenu	 = noone;
	hoykeyObject = noone;
	
	static deactivate   = function()			/*=>*/ { INLINE active		= false;		return self; }
	static setIsShelf   = function()			/*=>*/ { INLINE isShelf 	= true;			return self; }
	static setActive    = function(_active)		/*=>*/ { INLINE active 		= _active;		return self; }
	static setColor     = function(_color)		/*=>*/ { INLINE color		= _color;		return self; }
	static setShiftMenu = function(_shiftMenu)	/*=>*/ { INLINE shiftMenu	= _shiftMenu;	return self; }
}

function menuItemGroup(_name, _group, _hotkey = noone) { return new MenuItemGroup(_name, _group, _hotkey); }
function MenuItemGroup(_name, _group, _hotkey = noone) constructor {
	active	= true;
	name	= _name;
	group	= _group;
	hotkey  = _hotkey;
	params	= {};
	
	hoykeyObject = noone;
	spacing = ui(36);
	
	static setSpacing = function(_spacing) {
		spacing = _spacing;
		return self;
	}
}