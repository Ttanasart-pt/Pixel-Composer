function draw_text_cut(x, y, str, w, scale = 1) {
	draw_text_transformed(x, y, string_cut(str, w,, scale), scale, scale, 0);
}

function string_cut(str, w, tail = "...", scale = 1) {
	var ww  = 0;
	var ind = 1;
	var ss  = "";
	var tw = string_width(tail);
	if(string_width(str) <= w) return str;
	
	while(ind <= string_length(str)) {
		var ch = string_char_at(str, ind);
		var _w = string_width(ch) * scale;
		
		if(ww + _w + tw >= w) {
			ss += tail;
			break;
		} else
			ss += ch;
		
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