function string_splice(str, delim) {
	var st = [];
	var ss = str;
	var sp;
	
	do {
		sp = string_pos(delim, ss);
		
		if(sp == 0) {
			if(ss != "") array_push(st, ss);
		} else {
			var _ss = string_copy(ss, 1, sp - 1);
			if(_ss != "") array_push(st, _ss);
		}
		ss = string_copy(ss, sp + 1, string_length(ss) - sp);
	} until(sp == 0);
	
	return st;
}