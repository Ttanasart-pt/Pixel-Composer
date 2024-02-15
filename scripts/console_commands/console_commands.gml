globalvar CMD_COLOR;

CMD_COLOR = {
	HEADER  : "\033[95m",
    OKBLUE  : "\033[94m",
    OKCYAN  : "\033[96m",
    OKGREEN : "\033[92m",
    WARNING : "\033[93m",
    FAIL    : "\033[91m",
    ENDC    : "\033[0m",
    BOLD    : "\033[1m",
}

function cmd_submit(command) { #region
	if(command == "") return;
	array_push(CMD, cmdLineIn(command));
	array_push(CMDIN, command);
		
	var cmd = string_splice(command, " ", false, false);
	var cmd_type = cmd[0];
	    cmd_type = string_trim(cmd_type);
	
	switch(cmd_type) {
		case "f": 
		case "flag": 
			if(array_length(cmd) < 2) {
				var _txt = $"[Error] `flag` not enough argument.";
				array_push(CMD, cmdLine(_txt, COLORS._main_value_negative) );
				log_console(_txt, true);
				break;
			}
			var flg = cmd[1];
			global.FLAG[$ flg] = !global.FLAG[$ flg];
				
			var _txt = $"Toggled debug flag: {flg} = {global.FLAG[$ flg]? "True" : "False"}";
			array_push(CMD, cmdLine(_txt, COLORS._main_value_positive) );
			log_console(_txt, true);
			break;
		
		case "s":
		case "set":
			if(array_length(cmd) < 3) {
				var _txt = $"[Error] `set` not enough argument.";
				array_push(CMD, cmdLine(_txt, COLORS._main_value_negative) );
				log_console(_txt, true);
				break;
			}
			
			var key = string_trim(cmd[1]);
			var val = string_trim(cmd[2]);
			var glb = PROJECT.globalNode;
			
			if(glb.inputExist(key)) {
				for( var i = 0; i < ds_list_size(glb.inputs); i++ ) {
					var _inp = glb.inputs[| i];
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
		
		case "r":
		case "render":
			PROGRAM_ARGUMENTS._run       = true;
			PROGRAM_ARGUMENTS._rendering = true;
			CLI_EXPORT_AMOUNT            = 0;
			break;
		
		case "x":
		case "exit":
			game_end();
			break;
		
		default: 
			if(struct_has(FUNCTIONS, cmd[0])) {
				var _f    = FUNCTIONS[$ cmd[0]];
				var _vars = string_splice(array_safe_get(cmd, 1, ""), ",");
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
} #endregion

function cmd_path(path) { #region
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
} #endregion