function string_splice(str, delim) {
	var st = [];
	var ss = str;
	var sp;
	var wd = string_length(delim);
	
	do {
		sp = string_pos(delim, ss);
		
		if(sp == 0) { //no delim left
			array_push(st, ss);
			break;
		} else {
			var _ss = string_copy(ss, 1, sp - 1);
			array_push(st, _ss);
		}
		ss = string_copy(ss, sp + 1, string_length(ss) - sp);
	} until(sp == 0);
	
	return st;
}

function string_title(str) {
	var ch = string_char_at(str, 1);
	ch = string_upper(ch);
	var rs = string_copy(str, 2, string_length(str) - 1);
	return ch + rs;
}