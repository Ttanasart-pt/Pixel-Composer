function isEqual(val1, val2, struct_expand = false, _depth = 0) {
	INLINE
	
	if(_depth > 8) return false;
	
	if(is_array(val1) && is_array(val2))
		return array_member_equal(val1, val2, _depth);
		
	if(struct_expand && is_struct(val1) && is_struct(val2))	
		return struct_equal(val1, val2, _depth);
	
	return val1 == val2;
}

function array_member_equal(arr1, arr2, _depth = 0) {
	INLINE
	
	if(array_length(arr1) != array_length(arr2)) return false;
	
	for( var i = 0, n = array_length(arr1); i < n; i++ )
		if(!isEqual(arr1[i], arr2[i],, _depth + 1)) return false;
	
	return true;
}

function struct_equal(str1, str2, _depth = 0) {
	INLINE
	
	var key1 = variable_struct_get_names(str1);
	var key2 = variable_struct_get_names(str2);
	
	if(!array_equals(key1, key2)) return false;
	
	for( var i = 0, n = array_length(key1); i < n; i++ )
		if(!isEqual(str1[$ key1[i]], str2[$ key1[i]],, _depth + 1)) return false;
	
	return true;
}