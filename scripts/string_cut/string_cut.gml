function string_cut(str, w, tail = "...", scale = 1) {
	if(string_width(str) * scale <= w) return str;
	
	for( var i = string_length(str) - 1; i > 0; i-- ) {
		var subS = string_copy(str, 1, i) + tail;
		
		if(string_width(subS) * scale <= w)
			return subS;
	}
	
	return "";
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