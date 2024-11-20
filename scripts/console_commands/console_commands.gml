globalvar CMD_COLOR;

CMD_COLOR = {
	HEADER  : "\033[95m",
    OKBLUE  : "\033[94m",
    OKCYAN  : "\033[96m",
    OKGREEN : "\033[92m",
    WARN    : "\033[93m",
    FAIL    : "\033[91m",
    ENDC    : "\033[0m",
    BOLD    : "\033[1m",
}

function cmd_error_param(command) {
	var _txt = $"[Error] `{command}` not enough argument."; 
	array_push(CMD, cmdLine(_txt, COLORS._main_value_negative) ); 
	log_console(_txt, true); 
}

function cmd_submit(command) {
	if(command == "") return noone;
	array_push(CMD, cmdLineIn(command));
	array_push(CMDIN, command);
	
	var raw = string_splice(command, " ", false, false);
	var opt = [];	
	var cmd = [];
	
	for( var i = 0, n = array_length(raw); i < n; i++ ) {
		var _c = string_trim(raw[i]);
		
		if(string_starts_with(_c, "-"))
			array_push(opt, _c);
		else
			array_push(cmd, _c);
	}
	
	var cmd_type = cmd[0];
	    
	switch(cmd_type) {
		case "flag": 
			if(array_length(cmd) < 2) { cmd_error_param(cmd_type); break; }
			
			var flg = cmd[1];
			global.FLAG[$ flg] = !global.FLAG[$ flg];
				
			var _txt = $"Toggled debug flag: {flg} = {global.FLAG[$ flg]? "True" : "False"}";
			array_push(CMD, cmdLine(_txt, COLORS._main_value_positive) );
			log_console(_txt, true);
			break;
		
		case "set":
			if(array_length(cmd) < 3) { cmd_error_param(cmd_type); break; }
			
			var key = string_trim(cmd[1]);
			var val = string_trim(cmd[2]);
			var glb = PROJECT.globalNode;
			
			if(glb.inputExist(key)) {
				for( var i = 0; i < array_length(glb.inputs); i++ ) {
					var _inp = glb.inputs[i];
					if(_inp.name != key) continue;
					
					if(_inp.type == VALUE_TYPE.text || _inp.type == VALUE_TYPE.path) {
						_inp.setValue(val);
						PROGRAM_ARGUMENTS[$ key] = val;
					} else {
						var v = evaluateFunction(val);
						_inp.setValue(v);
						PROGRAM_ARGUMENTS[$ key] = v;
					}
					break;
				}
			} else 
				PROGRAM_ARGUMENTS[$ key] = val;
			
			var _txt = $"Set global variable: {key} = {val}";
			array_push(CMD, cmdLine(_txt, COLORS._main_value_positive) );
			log_console(_txt, true);
			break;
		
		case "render":
			PROGRAM_ARGUMENTS._run       = true;
			PROGRAM_ARGUMENTS._rendering = true;
			CLI_EXPORT_AMOUNT            = 0;
			break;
		
		case "exit":
			game_end();
			break;
		
		case "print":
			if(array_length(cmd) < 2) { cmd_error_param(cmd_type); break; }
			print(cmd[1]);
			break;
		
		case "netlog":
			if(array_length(cmd) == 1) {
				for( var i = 0, n = array_length(NETWORK_LOG); i < n; i++ ) {
					var _log = NETWORK_LOG[i];
					print($"{_log.time} - {_log.txt}");
				}
				
			} else if(array_length(cmd) == 2) {
				var _key = cmd[1];
				if(!struct_has(NETWORK_LOG_DATA, _key)) {
					array_push(CMD, cmdLine($"[Error] netdat `{_key}` not found", COLORS._main_value_negative) );
					break;
				}
				
				print(NETWORK_LOG_DATA[$ _key]);
			}
			break;
			
		case "patreon":
			if(array_length(cmd) < 2) { cmd_error_param(cmd_type); break; }
			var _leg  = array_exists(opt, "-l");
			if(_leg) return new cmd_program_patreon_legacy(cmd[1]);
			break;
		
		default: 
			if(struct_has(CMD_FUNCTIONS, cmd[0])) {
				var _f    = CMD_FUNCTIONS[$ cmd[0]];
				var _vars = string_splice(array_safe_get_fast(cmd, 1, ""), ",");
				var _args = [];
					
				for( var i = 0, n = array_length(_f.args); i < n; i++ ) {
					var _arg = _f.args[i];
					var _def = _arg.fn? _arg.def() : _arg.def;
						
					if(i < array_length(_vars) && _vars[i] != "") {
						if(is_real(_def)) _args[i] = toNumber(_vars[i]);
						else              _args[i] = _vars[i];
					} else 
						_args[i] = _def;
				}
				
				callFunction(cmd[0], _args);
				cli_wait();
				break;
			}
			
			var _txt = $"[Error] \"{cmd_type}\" command not found.";
			array_push(CMD, cmdLine(_txt, COLORS._main_value_negative) );
			log_console(_txt, true);
			break;
	}
	
	return noone;
}

function cmd_path(path) {
	var params = string_splice(path, ";");
	var vals   = [];
			
	for( var j = 0, n = array_length(params); j < n; j++ ) {
		var _p = params[j];
				
		if(filename_drive(_p) == "") {
			array_push(vals, _p);
			continue;
		}
				
		var _f   = file_find_first(_p, 0);
		var _dir = filename_dir(_p) + "/";
					
		while (_f != "") {
			var _pf = _f;
					
			array_push(vals, _dir + _f);
					
			_f = file_find_next();
			if(_pf == _f) break;
		}
					
		file_find_close();
	}
	
	return vals;
}

function cmd_program() constructor {
	title   = "cmd";
	color   = CDEF.main_dkgrey;
	
	static close = function() { CMDPRG = noone; }
	
	static submit = function(arg) { return 0; }
}