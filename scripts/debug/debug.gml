#region counter
	globalvar DEBUG_COUNTER;
	DEBUG_COUNTER = ds_map_create();
	
	function __count(key) {
		if(ds_map_exists(DEBUG_COUNTER, key)) 
			DEBUG_COUNTER[? key]++;
		else 
			DEBUG_COUNTER[? key] = 1;
		print(key + ": " + string(DEBUG_COUNTER[? key]));
	}
#endregion

function _log_template() {
	return string(current_year) + "/" + string(current_month) + "/" + string(current_day)
		+ " " + string(current_hour) + ":" + string(current_minute) + ":" + string(current_second)
		+ " > ";
}

function __log(title, str, fname = "log.txt") {
	var path = DIRECTORY + fname;
	var f = file_text_open_append(path);
	var t = _log_template();
	file_text_write_string(f, string(title) + t + string(str) + "\n");
	file_text_close(f);
}

function log_message(title, str, icon = noone, flash = false) {
	__log("[MESSAGE] ", string(title) + ": " + string(str));
	
	return noti_status(string(title) + ": " + string(str), icon, flash);
}

function log_warning(title, str, ref = noone) {
	__log("[WARNING] ", string(title) + ": " + string(str));
	
	return noti_warning(string(title) + ": " + string(str),, ref);
}

function log_crash(str) {
	__log("[ERROR] ", string(str));
	
	return noti_error(string(str));
}

function log_newline() {
	var path = DIRECTORY + "log.txt";
	var f = file_text_open_append(path);
	file_text_writeln(f);
	file_text_close(f);
}

function log_clear() {
	var path = DIRECTORY + "log.txt";
	if(file_exists(path))
		file_delete(path);
}

function exception_print(e) {
	var str = "\n\n==========  Crash log  ==========\n\n" + e.longMessage;	
	str += "\n\n========== Stack trace ==========\n\n";	
	
	for( var i = 0; i < array_length(e.stacktrace); i++ )
		str += e.stacktrace[i] + "\n"
	
	str += "\n\n========= Crash log end =========\n";	
	
	return str;
}

exception_unhandled_handler(function(ex) {
	var path = string(DIRECTORY) + "prev_crash.pxc";
	SAVE_AT(path);
	
	var tt = "\n-------------------------- OH NO --------------------------\n\n";
	tt += "\n" + ex.longMessage;
	tt += "\n" + ex.script;
	tt += "\n-------------------------- STACK TRACE --------------------------\n\n";
	for( var i = 0; i < array_length(ex.stacktrace); i++ ) {
		tt += ex.stacktrace[i] + "\n";
	}
	tt += "\n---------------------------- :( ----------------------------\n";
	
	var path = string(DIRECTORY) + "crash_log.txt";
	file_text_write_all(path, tt);
	clipboard_set_text(tt);
	show_debug_message(tt);
	
	var tt = "\n-------------------------- OH NO --------------------------\n\n";
	tt += ex.longMessage;
	tt += "\n---------------------------- :( ----------------------------\n";
	
	tt += "\n\nCrash log stored in clipboard and saved at " + path;
	tt += "\n\nRelaunch the program?";
	
	widget_set_caption("Pixel Composer crashed");
	widget_set_icon(DIRECTORY + "icon.png");
	
	if(show_question(tt)) {
		var path = executable_get_pathname();
		execute_shell(path, "--crashed");
	}
    return 0;
});