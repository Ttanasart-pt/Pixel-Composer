date_set_timezone(timezone_utc);

function measure(func, header = "") {
	var t = current_time;
	func();
	show_debug_message($"{header} {t}ms");
}

function unix_time_to_string(_time, _format = "") {
	static month_names = ["January","February","March","April","May","June","July","August","September","October","November","December"];
	
	var _datetime = date_inc_second(date_create_datetime(1970, 1, 1, 0, 0, 0), _time);
	var day   = date_get_day(_datetime);
	var month = date_get_month(_datetime);
	var year  = date_get_year(_datetime);
	
	return $"{day} {month_names[month-1]} {year}";
	
	var days_since_epoch = floor(_time / 86400);
	
	var year = 1970;
	var days_in_year;
	while (true) {
	    days_in_year = 365 + (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
	    if (days_since_epoch < days_in_year) break;
	    days_since_epoch -= days_in_year;
	    year += 1;
	}
	
	var month_lengths = [31,28,31,30,31,30,31,31,30,31,30,31];
	if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) month_lengths[1] = 29;
	
	var month = 0;
	while (days_since_epoch >= month_lengths[month]) {
	    days_since_epoch -= month_lengths[month];
	    month += 1;
	}
	var day = days_since_epoch + 1;
	
	return $"{day} {month_names[month]} {year}";
}

function get_unix_time() { return date_second_span( date_create_datetime(1970, 1, 1, 0, 0, 0), date_current_datetime() ); }

function unix_time_get_string(_time) {
	var _secSince = get_unix_time() - _time;
	
	if(_secSince > 86400 * 2) return unix_time_to_string(_time, "{day} {month} {year}");
	if(_secSince > 86400)     return "yesterday";
	if(_secSince > 3600)      return string(floor(_secSince / 3600)) + " hours ago";
	if(_secSince > 60)        return string(floor(_secSince / 60)) + " minutes ago";
	
	return "just now";
}