function isEqual(val1, val2) {
	if(!is_array(val1) && !is_array(val2)) return val1 == val2;
	if(is_array(val1) ^ is_array(val2)) return false;
	if(array_length(val1) != array_length(val2)) return false;
	
	for( var i = 0; i < array_length(val1); i++ ) {
		if(val1[i] != val2[i]) return false;
	}
	
	return true;
}