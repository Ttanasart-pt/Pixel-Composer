function tunnel_autocomplete_server(prompt, params = []) {
	var res = [];
	
	var pr_list = ds_priority_create();
	
	//////////////////////////////////
	ds_priority_clear(pr_list);
	
	var _tkeys = ds_map_keys_to_array(TUNNELS_IN);
	for( var i = 0, n = array_length(_tkeys); i < n; i++ ) {
		var gl = _tkeys[i];
		
		var match = string_partial_match(string_lower(gl), string_lower(prompt));
		if(match == -9999) continue;
		
		ds_priority_add(pr_list, [[THEME.ac_constant, 2], gl, "tunnel", gl], match);
	}
	
	repeat(ds_priority_size(pr_list))
		array_push(res, ds_priority_delete_max(pr_list));
	
	ds_priority_destroy(pr_list);
	
	return res;
}