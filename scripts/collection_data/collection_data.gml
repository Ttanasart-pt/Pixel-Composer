function __initCollection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
	var root = DIRECTORY + "Collections";
	if(!directory_exists(root))
		directory_create(root);
	
	var _l = root + "/version";
	if(file_exists(_l)) {
		var res = json_load_struct(_l);
		if(!is_struct(res) || !struct_has(res, "version") || res.version < COLLECTION_VERSION) 
			zip_unzip("data/Collections.zip", root);
	} else 
		zip_unzip("data/Collections.zip", root);
	json_save_struct(_l, { version: COLLECTION_VERSION });
	
	
	refreshCollections();
}

function refreshCollections() {
	log_message("COLLECTION", "refreshing collection base folder.");
	
	COLLECTIONS = new DirectoryObject("Collections", DIRECTORY + "Collections");
	COLLECTIONS.scan([".json", ".pxcc"]);
	COLLECTIONS.open = true;
}

function searchCollection(_list, _search_str, _clear_list = true) {
	//if(_clear_list)
	//	ds_list_clear(_list);
	
	if(_search_str == "") return;
	var search_lower = string_lower(_search_str);
		
	var st = ds_stack_create();
	ds_stack_push(st, COLLECTIONS);
		
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _nd = _st.content[| i];
				
			var match = string_partial_match(string_lower(_nd.name), search_lower);
			if(match == -9999) continue;
			
			ds_priority_add(_list, _nd, match);
		}
			
		for( var i = 0; i < ds_list_size(_st.subDir); i++ ) {
			ds_stack_push(st, _st.subDir[| i]);
		}
	}
	
	ds_stack_destroy(st);
}