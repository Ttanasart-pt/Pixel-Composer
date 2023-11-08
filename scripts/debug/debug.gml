#region counter
	globalvar DEBUG_COUNTER;
	DEBUG_COUNTER = ds_map_create();
	
	function __debug_counter(key) {
		if(ds_map_exists(DEBUG_COUNTER, key)) 
			DEBUG_COUNTER[? key]++;
		else 
			DEBUG_COUNTER[? key] = 1;
		print(key + ": " + string(DEBUG_COUNTER[? key]));
	}
#endregion

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

function log_message(title, str, icon = noone, flash = false, write = true) {
	if(TEST_ERROR) return;
	if(write) __log("[MESSAGE] ", string(title) + ": " + string(str));
	
	return noti_status(string(title) + ": " + string(str), icon, flash);
}

function log_warning(title, str, ref = noone) { 
	if(TEST_ERROR) return;
	__log("[WARNING] ", string(title) + ": " + string(str));
	
	return noti_warning(string(title) + ": " + string(str),, ref);
}

function log_crash(str) {
	if(TEST_ERROR) return;
	__log("[ERROR] ", string(str));
	
	return noti_error(string(str));
}

function log_newline() {
	var path = DIRECTORY + "log/log.txt";
	var f = file_text_open_write(path);
	file_text_writeln(f);
	file_text_close(f);
}

function log_clear() {
	var path = DIRECTORY + "log/log.txt";
	if(file_exists(path))
		file_delete(path);
}

function exception_print(e) {
	if(!is_struct(e) || !struct_has(e, "longMessage")) return string(e);
	
	var str = "\n\n==========  Crash log  ==========\n\n" + e.longMessage;	
	str += "\n\n========== Stack trace ==========\n\n";	
	
	for( var i = 0, n = array_length(e.stacktrace); i < n; i++ )
		str += e.stacktrace[i] + "\n"
	
	str += "\n\n========= Crash log end =========\n";	
	
	return str;
}

function setException() {
	exception_unhandled_handler(function(ex) {
		var path = string(DIRECTORY) + "prev_crash.pxc";
		if(!SAVING && !TESTING) SAVE_AT(PROJECT, path);
	
		var tt = "\n-------------------------- OH NO --------------------------\n\n";
		tt += "\n" + ex.longMessage;
		tt += "\n" + ex.script;
		tt += "\n-------------------------- STACK TRACE --------------------------\n\n";
		for( var i = 0, n = array_length(ex.stacktrace); i < n; i++ ) {
			tt += ex.stacktrace[i] + "\n";
		}
		tt += "\n---------------------------- :( ----------------------------\n";
		
		var path = DIRECTORY + "log/crash_log.txt";
		file_text_write_all(path, tt);
		clipboard_set_text(tt);
		show_debug_message(tt);
		
		ExecProcessFromArgVAsync(GetArgVFromProcid(ProcIdFromSelf())); //create new dialog

	    return 0;
	});
}
//setException();

function resetException() {
	exception_unhandled_handler(undefined);
}

function printCallStack(maxDepth = 32) {
	var stack = debug_get_callstack(maxDepth);
	
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
				_txt += $" line: {sp[1]}";
			print(_txt);
		}
	}
	print("")
}