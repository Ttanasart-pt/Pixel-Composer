function ds_map_clone(map) {
	var m = ds_map_create();
	var k = ds_map_find_first(map);
	
	repeat(ds_map_size(map)) {
		m[? k] = map[? k];
		k = ds_map_find_next(map, k);
	}
	return m;
}

function ds_map_try_get(map, key, def = 0) {
	if(ds_map_exists(map, key)) return map[? key];
	return def;
}

function ds_map_override(original, newmap) {
	if(is_undefined(original)) return;
	if(!ds_exists(original, ds_type_map)) return;
	
	if(is_undefined(newmap)) return;
	if(!ds_exists(newmap, ds_type_map)) return;
	
	var k = ds_map_find_first(newmap);
	
	repeat(ds_map_size(newmap)) {
		original[? k] = newmap[? k] ?? 1;
		k = ds_map_find_next(newmap, k);
	}
}

function ds_map_arr_to_list(map) {
	var k = ds_map_find_first(map);
	
	repeat(ds_map_size(map)) {
		if(is_array(map[? k])) {
			var l = ds_list_create_from_array(map[? k]);
			ds_map_replace_list(map, k, l);
		}
		
		k = ds_map_find_next(map, k);
	}
}

function ds_map_list_to_arr(map) {
	var k = ds_map_find_first(map);
	
	repeat(ds_map_size(map)) {
		if(ds_map_is_list(map, k))
			map[? k] = array_create_from_list(map[? k]);
		
		k = ds_map_find_next(map, k);
	}
}

function ds_map_print(map) {
	var txt = "{";
	var k = ds_map_find_first(map);
	
	repeat(ds_map_size(map)) {
		txt += $"{k} : {map[? k]}, ";
		k = ds_map_find_next(map, k);
	}
	txt += "}";
	return txt;
}

function ds_map_to_struct(map) {
	var _s = {};
	var k = ds_map_find_first(map);
	
	repeat(ds_map_size(map)) {
		_s[$ k] = map[? k];
		k = ds_map_find_next(map, k);
	}
	return _s;
}