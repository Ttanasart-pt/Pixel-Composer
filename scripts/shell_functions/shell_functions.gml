function shellOpenExplorer(path) {
	if(OS == os_windows) {
		var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
		path = string_replace_all(path, "/", "\\");
		shell_execute_async(_windir, path);	
		
	} else if(OS == os_macosx) {
		path = string_replace_all(path, "\\", "/");
		var res = shell_execute_async("open", path);
	} 
	
	return 0;
}

function shell_execute(path, command, ref = noone, _log = true) {
	INLINE
	
	if(OS == os_macosx) {
		path    = string_replace_all(path,    "\\", "/");
		command = string_replace_all(command, "\\", "/");
	}
	
	var txt = $"{path} {command}";
	var res = ProcessExecute(txt);
	if(_log) print($"Execute {path} {command} | {res}");
	
	return res;
}

function shell_execute_async(path, command, ref = noone, _log = true) {
	INLINE
	
	if(IS_CMD) return shell_execute(path, command, ref);
	
	if(OS == os_macosx) {
		path    = string_replace_all(path,    "\\", "/");
		command = string_replace_all(command, "\\", "/");
	}
	
	var txt = $"{path} {command}";
	var res = ProcessExecuteAsync(txt);
	if(_log) print($"Execute async {path} {command} | {res}");
	
	return res;
}
	
function env_user() {
	INLINE
	
	if(OS == os_windows) return string(environment_get_variable("userprofile")) + "/AppData/Local/PixelComposer/";
	if(OS == os_macosx)  return string(environment_get_variable("HOME")) + "/PixelComposer/";
	return "";
}