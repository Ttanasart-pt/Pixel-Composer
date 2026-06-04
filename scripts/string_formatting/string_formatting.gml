function string_lead_zero(val, digit, _pad = "0") {
	var len = string_length(string(val));
	var zer = digit - len;
	
	var ss = "";
	repeat(zer) ss += _pad;
	ss += string(val);
	
	return ss;
}

function string_byte_format(bytes) {
	static suffix = [ "B", "KB", "MB", "GB", "TB" ];
	
	var _neg = bytes < 0;
	bytes = abs(bytes);
	
	var lv  = clamp(floor(log2(bytes) / 10), 0, array_length(suffix) - 1);
	var amo = bytes / power(2, lv * 10);
	
	return $"{_neg? "-":""}{amo} {suffix[lv]}"
}

function string_time_format(seconds) {
	seconds = round(seconds);

	var _neg = seconds < 0;
	seconds = abs(seconds);
	
	var hr = floor(seconds / 3600);
	var mn = floor((seconds - hr * 3600) / 60);
	var sc = floor(seconds - hr * 3600 - mn * 60);
	
	return $"{_neg? "-":""}{string_lead_zero(hr, 2)}:{string_lead_zero(mn, 2)}:{string_lead_zero(sc, 2)}";
}