function ds_list_create_from_array(array) {
	var l = ds_list_create();
	for( var i = 0; i < array_length(array); i++ )  {
		l[| i] = array[i];
	}	
	return l;
}

function ds_list_to_array(list) {
	if(!ds_exists(list, ds_type_list)) return [];
	
	var a = array_create(ds_list_size(list));
	for( var i = 0; i < ds_list_size(list); i++ )  {
		a[i] = list[| i];
	}
	return a;
}

function ds_list_add_map(list, map) {
	ds_list_add(list, map);
	ds_list_mark_as_map(list, ds_list_size(list) - 1);
}

function ds_list_get(list, index, def = 0) {
	if(index < ds_list_size(list)) return list[| index];
	return def;
}

function ds_list_clone(list) {
	var l = ds_list_create();
	ds_list_copy(l, list);
	return l;
}

function ds_list_remove(list, item) {
	var in = ds_list_find_index(list, item);
	if(in >= 0) ds_list_delete(list, in);
}

function ds_list_append(list, _append) {
	for( var i = 0; i < ds_list_size(_append); i++ ) {
		ds_list_add(list, _append[| i]);
	}
}

function ds_list_exist(list, item) {
	return ds_list_find_index(list, item) != -1;
}