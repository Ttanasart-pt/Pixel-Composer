function shellOpenExplorer(path) {
	var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
	path = string_replace_all(path, "/", "\\");
	shell_execute(_windir, path);	
}

function shell_execute(path, command, ref = noone) {
	gml_pragma("forceinline");
	
	var txt = $"{path} {command}";
	noti_status(txt, THEME.noti_icon_console,, ref);
	
	try {
		var res = execute_shell(path, command);
		noti_status("Execute shell complete", THEME.noti_icon_console, COLORS._main_accent, ref);
	} catch(e) {
		noti_warning($"Execute shell failed: {e}", THEME.noti_icon_console_failed, COLORS._main_value_negative, ref);
	}
}