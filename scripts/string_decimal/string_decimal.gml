function string_decimal(str) {
	var neg = string_char_at(str, 1) == "-";
	if(neg) str = string_copy(str, 2, string_length(str) - 1);
	
	var dec = string_pos(".", str);
	var pre = string_copy(str, 1, dec - 1);
	var pos = string_copy(str, dec + 1, string_length(str) - dec);
	
	return (neg? "-" : "") + (dec? string_digits(pre) + "." + string_digits(pos) : string_digits(str));
}

function toNumber(str) {
	if(is_real(str)) return str;
	
	var expo = 0;
	if(string_pos("e", str)) {
		var pos = string_pos("e", str);
		expo = toNumber(string_copy(str, pos + 1, string_length(str) - pos));
	}
	
	str = string_replace_all(str, ",", ".");
	str = string_decimal(str);
	if(str == "") return 0;
	if(str == ".") return 0;
	if(str == "-") return 0;
	return real(str) * power(10, expo);
}