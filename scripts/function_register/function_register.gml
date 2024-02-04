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
		globalvar FUNCTIONS;
		FUNCTIONS = {};
		
		__registerFunction("NEW",		NEW,			[]);
		__registerFunction("SAVE_AT",	SAVE_AT,		[ ARG("project", function() { return PROJECT; }, true), ARG("path", ""), ARG("log", "save at ") ]);
		__registerFunction("LOAD_AT",	LOAD_AT,		[ ARG("path", ""), ARG("readonly", false), ARG("override", false) ]);
		__registerFunction("CLOSE",		closeProject,	[ ARG("project", function() { return PROJECT; }, true) ]);
		__registerFunction("APPEND",	APPEND,			[ ARG("path", ""), ARG("context", function() { return PANEL_GRAPH.getCurrentContext(); }, true) ]);
		
		__registerFunction("UNDO",		UNDO,			[]);
		__registerFunction("REDO",		REDO,			[]);
	}
#endregion

function __registerFunction(name, fn, args = []) { #region
	INLINE
	FUNCTIONS[$ name] = { fn, args };
} #endregion

function callStatusFunction(name) { #region
	INLINE
	var command = $"{name} {string_join_ext(",", _args)}";
	
	array_push(CMD, cmdLine(command, COLORS._main_text_sub));
	array_push(CMDIN, command);
} #endregion

function callFunction(name, args) { #region
	INLINE
	
	var _f = FUNCTIONS[$ name];
	
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
} #endregion
	
