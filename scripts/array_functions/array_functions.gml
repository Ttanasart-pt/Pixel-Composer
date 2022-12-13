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

function array_push_unique(arr, val) {
	if(array_exists(arr, val)) return;
	array_push(arr, val);
}

function array_append(arr, arr0) {
	for( var i = 0; i < array_length(arr0); i++ )
		array_push(arr, arr0[i]);
}

function array_merge() {
	var arr = [];
	for( var i = 0; i < argument_count; i++ ) {
		array_append(arr, argument[i]);
	}
	
	return arr;
}