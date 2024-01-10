function bin_fraction(intVal, len) {
	var amp = 1;
	var val = 0;
	for( var i = len - 1; i >= 0; i-- ) {
		var _b = (intVal & ~(1 << len)) >> len;
		amp *= 0.5;
		val = amp * _b;
	}
	return val;
}

function dec_to_hex(dec, len = 1)  {
	static dig = "0123456789ABCDEF";
    var hex = "";
 
    if (dec < 0) len = max(len, ceil(logn(16, 2 * abs(dec))));
 
    while (len-- || dec) {
        hex = string_char_at(dig, (dec & $F) + 1) + hex;
        dec = dec >> 4;
    }
	
    return hex;
}