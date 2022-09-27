function array_safe_get(arr, index, def = 0) {
	if(index >= array_length(arr)) return def;
	return arr[index];
}

function array_exists(arr, val) {
	for( var i = 0; i < array_length(arr); i++ ) {
		if(arr[i] == val) return true;
	}
	return false;
}

function array_find(arr, val) {
	for( var i = 0; i < array_length(arr); i++ ) {
		if(arr[i] == val) return i;
	}
	return -1;
}

function array_remove(arr, val) {
	if(!array_exists(arr, val)) return;
	var ind = array_find(arr, val);
	array_delete(arr, ind, 1);
}