#macro struct_has variable_struct_exists

function struct_override(original, override) {
	var args = variable_struct_get_names(override);
	
	for( var i = 0; i < array_length(args); i++ ) {
		if(!struct_has(original, args[i])) continue;
		original[$ args[i]] = override[$ args[i]];
	}
	
	return original;
}

function struct_try_get(struct, key, def = 0) {
	return struct_has(struct, key)? struct[$ key] : def;
}