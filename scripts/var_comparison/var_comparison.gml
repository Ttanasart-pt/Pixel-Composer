function isEqual(val1, val2, struct_expand = false) {
	gml_pragma("forceinline");
	
	if(is_array(val1) && is_array(val2))	return array_member_equal(val1, val2);
	if(struct_expand && is_struct(val1) && is_struct(val2))	return struct_equal(val1, val2);
	
	return val1 == val2;
}

function array_member_equal(arr1, arr2) {
	gml_pragma("forceinline");
	
	if(array_length(arr1) != array_length(arr2)) return false;
	
	for( var i = 0, n = array_length(arr1); i < n; i++ )
		if(!isEqual(arr1[i], arr2[i])) return false;
	
	return true;
}

function struct_equal(str1, str2) {
	gml_pragma("forceinline");
	
	//return json_stringify(str1) == json_stringify(str2);
	
	var key1 = variable_struct_get_names(str1);
	var key2 = variable_struct_get_names(str2);
	
	if(!array_equals(key1, key2)) return false;
	
	for( var i = 0, n = array_length(key1); i < n; i++ )
		if(!isEqual(str1[$ key1[i]], str2[$ key1[i]])) return false;
	
	return true;
}