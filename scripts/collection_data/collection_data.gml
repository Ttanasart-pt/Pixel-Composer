function __initCollection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
	var root = DIRECTORY + "Collections";
	directory_verify(root);
	
	if(check_version($"{root}/version"))
		zip_unzip("data/Collections.zip", root);
	
	refreshCollections();
}

function refreshCollections() {
	log_message("COLLECTION", "refreshing collection base folder.");
	
	COLLECTIONS = new DirectoryObject("Collections", DIRECTORY + "Collections");
	COLLECTIONS.scan([".json", ".pxcc"]);
	COLLECTIONS.open = true;
}

function searchCollection(_list, _search_str, _clear_list = true) {
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

function saveCollection(_node, _path, _name, save_surface = true, metadata = noone) {
	if(_node == noone) return;
		
	var _pre_name = (_path == ""? "" : _path + "/") + _name;
	var ext = filename_ext(_pre_name);
	_path = ext == ".pxcc"? _pre_name : _pre_name + ".pxcc";
		
	SAVE_COLLECTION(_node, _path, save_surface, metadata, _node.group);
		
	PANEL_COLLECTION.updated_path = _path;
	PANEL_COLLECTION.updated_prog = 1;
	PANEL_COLLECTION.refreshContext();
}