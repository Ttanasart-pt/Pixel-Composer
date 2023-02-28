function string_to_array(str) {
	var amo = string_length(str);
	var arr = array_create(amo);
	for( var i = 0; i < amo; i++ )
		arr[i] = string_char_at(str, i + 1);
	return arr;
}

function string_partial_match(str, key) {
	var amo = string_length(str);
	var run = 1;
	var consec = 0;
	var conMax = 0;
	var misMatch = 0;
	var kchr = string_char_at(key, run);
	
	for( var i = 1; i <= amo; i++ ) {
		var ch = string_char_at(str, i);
		if(ch == kchr) {
			consec++;
			conMax = max(conMax, consec);
			run++;
			if(run > string_length(key)) return conMax - (misMatch + (amo - i));
			kchr = string_char_at(key, run);
		} else {
			consec = 0;
			misMatch += amo - i;
		}
	}
	
	return -9999;
}

function string_real(val, digMax = 999) {
	if(is_string(val)) return val;
	if(is_struct(val)) return string(val);
	
	if(is_array(val)) {
		var s = "[";
		for( var i = 0; i < array_length(val); i++ ) 
			s += (i? ", " : "") + string_real(val[i]);
		return s + "]";
	}
	
	if(val == 0) return "0";
	
	var pres, p = 1;
	var presMax = min(5, digMax - ceil(log10(ceil(abs(val)))));
	for( pres = 0; pres < presMax; pres++ ) {
		if(frac(val * p) == 0)
			break;
		p *= 10;
	}
	
	return string_format(val, -1, pres);
}

function filename_name_only(name) {
	name = filename_name(name);
	return string_replace(name, filename_ext(name), "")
}