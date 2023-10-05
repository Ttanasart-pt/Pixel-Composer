function string_variable_valid(str) {
	static valid_char = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
	
	for( var i = 1; i <= string_length(str); i++ ) {
		var cch = string_char_at(str, i);
		if(string_pos(cch, valid_char) == 0) return false;
	}
	
	return true;
}

function string_decimal(str) {
	var neg = string_char_at(str, 1) == "-";
	if(neg) str = string_copy(str, 2, string_length(str) - 1);
	
	var dec = string_pos(".", str);
	if(dec == 0)  return (neg? "-" : "") + string_digits(str);
		
	var pre = string_copy(str, 1, dec - 1);
	var pos = string_copy(str, dec + 1, string_length(str) - dec);
	
	return (neg? "-" : "") + string_digits(pre) + "." + string_digits(pos);
}

function toNumberFast(str) {
	gml_pragma("forceinline");
	
	var r = real(str);
	if(is_real(r)) return r;
	return 0;
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