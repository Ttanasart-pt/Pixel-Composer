function __log(title, str) {
	var path = DIRECTORY + "log.txt";
	var f = file_text_open_append(path);
	var t = string(current_year) + "/" + string(current_month) + "/" + string(current_day)
		+ " " + string(current_hour) + ":" + string(current_minute) + ":" + string(current_second)
		+ " > ";
	file_text_write_string(f, string(title) + t + string(str) + "\n");
	file_text_close(f);
	
	show_debug_message(str);
}

function log_message(title, str) {
	__log("[MESSAGE] ", string(title) + " : " + string(str));
}

function log_warning(title, str) {
	__log("[WARNING] ", string(title) + " : " + string(str));
}

function log_crash(str) {
	__log("[ERROR] ", string(str));
}

function log_newline() {
	var path = DIRECTORY + "log.txt";
	var f = file_text_open_append(path);
	file_text_writeln(f);
	file_text_close(f);
}

exception_unhandled_handler(function(ex) {
	var tt = "\n-------------------------- OH NO --------------------------\n\n";
	tt += ex.longMessage;
	tt += "\n-------------------------- STACK TRACE --------------------------\n\n";
	for( var i = 0; i < array_length(ex.stacktrace); i++ ) {
		tt += ex.stacktrace[i] + "\n";
	}
	tt += "\n---------------------------- :( ----------------------------\n";
	log_crash(tt);
	log_message("SESSION", "Ended with error");
	
	var tt = "\n-------------------------- OH NO --------------------------\n\n";
	tt += ex.longMessage;
	tt += "\n---------------------------- :( ----------------------------\n";
	tt += "\nError message saved to clipboard";
	tt += "\n\nVisit crash log from " + string(DIRECTORY + "log.txt") + " for more information";
	show_error(tt, true);
	clipboard_set_text(tt);
    return 0;
});