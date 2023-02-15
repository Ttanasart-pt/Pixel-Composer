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