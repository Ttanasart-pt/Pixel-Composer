function draw_text_cut(x, y, str, w) {
	draw_text(x, y, string_cut(str, w));
}

function string_cut(str, w, tail = "...") {
	var ww  = 0;
	var ind = 1;
	var ss  = "";
	
	while(ind <= string_length(str)) {
		var ch = string_char_at(str, ind);
		var _w = string_width(ch);
		
		if(ww + _w > w - 10) {
			ss += tail;
			break; 
		} else {
			ss += ch;
		}
		ww += _w;
		
		ind++;
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