#region macros
	// gml_pragma("global", "__fnInit()");
	
	#macro ARG  new __fnArgument
	#macro CALL _args = []; for(i = 0; i < argument_count; i++) _args[i] = argument[i]; callStatusFunction
	
	function __fnArgument(name, def, fn = false) constructor {
		self.name = name;
		self.def  = def;
		self.fn   = fn;
	}
	
	globalvar CMD_FUNCTIONS, MENU_ITEMS, FUNCTIONS, RECENT_COMMANDS;
	
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
		
		__fnInit_Preference();
	}
	
#endregion

function registerFunctionLite(_context, _name, _action, _param = noone) { return new functionObjectLite(_context, _name, _action, _param); }
function functionObjectLite(_context, _name, _action, _param = noone) constructor {
	context  = _context;
	name     = _name;
	action   = method(undefined, _action);
	params   = _param;
	fnName   = string_to_var2(_context, _name);
	menu     = noone;
	spr      = noone;
	
	FUNCTIONS[$ fnName]     = self;
}
	
function registerFunction(_context, _name, _key, _mod, _action, _param = noone) { return new functionObject(_context, _name, _key, _mod, _action, _param); }
function functionObject(_context, _name, _key, _mod, _action, _param = noone) constructor {
	hotkey   = addHotkey(_context == ""? 0 : _context, _name, _key, _mod, _action);
	context  = _context;
	name     = _name;
	dkey     = _key;
	dmod     = _mod;
	action   = method(undefined, _action);
	params   = _param;
	hide     = false;
	
	fnName   = string_to_var2(_context, _name);
	menu     = noone;
	spr      = noone;
	
	FUNCTIONS[$ fnName]     = self;
	CMD_FUNCTIONS[$ fnName] = { action: _action, args: [] };
	
	static setArg = function(_args = []) { CMD_FUNCTIONS[$ fnName] = { action, args: _args }; return self; }
	
	static setMenuAlt = function(_name, _id, _spr = noone, shelf = false) { 
		menu = menuItem(__txt(_name), action, _spr, [ context, name ]);
		menu.hoykeyObject = hotkey;
		if(shelf) menu.setIsShelf();
		MENU_ITEMS[$ _id] = menu;
		
		return self;
	}
	
	static setMenu = function(_id, _spr = noone, shelf = false) { 
		menu = menuItem(__txt(name), action, _spr, [ context, name ]);
		menu.hoykeyObject = hotkey;
		if(shelf) menu.setIsShelf();
		MENU_ITEMS[$ _id] = menu;
		
		return self;
	}
	
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
	
function call(fn, args) {
	if(!is_array(args)) {
		fn();
		return;
	}
	
	switch(array_length(args)) {
		case  0 : fn();																																						break;
		case  1 : fn(args[0]);																																				break;
		case  2 : fn(args[0], args[1]);																																		break;
		case  3 : fn(args[0], args[1], args[2]);																															break;
		case  4 : fn(args[0], args[1], args[2], args[3]);																													break;
		case  5 : fn(args[0], args[1], args[2], args[3], args[4]);																											break;
		case  6 : fn(args[0], args[1], args[2], args[3], args[4], args[5]);																									break;
		case  7 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);																						break;
		case  8 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);																				break;
		case  9 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);																		break;
		case 10 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);																break;
		case 11 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);													break;
		case 12 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);											break;
		case 13 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);								break;
		case 14 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);						break;
		case 15 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);			break;
		case 16 : fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);	break;
	}
}