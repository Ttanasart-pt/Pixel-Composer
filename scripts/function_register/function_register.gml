#region macros
	// gml_pragma("global", "__fnInit()");
	
	#macro ARG  new __fnArgument
	#macro CALL _args = []; for(i = 0; i < argument_count; i++) _args[i] = argument[i]; callStatusFunction
	
	function __fnArgument(name, def, fn = false) constructor {
		self.name = name;
		self.def  = def;
		self.fn   = fn;
	}
	
	globalvar CMD_FUNCTIONS; CMD_FUNCTIONS    = {};
	globalvar MENU_ITEMS; MENU_ITEMS       = {};
	globalvar FUNCTIONS; FUNCTIONS        = {};
	globalvar RECENT_COMMANDS; RECENT_COMMANDS  = [];
	global.FUNCTION_CALL_EVENT = { type: "null" };
	
	function __fnInit() {
		
		FUNCTIONS       = {};
		CMD_FUNCTIONS   = {};
		MENU_ITEMS      = {};
		RECENT_COMMANDS = [];
		
		__fnInit_Global();
		__fnInit_Panels();
		__fnInit_Preview();
		__fnInit_Inspector();
		__fnInit_Animation();
		__fnInit_Graph();
		__fnInit_Collection();
		__fnInit_Presets();
		__fnInit_Notification();
		__fnInit_Preview_Window();
		__fnInit_Nodes();
		
		__fnInit_Preference();
	}
#endregion

function registerFunction(_context, _name, _key, _mod, _action, _param = noone) { 
	return new functionObject(_context, _name, _key, _mod, _action, _param).getLname(); 
}

function registerLFunction(_context, _name, _key, _mod, _action, _param = noone) { 
	return new functionObject(_context, _name, _key, _mod, _action, _param); 
}

function functionObject(_context, _name, _key, _mod, _action, _param = noone) constructor {
	hotkey  = addHotkey(_context == ""? 0 : _context, _name, _key, _mod, _action, _param).setFn(self);
	
	tooltipContext = undefined;
	context = _context;
	name    = _name;
	comName = _name;
	Lname   = name;
	
	fn      = method(undefined, _action);
	params  = _param;
	hide    = false;
	
	fnName  = string_to_var2(_context, _name);
	menu    = noone;
	spr     = noone;
	
	FUNCTIONS[$ fnName]     = self;
	CMD_FUNCTIONS[$ fnName] = { action: _action, args: [] };
	
	static getLname = function() /*=>*/ {
		var elp = string_ends_with(name, "...");
		
		Lname = name;
		Lname = string_replace_all(Lname, ".",   ""  );
		var n = Lname;
		
		Lname = string_replace_all(Lname, "(",   ""  );
		Lname = string_replace_all(Lname, ")",   ""  );
		Lname = string_replace_all(Lname, " > ", "_" );
		Lname = string_replace_all(Lname, "/",   "_" );
		Lname = string_replace_all(Lname, " ",   "_" );
		
		Lname = __txt(Lname, n);
		if(elp) Lname += "...";
		return self;
	}
	
	static action = function(_dat = undefined) {
		if(!is_callable(fn)) return;
		var _res;
		
		if(!is_undefined(_dat)) {
			if(params != noone) _res = fn(params, _dat);
			else                _res = fn(_dat);
			
		} else {
			if(params != noone) _res = fn(params);
			else                _res = fn();
		}
		
		switch(tooltipContext ?? context) {
			case "Graph":     PANEL_GRAPH.setActionTooltip(Lname);     break;
			case "Preview":   PANEL_PREVIEW.setActionTooltip(Lname);   break;
			case "Animation": PANEL_ANIMATION.setActionTooltip(Lname); break;
		}
		
		return _res;
	}
	
	static setTContext    = function(_p) /*=>*/ { tooltipContext = _p; hotkey.tooltipContext = _p;   return self; }
	static setCommandName = function(_p) /*=>*/ { comName = _p;                                      return self; }
	static setSpr = function(_spr)       /*=>*/ { spr = _spr; if(menu) menu.spr = _spr;              return self; }
	static setArg = function(_args = []) /*=>*/ { CMD_FUNCTIONS[$ fnName] = { action, args: _args }; return self; }
	
	static setMenuAlt = function(_name, _id, _spr = noone, shelf = false) { 
		menu = menuItem(__txt(_name), method(self, action), _spr, [ context, name ], noone, params);
		menu.hoykeyObject = hotkey;
		if(shelf) menu.setIsShelf();
		MENU_ITEMS[$ _id] = menu;
		
		return self;
	}
	
	static setMenu = function(_id, _spr = noone, shelf = false, toggle = undefined) { 
		return setMenuName(_id, Lname, _spr, shelf, toggle);
	}
	
	static setMenuName = function(_id, _name, _spr = noone, shelf = false, toggle = undefined) { 
		menu = menuItem(_name, method(self, action), _spr, [ context, name ], noone, params);
		menu.hoykeyObject = hotkey;
		
		if(shelf) menu.setIsShelf();
		if(toggle != undefined) menu.setToggle(toggle);
		
		MENU_ITEMS[$ _id] = menu;
		
		return self;
	}
	
	static setActiveFn   = function(_fn)      { if(menu) menu.setActiveFn(_fn);     return self; }
	static setColorFn    = function(colrFn)   { if(menu) menu.getColor  = colrFn;   return self; }
	static setSpriteInd  = function(sprIndFn) { if(menu) menu.getSprInd = sprIndFn; return self; }
	static setToggle     = function(_togg)    { if(menu) menu.setToggle(_togg);     return self; }
	static setTooltip    = function(_tool)    { if(menu) menu.setTooltip(_tool);    return self; }
	static setScroll     = function()         { if(menu) menu.setScroll();          return self; }
	static setContext    = function(_c)       { if(menu) menu.setContext(_c);       return self; }
	
	static hidePalette = function() { hide = true; return self; }
}

function callStatusFunction(name) {
	INLINE
	var command = $"{name} {string_join_ext(",", _args)}";
	
	array_push(CMD, cmdLine(command, COLORS._main_text_sub));
	array_push(CMDIN, command);
}

function callFunction(name, args) {
	INLINE
	
	var _f = CMD_FUNCTIONS[$ name];
	call(_f.fn, args);
	
	return true;
}
	
function call(fn, args = undefined) {
	if(args == undefined) return fn();
	if(!is_array(args))   return fn(args);
	
	var a = args;
	switch(array_length(a)) {
		case  0 : return fn();
		case  1 : return fn(a[0]);
		case  2 : return fn(a[0], a[1]);
		case  3 : return fn(a[0], a[1], a[2]);
		case  4 : return fn(a[0], a[1], a[2], a[3]);
		case  5 : return fn(a[0], a[1], a[2], a[3], a[4]);
		case  6 : return fn(a[0], a[1], a[2], a[3], a[4], a[5]);
		case  7 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
		case  8 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
		case  9 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]);
		case 10 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
		case 11 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10]);
		case 12 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11]);
		case 13 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12]);
		case 14 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13]);
		case 15 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14]);
		case 16 : return fn(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15]);
	}
	
	return undefined;
}