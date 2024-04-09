function string_lead_zero(val, digit) {
	var len = string_length(string(val));
	var zer = digit - len;
	
	var ss = "";
	repeat(zer) ss += "0";
	ss += string(val);
	
	return ss;
}

function string_byte_format(bytes) {
	static suffix = [ "B", "KB", "MB", "GB", "TB" ];
	
	var lv  = clamp(floor(log2(bytes) / 10), 0, array_length(suffix) - 1);
	var amo = bytes / power(2, lv * 10);
	
	return $"{amo} {suffix[lv]}"
}