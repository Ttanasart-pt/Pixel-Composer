function variable_instance_set_struct(object, params) {
	var _keys = variable_struct_get_names(params);
	for( var i = 0, n = array_length(_keys); i < n; i++ ) 
		variable_instance_set(object, _keys[i], params[$ _keys[i]]);
}