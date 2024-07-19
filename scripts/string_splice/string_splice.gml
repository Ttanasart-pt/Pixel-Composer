function string_splice(str, delim = " ", keep = false, empty = true) {
	var st = [];
	var ss = str;
	var sp;
	if(!is_array(delim)) delim = [ delim ];
	
	while(1) {
		sp = 99999;
		var found = false;
		for( var i = 0, n = array_length(delim); i < n; i++ ) {
			var pos = string_pos(delim[i], ss);
			if(pos) {
				sp = min(sp, pos);
				found = true;
			}
		}
		
		if(!found) { //no delim left
			if(empty || string_length(ss)) array_push(st, ss);
			break;
		} else {
			var _ss = string_copy(ss, 1, keep? sp : sp - 1);
			if(empty || string_length(ss)) array_push(st, _ss);
		}
		
		ss = string_copy(ss, sp + 1, string_length(ss) - sp);
	} 
	
	return st;
}

function string_title(str) {
	str = string_replace_all(str, "_", " ");
	var ch = string_char_at(str, 1);
	    ch = string_upper(ch);
	var rs = string_copy(str, 2, string_length(str) - 1);
	return ch + rs;
}

function string_titlecase(str) {
	var ch = "", ind = 1, len = string_length(str);
	var tt = "";
	var sp = true;
	
	repeat(len) {
		ch = string_char_at(str, ind++);
		tt += sp? string_upper(ch) : ch;
		sp = ch == " ";
	}
	
	return tt;
}