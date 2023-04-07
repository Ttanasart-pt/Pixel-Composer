function shellOpenExplorer(path) {
	var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
	path = string_replace_all(path, "/", "\\");
	execute_shell(_windir, path);	
}