function string_lead_zero(val, digit) {
	var len = string_length(string(val));
	var zer = digit - len;
	
	var ss = "";
	repeat(zer) ss += "0";
	ss += string(val);
	
	return ss;
}