function shellOpenExplorer(path) {
	var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
	execute_shell_simple(_windir, path);	
}