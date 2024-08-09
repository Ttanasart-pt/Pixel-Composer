#region macros
	gml_pragma("global", "__fnInit()");
	
	#macro ARG  new __fnArgument
	#macro CALL _args = []; for(i = 0; i < argument_count; i++) _args[i] = argument[i]; callStatusFunction
	
	function __fnArgument(name, def, fn = false) constructor {
		self.name = name;
		self.def  = def;
		self.fn   = fn;
	}
	
	function __fnInit() {
		globalvar CMD_FUNCTIONS, ACTION_MAP;
		CMD_FUNCTIONS = {};
		ACTION_MAP    = {};
		
		__fnInit_Global();
		__fnInit_Preview();
		__fnInit_Inspector();
		__fnInit_Animation();
		__fnInit_Graph();
		__fnInit_Collection();
	}
#endregion

function registerFunction(_context, _name, _key, _mod, _action, _args = []) { 
	addHotkey(_context, _name, _key, _mod, _action);
	
	var _fnName = _context == ""? _name : $"{_context} {_name}";
		_fnName = string_to_var(_fnName);
		
	CMD_FUNCTIONS[$ _fnName] = { _action, _args };
	ACTION_MAP[$ _action]    = [ _context, _name ];
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
	
	switch(array_length(_f.args)) {
		case  0 : _f.fn();																																						break;
		case  1 : _f.fn(args[0]);																																				break;
		case  2 : _f.fn(args[0], args[1]);																																		break;
		case  3 : _f.fn(args[0], args[1], args[2]);																																break;
		case  4 : _f.fn(args[0], args[1], args[2], args[3]);																													break;
		case  5 : _f.fn(args[0], args[1], args[2], args[3], args[4]);																											break;
		case  6 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5]);																									break;
		case  7 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);																							break;
		case  8 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);																				break;
		case  9 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);																		break;
		case 10 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);																break;
		case 11 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);													break;
		case 12 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);											break;
		case 13 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);								break;
		case 14 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);						break;
		case 15 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);			break;
		case 16 : _f.fn(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);	break;
	}
	
	return true;
}
	
