#macro struct_has variable_struct_exists

function struct_override(original, override) {
	var args = variable_struct_get_names(override);
	
	for( var i = 0, n = array_length(args); i < n; i++ ) {
		if(!struct_has(original, args[i])) continue;
		original[$ args[i]] = override[$ args[i]];
	}
	
	return original;
}

function struct_try_get(struct, key, def = 0) {
	if(struct[$ key] != undefined) return struct[$ key];
	
	key = string_replace_all(key, "_", " ");
	return struct[$ key] ?? def;
}