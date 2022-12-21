function string_to_array(str) {
	var amo = string_length(str);
	var arr = array_create(amo);
	for( var i = 0; i < amo; i++ )
		arr[i] = string_char_at(str, i + 1);
	return arr;
}