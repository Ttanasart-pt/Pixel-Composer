function shellOpenExplorer(path) { #region
	if(OS == os_windows) {
		var _windir = environment_get_variable("WINDIR") + "/explorer.exe";
		path = string_replace_all(path, "/", "\\");
		shell_execute_async(_windir, path);	
	} else if(OS == os_macosx) {
		path = string_replace_all(path, "\\", "/");
		var res = shell_execute_async("open", path);
	} 
} #endregion

function shell_execute(path, command, ref = noone) { #region
	INLINE
	
	if(OS == os_macosx) {
		path    = string_replace_all(path,    "\\", "/");
		command = string_replace_all(command, "\\", "/");
	}
	
	var txt = $"{path} {command}";
	var res = ProcessExecute(txt);
	print($"Execute {path} {command} | {res}");
	
	return res;
} #endregion

function shell_execute_async(path, command, ref = noone) { #region
	INLINE
	
	if(OS == os_macosx) {
		path    = string_replace_all(path,    "\\", "/");
		command = string_replace_all(command, "\\", "/");
	}
	
	var txt = $"{path} {command}";
	var res = ProcessExecuteAsync(txt);
	print($"Execute async {path} {command} | {res}");
	
	return res;
} #endregion
	
function env_user() { #region
	INLINE
	
	if(OS == os_windows) return string(environment_get_variable("userprofile")) + "\\AppData\\Local\\PixelComposer\\";
	if(OS == os_macosx)  return string(environment_get_variable("HOME")) + "/PixelComposer/";
	return "";
} #endregion