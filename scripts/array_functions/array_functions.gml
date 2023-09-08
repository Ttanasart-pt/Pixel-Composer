function array_create_from_list(list) {
	if(list == undefined) return [];
	if(!ds_exists(list, ds_type_list)) return [];
	
	var arr = array_create(ds_list_size(list));
	for( var i = 0; i < ds_list_size(list); i++ )
		arr[i] = list[| i];
	return arr;
}

function array_safe_set(arr, index, value, fill = 0) {
	if(!is_array(arr))  return arr;
	if(is_array(index)) return arr;
	
	if(index < 0) return arr;
	if(index >= array_length(arr)) {
		var i = array_length(arr);
		for(; i <= index; i++ )
			arr[i] = fill;
		arr[index] = value;
		return arr;
	}
	
	array_set(arr, index, value);
	return arr;
}

function array_resize_fill(arr, size, fill = 0) {
	if(size < array_length(arr)) {
		array_resize(arr, size);
		return arr;
	}
	
	var i = array_length(arr);
	for(; i < size; i++)
		arr[i] = fill;
	return arr;
}

enum ARRAY_OVERFLOW {
	_default,
	loop
}

function array_safe_get(arr, index, def = 0, overflow = ARRAY_OVERFLOW._default) {
	gml_pragma("forceinline");
	if(!is_array(arr))  return def;
	if(is_array(index)) return def;
	
	if(overflow == ARRAY_OVERFLOW.loop) {
		var len = array_length(arr);
		if(index < 0)
			index = len - safe_mod(abs(index), len);
		index = safe_mod(index, len);
	}
	
	if(index < 0) return def;
	if(index >= array_length(arr)) return def;
	return arr[index] == undefined? def : arr[index];
}

function array_push_create(arr, val) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) return [ val ];
	array_push(arr, val);
	return arr;
}

function array_get_decimal(arr, index, color = false) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) return 0;
	if(frac(index) == 0) return array_safe_get(arr, index);
	
	var v0 = array_safe_get(arr, floor(index));
	var v1 = array_safe_get(arr, floor(index) + 1);
	
	return color? 
		merge_color(v0, v1, frac(index)) : 
		lerp(v0, v1, frac(index));
}

function array_exists(arr, val) {
	gml_pragma("forceinline");
	self.__temp_val = val;
	
	if(!is_array(arr)) return false;
	return array_any(arr, function(_val, _ind) {
		return isEqual(_val, self.__temp_val);
	});
}

function array_overlap(arr0, arr1) {
	gml_pragma("forceinline");
	self.__temp_arr = arr1;
	
	if(!is_array(arr0)) return false;
	if(!is_array(arr1)) return false;
	
	return array_any(arr0, function(_val, _ind) {
		return array_exists(self.__temp_arr, _val);
	});
}

function array_empty(arr) {
	gml_pragma("forceinline");
	return is_array(arr) && array_length(arr) == 0;
}

function array_find(arr, val) {
	gml_pragma("forceinline");
	self.__temp_val = val;
	
	if(!is_array(arr)) return -1;
	return array_find_index(arr, function(_val, _ind) {
		return isEqual(_val, self.__temp_val);
	});
}

function array_remove(arr, val) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) return;
	if(!array_exists(arr, val)) return;
	var ind = array_find(arr, val);
	array_delete(arr, ind, 1);
}

function array_push_unique(arr, val) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) return;
	if(array_exists(arr, val)) return;
	array_push(arr, val);
}


function array_insert_unique(arr, ind, val) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) return;
	if(array_exists(arr, val)) return;
	array_insert(arr, ind, val);
}

function array_append(arr, arr0) {
	gml_pragma("forceinline");
	
	if(!is_array(arr))  return arr;
	if(!is_array(arr0)) return arr;
	
	for( var i = 0, n = array_length(arr0); i < n; i++ )
		array_push(arr, arr0[i]);
	return arr;
}

function array_merge() {
	gml_pragma("forceinline");
	
	var arr = [];
	for( var i = 0; i < argument_count; i++ )
		array_append(arr, argument[i]);
	
	return arr;
}

function array_clone(arr) {
	gml_pragma("forceinline");
	
	if(!is_array(arr)) return arr;
	
	var _res = [];
	 for( var i = 0, n = array_length(arr); i < n; i++ )
		 _res[i] = array_clone(arr[i]);
	 return _res;
}

function array_min(arr) {
	gml_pragma("forceinline");
	
	if(!is_array(arr) || array_length(arr) == 0) return 0;
	
	var mn = arr[0];
	for( var i = 0, n = array_length(arr); i < n; i++ )
		mn = min(mn, arr[i]);
	return mn;
}

function array_max(arr) {
	gml_pragma("forceinline");
	
	if(!is_array(arr) || array_length(arr) == 0) return 0;
	
	var mx = arr[0];
	for( var i = 0, n = array_length(arr); i < n; i++ )
		mx = max(mx, arr[i]);
	return mx;
}

function array_get_dimension(arr) {
	gml_pragma("forceinline");
	
	return is_array(arr)? array_length(arr) : 1;
}

function array_shape(arr, first = true, isSurface = false) {
	if(!is_array(arr)) {
		if(isSurface && is_surface(arr)) 
			return (first? "" : " x ") + string(surface_get_width_safe(arr)) + " x " + string(surface_get_height_safe(arr)) + " px";
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
	
	for( var i = 0, n = array_length(arr); i < n; i++ ) 
		array_spread(arr[i], _arr);
		
	return _arr;
}