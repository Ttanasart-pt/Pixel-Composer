function shellOpenExplorer(path) {
	var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
	path = string_replace_all(path, "/", "\\");
	shell_execute(_windir, path);	
}

function shell_execute(path, command, ref = noone) {
	gml_pragma("forceinline");
	
	noti_status($"{path} {command}", THEME.noti_icon_console, false, ref);
	execute_shell(path, command);
}