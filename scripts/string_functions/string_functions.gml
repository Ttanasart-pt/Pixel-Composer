function string_to_array(str) {
	var amo = string_length(str);
	var arr = array_create(amo);
	for( var i = 0; i < amo; i++ )
		arr[i] = string_char_at(str, i + 1);
	return arr;
}

function string_real(val, digMax = 999, decMin = 5) {
	if(is_string(val)) return val;
	if(is_struct(val)) return string(val);
	
	if(is_array(val)) {
		var s = "[";
		var i = 0, n = array_length(val);
		repeat( n ) { s += (i? ", " : "") + string_real(val[i]); i++; }
		return s + "]";
	}
	
	if(val == 0 || is_handle(val) || !is_numeric(val)) return "0";
	
	var pres, p = 1;
	var presMax = min(decMin, digMax - ceil(log10(ceil(abs(val)))));
	for( pres = 0; pres < presMax; pres++ ) {
		if(frac(val * p) == 0)
			break;
		p *= 10;
	}
	
	return string_format(val, -1, pres);
}

function string_char_last(str, shift = 0) {
	INLINE
	return string_char_at(str, string_length(str) - shift);
}

function filename_name_only(name) {
	name = filename_name(name);
	return string_replace(name, filename_ext(name), "")
}
	
function string_to_var(str) { INLINE return string_replace_all(string_lower(str), " ", "_"); }
function string_quote(str)  { INLINE return $"\"{str}\""; }

function array_to_string(arr) {
	if(!is_array(arr))   return string(arr);
	if(array_empty(arr)) return "[]";
	
	var s = "[";
	
	for (var i = 0, n = array_length(arr); i < n - 1; i++)
		s += array_to_string(arr[i]) + ", ";
	s += array_to_string(arr[i])
	
	return s + "]";
}

function string_partial_match(str, key) {
	var amo      = string_length(str);
	var run      = 1;
	var consec   = 0;
	var conMax   = 0;
	var misMatch = 0;
	var kchr     = string_char_at(key, run);
	var ch;
	var stArr    = [];
	
	for( var i = 1; i <= amo; i++ ) {
		ch = string_char_at(str, i);
		
		if(ch == kchr) {
			consec++;
			conMax = max(conMax, consec);
			run++;
			if(run > string_length(key)) return conMax - misMatch;
			kchr = string_char_at(key, run);
			
		} else {
			consec    = 0;
			misMatch += amo - i;
		}
		
	}
	
	return -9999;
}

function draw_text_match(_x, _y, _text, _search) {
	INLINE
	_x = round(_x);
	_y = round(_y);
	
	var ha = draw_get_halign();
	var xx = _x;
	var yy = _y;
	var cc = draw_get_color();
	
	draw_set_halign(fa_left);
	_search = string_lower(_search);
	
	var keylen   = string_length(_search);
	var run      = 1;
	var kchr     = string_char_at(_search, 1);
	
	BLEND_ALPHA_MULP;
	var aa = string_length(_text);
	var lw = string_width(_text);
	var tl = string_lower(_text);
	
	switch(ha) {
		case fa_left :   xx = _x;			break;
		case fa_center : xx = _x - lw / 2;	break;
		case fa_right :  xx = _x - lw;		break;
	}
	
	var j = 1;
	repeat(aa) {
		var ch = string_char_at(_text, j);
		var cl = string_char_at(tl, j);
		
		if(run > 0 && cl == kchr) {
			run++;
			if(run > keylen) run = 0;
			kchr = string_char_at(_search, run);
			draw_set_color(COLORS._main_accent);
		} else 
			draw_set_color(cc);
		
		draw_text(xx, yy, ch);
		xx += string_width(ch);
		j++;
	}
	
	BLEND_NORMAL;
	
	draw_set_halign(ha);
}

function draw_text_match_ext(_x, _y, _text, _w, _search) {
	INLINE
	_x = round(_x);
	_y = round(_y);
	
	var lines  = [];
	var line   = "";
	var line_w = 0;
	var words  = string_split(_text, " ");
	var amo    = array_length(words);
	
	for( var i = 0; i < amo; i++ ) {
		var wr = words[i] + " ";
		var ww = string_width(wr);
		
		if(line_w + ww > _w) {
			array_push(lines, line);
			line   = wr;
			line_w = ww;
			
		} else {
			line   += wr;
			line_w += ww;
		}
	}
	
	if(line != "") array_push(lines, line);
	
	var ha = draw_get_halign();
	var va = draw_get_valign();
	var xx = _x;
	var yy = _y;
	var lh = line_get_height();
	var hh = lh * array_length(lines);
	var cc = draw_get_color();
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	_search = string_lower(_search);
	
	var keylen   = string_length(_search);
	var run      = 1;
	var kchr     = string_char_at(_search, 1);
	
	switch(va) {
		case fa_top :    yy = _y;			break;
		case fa_middle : yy = _y - hh / 2;	break;
		case fa_bottom : yy = _y - hh;		break;
	}
	
	BLEND_ALPHA_MULP;
	for( var i = 0, n = array_length(lines); i < n; i++ ) {
		var ll = lines[i];
		var aa = string_length(ll);
		var lw = string_width(ll);
		var tl = string_lower(ll);
		
		switch(ha) {
			case fa_left :   xx = _x;			break;
			case fa_center : xx = _x - lw / 2;	break;
			case fa_right :  xx = _x - lw;		break;
		}
		
		var j = 1;
		repeat(aa) {
			var ch = string_char_at(ll, j);
			var cl = string_char_at(tl, j);
		
			if(run > 0 && cl == kchr) {
				run++;
				if(run > keylen) run = 0;
				kchr = string_char_at(_search, run);
				draw_set_color(COLORS._main_accent);
			} else 
				draw_set_color(cc);
			
			draw_text(xx, yy, ch);
			xx += string_width(ch);
			j++;
		}
		
		yy += lh;
	}
	BLEND_NORMAL;
	
	draw_set_halign(ha);
	draw_set_valign(va);
	
	return hh;
}