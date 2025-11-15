globalvar VALID_VAR; VALID_VAR     = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
globalvar VALID_VAR_MAP; VALID_VAR_MAP = {};
	
for( var i = 1; i <= string_length(VALID_VAR); i++ ) {
	var cch = string_char_at(VALID_VAR, i);
	VALID_VAR_MAP[$ cch] = 1;
}
	
function string_variable_valid(str) {
	for( var i = 1; i <= string_length(str); i++ ) {
		var cch = string_char_at(str, i);
		if(!has(VALID_VAR_MAP, cch)) return false;
	}
	
	return true;
}

function string_decimal(str, _strict = true) {
	var neg = string_char_at(str, 1) == "-";
	if(neg) str = string_copy(str, 2, string_length(str) - 1);
	
	var dec = string_pos(".", str);
	if(dec == 0)  return (neg? "-" : "") + string_digits(str);
		
	var pre = string_copy(str, 1, dec - 1);
	var pos = string_copy(str, dec + 1, string_length(str) - dec);
	
	var spre = string_digits(pre); 
	var spos = string_digits(pos); 
	
	if(!_strict) {
		if(spre == "") spre = "0";
		if(spos == "") spos = "0";
	}
	
	return $"{neg? "-" : ""}{spre}.{spos}";
}

function toNumber(str) {
	if(is_numeric(str)) return str;
	try { return real(str); } catch(e) {}
	return 0;
}

function toNumberFull(str) {
	if(is_real(str))   return str;
	
	var expo = 0;
	if(string_pos("e", str)) {
		var pos = string_pos("e", str);
		var exs = string_copy(str, pos + 1, string_length(str) - pos)
		if(exs != "") expo = real(exs);
		str  = string_copy(str, 1, pos - 1);
	}
	
	str = string_decimal(str);
	if(str == "")  return 0;
	if(str == ".") return 0;
	if(str == "-") return 0;
	
	return real(str) * power(10, expo);
}

function isNumber(str) {
	if(is_real(str)) return true;
	str = string_trim(str);
	return str == string_decimal(str);
}