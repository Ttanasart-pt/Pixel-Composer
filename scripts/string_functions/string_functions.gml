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
		if(frac(val * p) == 0) break;
		p *= 10;
	}
	
	var _str = string_format(val, -1, pres);
	if(string_pos(".", _str)) _str = string_trim_end(_str, ["0"]);
	
	return _str;
}

function string_char_last(str, shift = 0) {
	INLINE
	return string_char_at(str, string_length(str) - shift);
}
	
function string_to_var(str) {
	str = string_lower(str);
	str = string_replace_all(str, " ", "_");
	str = string_replace_all(str, "/", "_");
	str = string_replace_all(str, "-", "_");
	str = string_replace_all(str, " > ", "_");
	
	return str;
}

function string_to_var2(context, name) { INLINE return string_to_var(context == ""? name : $"{context} {name}"); }
function string_quote(str)             { INLINE return $"\"{str}\""; }

function string_multiply(str, amo) { var s = ""; repeat(amo) s += str; return s; }

function string_compare(s1, s2) {
	    s1 = string_lower(s1);
	    s2 = string_lower(s2);
    var l1 = string_length(s1);
    var l2 = string_length(s2);
	var l  = min(l1, l2);
	
    var i = 1;
    var c1, c2;
	
    repeat(l) {
        c1 = string_char_at(s1, i);
        c2 = string_char_at(s2, i);
		i++;
		
        if(c1 == c2) continue;
        return ord(c1) - ord(c2);
    }

    return l1 - l2;
}

function string_compare_file(s1, s2) {
    s1 = string_lower(s1);
    s2 = string_lower(s2);
	
    if(string_digits(string_char_at(s1, 1)) != "" && string_digits(string_char_at(s2, 1)) != "") {
    	var n1 = toNumber(string_copy(s1, 1, string_pos(" ", s1) - 1));
    	var n2 = toNumber(string_copy(s2, 1, string_pos(" ", s2) - 1));
    	if(is_numeric(n1) && is_numeric(n2) && n1 != n2) return n1 - n2;
    }
	    
    var l1 = string_length(s1);
    var l2 = string_length(s2);
	var l  = min(l1, l2);
	
    var i = 1;
    var c1, c2;
	
    repeat(l) {
        c1 = string_char_at(s1, i);
        c2 = string_char_at(s2, i);
		i++;
		
        if(c1 == c2) continue;
        return ord(c1) - ord(c2);
    }

    return l1 - l2;
}

function array_to_string(arr) {
	if(!is_array(arr))   return string_real(arr);
	if(array_empty(arr)) return "[]";
	
	var s = "[";
	
	for (var i = 0, n = array_length(arr); i < n - 1; i++)
		s += array_to_string(arr[i]) + ", ";
	s += array_to_string(arr[i])
	
	return s + "]";
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function string_partial_match(str, key) {
	if(str == key) return 9999;
	var amo      = string_length(str);
	var keyAmo   = string_length(key);
	var run      = 1;
	var consec   = 0;
	var conMax   = 0;
	var misMatch = 0;
	var kchr     = string_char_at(key, 1);
	var ch;
	
	for( var i = 1; i <= amo; i++ ) {
		ch = string_char_at(str, i);
		
		if(ch == kchr) {
			consec++;
			conMax = max(conMax, consec);
			if(++run > keyAmo) return conMax - misMatch - (amo - i);
			kchr = string_char_at(key, run);
			
		} else {
			consec    = 0;
			misMatch += amo - i;
		}
		
	}
	
	return -9999;
}

function string_partial_match_res(str, key) {
	if(str == key) return [ 9999, array_create(string_length(str) + 1, 1) ];
	
	var lenn = string_length(str);
	var lenm = string_length(key);
	var runm = 1;
	
	var _matchw = -lenn * lenm;
	var _matRng = array_create(string_length(str) + 1, 0);
	var _mated  = array_create(string_length(str) + 1, 0);
	var  runn   = 1;
	var  runC   = 0;
	
	repeat(lenm) {
		var m = string_char_at(key, runm);
		
		var matc = -1;
		var matW =  0;
		
		repeat(lenn) {
			var n = string_char_at(str, runn);
			if(_mated[runn] == 0 && m == n) {
				 matc     = runn;
				_matchw  += lenn - matW + (matW == 0) * runC * 5;
				
				_mated[runn]  = 1;
				_matRng[runn] = 1;
				
				runC = matW == 0? runC + 1 : 0;
				if(++runn > lenn) runn = 1;
				break;
			}
			
			matW++;
			if(++runn > lenn) runn = 1;
		}
		
		if(matc == -1) { _matchw = -9999; break; }
		runm++
	}
	
	return [ _matchw, _matRng ];
}

function __string_partial_match_res(str, key, keys) {
	if(str == key) return [ 9999, array_create(string_length(str) + 1, 1) ];
	
	var _minmat = 9999;
	var _matRng = array_create(string_length(str) + 1, 0);
	
	for( var i = 0, n = array_length(keys); i < n; i++ ) {
		var _mat = string_partial_match_ext(str, keys[i], _matRng);
		_minmat = min(_minmat, _mat);
	}
	
	return [ _minmat, _matRng ];
}

function string_partial_match_ext(str, key, _matRng) {
	var amo      = string_length(str);
	var keyAmo   = string_length(key);
	var run      = 1;
	var consec   = 0;
	var conMax   = 0;
	var misMatch = 0;
	var kchr     = string_char_at(key, 1);
	var matRng   = array_create(string_length(str) + 1, 0);
	var ch;
	
	for( var i = 1; i <= amo; i++ ) {
		ch = string_char_at(str, i);
		
		if(ch == kchr) {
			matRng[i] = 1;
			consec++;
			conMax = max(conMax, consec);
			if(++run > keyAmo) {
				for( var j = 1; j <= amo; j++ )
					_matRng[j] |= matRng[j];
				
				return conMax - misMatch - (amo - i);
			}
			kchr = string_char_at(key, run);
			
		} else {
			consec    = 0;
			misMatch += amo - i;
		}
		
	}
	
	return -9999;
}

function draw_text_match(_x, _y, _text, _search, _scale = 1) {
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
	
	BLEND_ALPHA_MULP
	var aa = string_length(_text);
	var lw = string_width(_text) * _scale;
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
		
		if(_scale == 1) draw_text(ceil(xx), ceil(yy), ch);
		else            draw_text_transformed(ceil(xx), ceil(yy), ch, _scale, _scale, 0);
		xx += string_width(ch) * _scale;
		j++;
	}
	
	BLEND_NORMAL
	
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
	var spw    = string_width(" ");
	
	for( var i = 0; i < amo; i++ ) {
		var wr = words[i] + " ";
		var ww = string_width(wr);
		
		if(line_w + ww - spw > _w) {
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
	
	BLEND_ALPHA_MULP
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
			
			draw_text(ceil(xx), ceil(yy), ch);
			xx += string_width(ch);
			j++;
		}
		
		yy += lh;
	}
	BLEND_NORMAL
	
	draw_set_halign(ha);
	draw_set_valign(va);
	
	return hh;
}

function draw_text_match_range(_x, _y, _text, _range, _scale = 1) {
	INLINE
	_x = round(_x); 
	_y = round(_y);
	
	var xx = _x;
	var yy = _y;
	var ha = draw_get_halign();
	var cc = draw_get_color();
	
	draw_set_halign(fa_left);
	
	BLEND_ALPHA_MULP
	var aa = string_length(_text);
	var lw = string_width(_text) * _scale;
	
	switch(ha) {
		case fa_left :   xx = _x;			break;
		case fa_center : xx = _x - lw / 2;	break;
		case fa_right :  xx = _x - lw;		break;
	}
	
	var j = 1;
	repeat(aa) {
		var ch = string_char_at(_text, j);
		draw_set_color(_range[j]? COLORS._main_accent : cc);
		
		if(_scale == 1) draw_text(ceil(xx), ceil(yy), ch);
		else            draw_text_transformed(ceil(xx), ceil(yy), ch, _scale, _scale, 0);
		xx += string_width(ch) * _scale;
		j++;
	}
	
	BLEND_NORMAL
	
	draw_set_halign(ha);
}

function draw_text_match_range_ext(_x, _y, _text, _w, _range) {
	INLINE
	_x = round(_x);
	_y = round(_y);
	
	var lines  = [];
	var line   = "";
	var line_w = 0;
	var words  = string_split(_text, " ");
	var amo    = array_length(words);
	var spw    = string_width(" ");
	
	for( var i = 0; i < amo; i++ ) {
		var wr = words[i] + (i < amo - 1? " " : "");
		var ww = string_width(wr);
		
		if(line_w + ww - spw > _w) {
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
	
	switch(va) {
		case fa_top :    yy = _y;			break;
		case fa_middle : yy = _y - hh / 2;	break;
		case fa_bottom : yy = _y - hh;		break;
	}
	
	var _rind = 1;
	
	BLEND_ALPHA_MULP
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
			draw_set_color(_range[_rind++]? COLORS._main_accent : cc);
			
			draw_text(ceil(xx), ceil(yy), ch);
			xx += string_width(ch);
			j++;
		}
		
		yy += lh;
	}
	BLEND_NORMAL
	
	draw_set_halign(ha);
	draw_set_valign(va);
	
	return hh;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function string_full_match(str, key) {
	if(string_pos(key, str)) return 1;
	return -9999;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function string_count_start(str, char) {
	var i = 1;
	
	repeat(string_length(str)) {
		if(string_char_at(str, i) != char) return i - 1;
		i++;
	}
	
	return string_length(str);
}