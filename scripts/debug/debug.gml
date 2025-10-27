#region counter
	globalvar DEBUG_COUNTER;
	DEBUG_COUNTER = ds_map_create();
	
	var _p = $"D:/Project/MakhamDev/LTS-PixelComposer/MISC/temp/";
	if(directory_exists(_p)) directory_destroy(_p);
	
	#macro printlog if(log) show_debug_message
#endregion

function printDebug(t) { show_debug_message(t); __log("", t); }

function print(str) { 
	var _s = "";
	for(var i = 0; i < argument_count; i++)
		_s += (i? ", " : "") + string(argument[i]);
	
	noti_status(_s); 
}

function printSurface(name, surface) { 
	if(!is_surface(surface)) { noti_status($"{name}|Error: Not a valid surface {surface}"); return; }
	
	var _p = $"D:/Project/MakhamDev/LTS-PixelComposer/MISC/temp/{UUID_generate()}.png";
	surface_save_safe(surface, _p);
	noti_status($"{name}|texture|{_p}"); 
}

function printIf(cond, log) { if(cond) print(log); }

function __debug_counter(key) {
	if(ds_map_exists(DEBUG_COUNTER, key)) DEBUG_COUNTER[? key]++;
	else                                  DEBUG_COUNTER[? key] = 1;
	print($"{key}: {DEBUG_COUNTER[? key]}");
}

function _log_template() {
	INLINE
	return $"{current_year}/{current_month}/{current_day} {string_lead_zero(current_hour, 2)}:{string_lead_zero(current_minute, 2)}:{string_lead_zero(current_second, 2)} > ";
}

function __log(title, str, fname = "log/log.txt") {
	var path = DIRECTORY + fname;
	var f = file_text_open_append(path);
	var t = _log_template();
	file_text_write_string(f, $"{title}{t}{str}\n");
	file_text_close(f);
}

function log_console(str, wait = false) {
	INLINE
	show_debug_message($"CLI: {str}"); 
	if(wait) cli_wait();
	return;
}

function cli_wait() { INLINE show_debug_message("WAIT"); return; }

function log_message(title, str, icon = noone, flash = false, write = true) {
	if(TEST_ERROR) return;
	if(IS_CMD)     { show_debug_message($"{title}: {str}"); return; }
	
	if(write) __log("[MESSAGE] ", $"{title}: {str}");
	return noti_status($"{title}: {str}", icon, flash);
}

function log_warning(title, str, ref = noone) {
	if(TEST_ERROR) return;
	if(IS_CMD)     { show_debug_message($"{title}: {str}"); return; }
	
	__log("[WARNING] ", $"{title}: {str}");
	return noti_warning($"{title}: {str}",, ref);
}

function log_crash(str) {
	if(TEST_ERROR) return;
	if(IS_CMD)     { show_debug_message($"{title}: {str}"); return; }
	
	__log("[ERROR] ", str);
	return noti_error(str);
}

function log_newline() {
	var path = DIRECTORY + "log/log.txt";
	var f = file_text_open_write(path);
	file_text_writeln(f);
	file_text_close(f);
}

function log_clear() {
	var path = DIRECTORY + "log/log.txt";
	if(file_exists_empty(path))
		file_delete(path);
}

function os_type_sting() {
	switch(os_type) {
		case os_windows : return "Windows";
		case os_macosx  : return "MacOS";
		case os_linux   : return "Linux";
	}
	
	return "undefined";
}

function exception_print(e) {
	if(!is_struct(e) || !struct_has(e, "longMessage")) return string(e);
	if(!code_is_compiled()) return $"ERR:{json_stringify(e)}";
	
	var str = $"\n\n==========  Crash log [PXC {VERSION_STRING}] [{os_type_sting()}] ==========";
	str += $"\n\n{e.longMessage}";
	str += "\n\n========== Stack trace ==========\n\n";	
	
	for( var i = 0, n = array_length(e.stacktrace); i < n; i++ )
		str += e.stacktrace[i] + "\n"
	
	str += "\n\n========= Crash log end =========\n";	
	
	return str;
}

function setException() {
	if(OS == os_macosx) return noone;
	
	exception_unhandled_handler(function(ex) {
		var path = $"{DIRECTORY}prev_crash.pxc";
		if(!SAVING && !TESTING && !IS_CMD) SAVE_AT(PROJECT, path);
		
		var tt = "";
		tt += $"\n-------------------------- Pixel Composer {VERSION_STRING} Crashed --------------------------\n";
		tt += $"\n{ex.longMessage}";
		tt += $"\n{ex.script}";
		
		tt += "\n\n-------------------------- STACK TRACE --------------------------\n\n";
		for( var i = 0, n = array_length(ex.stacktrace); i < n; i++ )
			tt += $"{ex.stacktrace[i]}\n";
			
		tt += "\n\n\n\n-------------------------- Device Info --------------------------\n";
		tt += $"\nVersion: {VERSION_STRING} ({VERSION})";
		tt += $"\nOperating system: {os_type_sting()} ({os_version})"
		tt += "\n\n---------------------------- :( ----------------------------\n";
		
		var path_pro = $"{env_user()}log/program_path.txt";
		var path_log = $"{env_user()}log/crash_log.txt";
		var path_crashed = $"{env_user()}log/crashed.txt";
		
		file_text_write_all(path_pro, program_directory);
		file_text_write_all(path_log, tt);
		file_text_write_all(path_crashed, "");
		clipboard_set_text(tt);
		
		if(IS_CMD) {
			show_debug_message($"[ERROR BEGIN]\n{tt}\n[ERROR END]");
			return 0;
		} else show_debug_message($"ERR:{json_stringify(ex)}");
		
		var rep = $"{APP_LOCATION}report/PXC crash reporter.exe";
		var pid = shell_execute(rep, DIRECTORY);
		print($"{rep} [{file_exists(rep)}]: {pid}");
		
	    return 0;
	});
}

function resetException() { exception_unhandled_handler(undefined); }

function printCallStack(maxDepth = 32) {
	var stack = debug_get_callstack(maxDepth);
	var text  = "";
	
	print($"Call Stack:");
	for( var i = 2, n = array_length(stack) - 1; i < n; i++ ) {
		var call = stack[i];
		var sp   = string_splice(call, ":");
		if(array_length(sp) < 2) continue;
		
		sp[0] = string_replace_all(sp[0], "anon_", "");
		sp[0] = string_split(sp[0], "gml_", true);
		
		for( var j = 0, m = array_length(sp[0]); j < m; j++ ) {
			sp[0][j] = string_replace(sp[0][j], "GlobalScript_", "Global: ");
			sp[0][j] = string_replace(sp[0][j], "Script_", "Script: ");
			sp[0][j] = string_replace(sp[0][j], "Object_", "Object: ");
			
			sp[0][j] = string_trim(sp[0][j], ["_"]);
			
			var _txt = "";
			repeat(j * 4) _txt += " ";
			
			_txt += $"     > {sp[0][j]}";
			if(j == m - 1) 
				_txt += $" line: {sp[1] - 1}";
			text += _txt + "\n";
		}
	}
	print(text);
}