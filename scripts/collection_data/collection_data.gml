function __initCollection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
	var root = DIRECTORY + "Collections";
	if(!directory_exists(root))
		directory_create(root);
			
	var _l = root + "\\_coll" + string(VERSION);
	if(!file_exists(_l)) {
		log_message("COLLECTION", "unzipping new collection to DIRECTORY.");
		var f = file_text_open_write(_l);
		file_text_write_real(f, 0);
		file_text_close(f);
		
		zip_unzip("data/Collections.zip", root);
	}
	
	refreshCollections();
}

function refreshCollections() {
	log_message("COLLECTION", "refreshing collection base folder.");
	
	COLLECTIONS = new DirectoryObject("Collections", DIRECTORY + "Collections");
	COLLECTIONS.scan([".json", ".pxcc"]);
	COLLECTIONS.open = true;
}

function searchCollection(_list, _search_str, _claer_list = true) {
	if(_claer_list)
		ds_list_clear(_list);
	
	if(_search_str == "") return;
	var search_lower = string_lower(_search_str);
		
	var st = ds_stack_create();
	ds_stack_push(st, COLLECTIONS);
		
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _nd = _st.content[| i];
				
			var match = string_pos(search_lower, string_lower(_nd.name)) > 0;
			if(!match) continue;
			
			ds_list_add(_list, _nd);
		}
			
		for( var i = 0; i < ds_list_size(_st.subDir); i++ ) {
			ds_stack_push(st, _st.subDir[| i]);
		}
	}
	
	ds_stack_destroy(st);
}