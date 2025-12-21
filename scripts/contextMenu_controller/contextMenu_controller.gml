#region data
	globalvar CONTEXT_MENU_CALLBACK, FOCUS_BEFORE;
	globalvar MENUITEM_CONDITIONS;
	
	CONTEXT_MENU_CALLBACK = ds_map_create();
	FOCUS_BEFORE = noone;
	
	MENUITEM_CONDITIONS = {};
#endregion

function menuItem(     name, func, spr = noone, hotkey = noone, toggle = noone, params = noone) { return new MenuItem(name, func, spr, hotkey, toggle, params); }
function menuItemShelf(name, func, spr = noone, hotkey = noone, toggle = noone, params = noone) { 
	return new MenuItem(name, func, spr, hotkey, toggle, params).setIsShelf(); 
}
	
function MenuItem(_name, _func, _spr = noone, _hotkey = noone, _toggle = noone, _params = noone) constructor {
	active	= true;
	name	= _name;
	func	= _func;
	spr		= _spr;
	hotkey	= _hotkey;
	toggle	= _toggle;
	params	= _params;
	color	= c_white;
	
	tooltip      = noone;
	tooltipName  = new tooltipHotkey(name, undefined);
	
	isShelf      = false;
	shelfObject  = noone;
	shiftMenu	 = noone;
	contextMenu  = [];
	hoykeyObject = noone;
	
	scrollable   = false;
	
	static toggleFunction = function(_dat = undefined) /*=>*/ {
		if(!is_undefined(_dat)) return func(_dat);
		if(params != noone)     return func(params);
			
		return func();
	}
	
    static deactivate   = function() /*=>*/ { active = false; return self; }
	
    static setIsShelf   = function()           /*=>*/ { isShelf    = true;       return self; }
    static setActive    = function(_active)    /*=>*/ { active     = _active;    return self; }
    static setColor     = function(_color)     /*=>*/ { color      = _color;     return self; }
    static setShiftMenu = function(_shiftMenu) /*=>*/ { shiftMenu  = _shiftMenu; return self; }
    static setParam     = function(_param)     /*=>*/ { params     = _param;     return self; }
    static setToggle    = function(_toggle)    /*=>*/ { toggle     = _toggle;    return self; }
    static setTooltip   = function(_t)         /*=>*/ { tooltip    = _t; scrollable = true; return self; }
    static setContext   = function(_c)         /*=>*/ { contextMenu = _c;        return self; }
    static setScroll    = function()           /*=>*/ { scrollable = true;       return self; }
	
	static getSpr       = function() /*=>*/ {return spr};
	static getSprInd    = function() /*=>*/ {return 0};
	static getTooltip   = function() /*=>*/ {
		if(tooltip == noone) {
			tooltipName.hotkey = hoykeyObject;
			return tooltipName;
		}
		
		tooltip.index = getSprInd();
		return tooltip;
	}
	
	static draw = function(bx, by, bw, bh, m, hov, foc, con = "") {
		var _tool = getTooltip();
		var _spr  = getSpr();
		var _spri = getSprInd();
		var _cc   = COLORS._main_icon;
		
		var b = buttonInstant_Pad(THEME.button_hide_fill, bx, by, bw, bh, m, hov, foc, _tool, _spr, _spri, _cc, 1, ui(4));
		
		if(b == 2) toggleFunction();
		if(b == 3) {
			var _cont = array_clone(contextMenu, 1);
			if(con != "") {
				if(!array_empty(_cont)) array_push(_cont, -1);
				array_append(_cont, menuItems_gen($"{con}_context")); 
			}
			
			menuCall("", _cont);
		}
		
		if(scrollable) {
			if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) 
				toggleFunction(-sign(MOUSE_WHEEL));
		}
	}
}

function menuItemGroup(_name, _group, _hotkey = noone) { return new MenuItemGroup(_name, _group, _hotkey); }
function MenuItemGroup(_name, _group, _hotkey = noone) constructor {
	active	= true;
	name	= _name;
	group	= _group;
	hotkey  = _hotkey;
	params	= {};
	spr     = noone;
	
	hoykeyObject = noone;
	spacing      = ui(32);
	
	static setSpacing = function(_spacing) { spacing = _spacing; return self; }
}

function menuButton(_spr, _onClick, _tooltip = "", _step = noone) constructor {
	spr     = _spr;
	onClick = _onClick;
	tooltip = _tooltip;
	step    = _step;
}

function MenuItem_Sort(_name, _func, _spr = noone, _hotkey = noone, _toggle = noone, _params = noone) : MenuItem(_name, _func, _spr, _hotkey, _toggle, _params) constructor {
	
	sortAsc = false;
	spr     = [ THEME.arrow_24, 1 ];
	
	static toggleFunction = function() /*=>*/ {
		func[sortAsc? 0 : 1]();
		sortAsc = !sortAsc;
	}
	
	static getSpr = function() /*=>*/ {return [ THEME.arrow_24, sortAsc? 3 : 1 ]};
}

	////- Generators
	
function menuItems_get(_id) { 
	if(struct_has(PREFERENCES_MENUITEMS, _id))     return PREFERENCES_MENUITEMS[$ _id];
	if(variable_global_exists($"menuItems_{_id}")) return variable_global_get($"menuItems_{_id}");
	return []; 
}

function menuItems_gen(strs) {
	if(is_string(strs)) strs = menuItems_get(strs);
	var _menu = [];
	
	for( var i = 0, n = array_length(strs); i < n; i++ ) {
		var _s = strs[i];
		
		if(_s == -1)      { array_push(_menu, _s); continue; }
		if(is_string(_s)) { 
			if(struct_has(MENU_ITEMS, _s)) array_push(_menu, struct_get(MENU_ITEMS, _s)); 
			else if(struct_has(self, _s))  array_push(_menu, struct_get(self, _s)); 
			continue; 
		}
		
		if(!is_struct(_s) || !struct_has(MENUITEM_CONDITIONS, _s.cond)) continue;
		
		var _res = MENUITEM_CONDITIONS[$ _s.cond]();
		if(_res) array_append(_menu, menuItems_gen(_s.items));
	}
    
	return _menu;
}

	////- Actions

function menuCallGen(menu_id, _x = 0, _y = 0, align = fa_left) { return menuCall(menu_id, menuItems_gen(menu_id), _x, _y, align); }
function menuCall(menu_id = "", menu = [], _x = 0, _y = 0, align = fa_left) {
	if(array_empty(menu)) return noone;
	FOCUS_BEFORE = FOCUS;
	
	_x = _x == 0? mouse_mx + ui(4) : _x;
	_y = _y == 0? mouse_my + ui(4) : _y;
	
	var dia = dialogCall(o_dialog_menubox, _x, _y);
	
	if(menu_id != "" && ds_map_exists(CONTEXT_MENU_CALLBACK, menu_id)) {
		var callbacks = CONTEXT_MENU_CALLBACK[? menu_id];
		
		for( var i = 0, n = array_length(callbacks); i < n; i++ ) 
			array_append(menu, callbacks[i].populate());
	}
	
	dia.context  = self;
	dia.menu_id  = menu_id;
	dia.setMenu(menu, align);
	return dia;
}

function pieMenuCall(menu_id = "", _x = mouse_mx, _y = mouse_my, menu = []) {
	var dia = instance_create(_x, _y, o_pie_menu);
	if(menu_id != "" && ds_map_exists(CONTEXT_MENU_CALLBACK, menu_id)) {
		var callbacks = CONTEXT_MENU_CALLBACK[? menu_id];
		
		for( var i = 0, n = array_length(callbacks); i < n; i++ ) 
			array_append(menu, callbacks[i].populate());
	}
	
	dia.context = self;
	dia.menu_id = menu_id;
	dia.setMenu(menu);
	return dia;
}

function submenuCall(_data = undefined, menu = [], menu_id = "") {
	if(is_undefined(_data)) return menuCall(menu_id, menu);
	
	var _xx = _data.x - 1;
	var dia = instance_create_depth(_xx, _data.y, _data.depth - 1, o_dialog_menubox);
	dia.context = _data.context;
	dia.setMenu(menu);
	
	if(_xx + dia.dialog_w > WIN_W - ui(2))
		dia.dialog_x = _data._x - dia.dialog_w + ui(4);
	
	return dia;
}

function fileNameCall(path, onModify, _x = mouse_mx + 8, _y = mouse_my + 8) {
	var dia = dialogCall(o_dialog_file_name, _x, _y)
		.setModify(onModify)
		.setPath(string_trim_end(path, [ "\\", "/" ]) + "/");
	
	return dia;
}

function textboxCall(initText, onModify, _x = mouse_mx + 8, _y = mouse_my + 8) {
	return dialogCall(o_dialog_textbox, _x, _y).setModify(onModify).activate(initText);
}
