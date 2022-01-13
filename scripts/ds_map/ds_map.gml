function ds_map_try_get(map, key, def) {
	if(ds_map_exists(map, key)) return map[? key];
	return def;
}

function ds_map_override(original, newmap) {
	var k = ds_map_find_first(newmap);
	
	repeat(ds_map_size(newmap)) {
		original[? k] = newmap[? k];
		k = ds_map_find_next(newmap, k);
	}
}
