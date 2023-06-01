function printBool(val) {
	if(!is_array(val)) return val? get_text("true", "True") : get_text("false", "False");
		
	var ss = "[";
	for( var i = 0; i < array_length(val); i++ ) {
		ss += (i? ", " : "") + printBool(val[i]);
	}
	
	ss += "]";
	return ss;
}