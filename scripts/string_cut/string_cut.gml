function string_cut(str, w, tail = "...", scale = 1) {
	var ww   = 0;
	var ind  = 1;
	var ss   = "";
	var _str = str;
	var tw = string_width(tail) * scale;
	if(string_width(str) <= w) return str;
	
	var amo = string_length(str);
	
	for( var i = 1, n = string_length(str); i <= n; i++ ) {
		var ch = string_char_at(str, i);
		
		if(string_width(ss + ch) + tw > w)
			return ss + tail;
			
		ss += ch;
	}
	
	return ss;
}

function string_cut_line(str, w) {
	var i  = 1;
	var ss = "";
	var ww = 0;
	
	while(i <= string_length(str) ) {
		var _chr = string_char_at(str, i);
		ss += _chr;
		
		ww += string_width(_chr);
		if(ww > w) {
			ww = 0;
			ss +=  "\n";
		}
		
		i++;
	}
	
	return ss;
}

function string_reduce(str) { 
	str = string_lower(str);
	str = string_replace_all(str, " ", "_"); 
	str = string_replace_all(str, "\\", ""); 
	str = string_replace_all(str, "/", ""); 
	str = string_replace_all(str, "'", ""); 
	
	return str;
}