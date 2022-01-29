function ds_map_try_get(map, key, def) {
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
		original[? k] = newmap[? k];
		k = ds_map_find_next(newmap, k);
	}
}
