function array_create_from_list(list) {
	if(list == undefined) return [];
	if(!ds_exists(list, ds_type_list)) return [];
	
	var arr = array_create(ds_list_size(list));
	for( var i = 0; i < ds_list_size(list); i++ )
		arr[i] = list[| i];
	return arr;
}

function array_safe_set(arr, index, value) {
	if(!is_array(arr)) return def;
	if(index < 0) return;
	if(index >= array_length(arr)) return;
	
	array_set(arr, index, value);
}

enum ARRAY_OVERFLOW {
	_default,
	loop
}
function array_safe_get(arr, index, def = 0, overflow = ARRAY_OVERFLOW._default) {
	if(!is_array(arr)) return def;
	
	if(overflow == ARRAY_OVERFLOW.loop) {
		if(index < 0)
			index = array_length(arr) - safe_mod(abs(index), array_length(arr));
		index = safe_mod(index, array_length(arr));
	}
	
	if(index < 0) return def;
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


function array_insert_unique(arr, ind, val) {
	if(array_exists(arr, val)) return;
	array_insert(arr, ind, val);
}

function array_append(arr, arr0) {
	for( var i = 0; i < array_length(arr0); i++ )
		array_push(arr, arr0[i]);
	return arr;
}

function array_shuffle(arr) {
	var r = array_length(arr) - 1;
	for(var i = 0; i < r; i += 1) {
	    var j = irandom_range(i,r);
	    temp = arr[i];
	    arr[i] = arr[j];
	    arr[j] = temp;
	}
	
	return arr;
}

function array_merge() {
	var arr = [];
	for( var i = 0; i < argument_count; i++ ) {
		array_append(arr, argument[i]);
	}
	
	return arr;
}

function array_clone(arr) {
	if(!is_array(arr))
		return arr;
	
	var _res = [];
	 for( var i = 0; i < array_length(arr); i++ )
		 _res[i] = array_clone(arr[i]);
	 return _res;
}

function array_min(arr) {
	if(array_length(arr) == 0) return 0;
	
	var mn = arr[0];
	 for( var i = 0; i < array_length(arr); i++ )
		 mn = min(mn, arr[i]);
	 return mn;
}

function array_max(arr) {
	if(array_length(arr) == 0) return 0;
	
	var mx = arr[0];
	 for( var i = 0; i < array_length(arr); i++ )
		 mx = max(mx, arr[i]);
	 return mx;
}

function array_get_dimension(arr) {
	return is_array(arr)? array_length(arr) : 1;
}

function array_shape(arr, first = true, isSurface = false) {
	if(!is_array(arr)) {
		if(isSurface && is_surface(arr)) 
			return (first? "" : " x ") + string(surface_get_width(arr)) + " x " + string(surface_get_height(arr)) + " px";
		return "";
	}
	
	var dim = string(array_length(arr));
	
	if(array_length(arr)) 
		dim += array_shape(arr[0], false, isSurface);
	
	return (first? "" : " x ") + dim;
}

function array_spread(arr, _arr = []) {
	if(!is_array(arr)) {
		array_push(_arr, arr);
		return _arr;
	}
	
	for( var i = 0; i < array_length(arr); i++ ) 
		array_spread(arr[i], _arr);
		
	return _arr;
}