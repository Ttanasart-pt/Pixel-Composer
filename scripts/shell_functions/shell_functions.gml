function shellOpenExplorer(path) {
	var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
	path = string_replace_all(path, "/", "\\");
	shell_execute_async(_windir, path);	
}

function shell_execute(path, command, ref = noone) {
	INLINE
	
	var txt = $"{path} {command}";
	
	try {
		var res = ProcessExecute(txt);
		//if(global.PROC_ID == 0) noti_status("Execute shell complete", THEME.noti_icon_console,, ref);
	} catch(e) {
		//if(global.PROC_ID == 0) noti_warning($"Execute shell failed: {e}", THEME.noti_icon_console_failed, ref);
	}
	
	return res;
}

function shell_execute_async(path, command, ref = noone) {
	INLINE
	
	var txt = $"{path} {command}";
	
	try {
		var res = ProcessExecuteAsync(txt);
		//if(global.PROC_ID == 0) noti_status("Execute shell complete", THEME.noti_icon_console,, ref);
	} catch(e) {
		//if(global.PROC_ID == 0) noti_warning($"Execute shell failed: {e}", THEME.noti_icon_console_failed, ref);
	}
	
	return res;
}