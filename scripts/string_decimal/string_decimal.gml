function string_decimal(str) {
	var neg = string_char_at(str, 1) == "-";
	if(neg) str = string_copy(str, 2, string_length(str) - 1);
	
	var dec = string_pos(".", str);
	if(dec == 0)  return (neg? "-" : "") + string_digits(str);
		
	var pre = string_copy(str, 1, dec - 1);
	var pos = string_copy(str, dec + 1, string_length(str) - dec);
	
	return (neg? "-" : "") + string_digits(pre) + "." + string_digits(pos);
}

function toNumber(str) {
	gml_pragma("forceinline");
	if(is_real(str))   return str;
	if(!isNumber(str)) return 0;
	
	var expo = 0;
	if(string_pos("e", str)) {
		var pos = string_pos("e", str);
		expo = real(string_copy(str, pos + 1, string_length(str) - pos));
	}
	
	str = string_replace_all(str, ",", ".");
	str = string_decimal(str);
	if(str == "") return 0;
	if(str == ".") return 0;
	if(str == "-") return 0;
	return real(str) * power(10, expo);
}

function isNumber(str) {
	if(is_real(str)) return true;
	str = string_trim(str);
	return str == string_decimal(str);
}