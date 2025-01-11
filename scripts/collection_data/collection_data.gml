function __initCollection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
	var root  = DIRECTORY + "Collections";       directory_verify(root);
	var rootz = DIRECTORY + "Collections_cache"; directory_verify(rootz);
	
	if(check_version($"{root}/version"))
		zip_unzip("data/Collections.zip", root);
	
	COLLECTIONS = new DirectoryObject(DIRECTORY + "Collections");
	refreshCollections();
}

function refreshCollections() {
	log_message("COLLECTION", "refreshing collection base folder.");
	
	COLLECTIONS = new DirectoryObject(DIRECTORY + "Collections");
	COLLECTIONS.scan([".json", ".pxcc"]);
	COLLECTIONS.open = true;
}

function searchCollection(_list, _search_str, _toList = true) {
	if(_search_str == "") return;
	var search_lower = string_lower(_search_str);
	
	var st = ds_stack_create();
	var ll = _toList? ds_priority_create() : _list;
	
	ds_stack_push(st, COLLECTIONS);
		
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _nd = _st.content[| i];
				
			var match = string_partial_match(string_lower(_nd.name), search_lower);
			if(match == -9999) continue;
			
			ds_priority_add(ll, _nd, match);
		}
			
		for( var i = 0; i < ds_list_size(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[| i]);
	}
	
	if(_toList) {
		repeat(ds_priority_size(ll))
			ds_list_add(_list, ds_priority_delete_max(ll));
		
		ds_priority_destroy(ll);
	}
	
	ds_stack_destroy(st);
}

function saveCollection(_node, _path, _name, save_surface = true, metadata = noone) {
	if(_node == noone) return;
		
	var _pxz  = false;
	var _file = _path + "/" + filename_name_only(_name);
	
	if(_pxz) {
		_path = _file + ".pxz";
		SAVE_PXZ_COLLECTION(_node, _path, PANEL_PREVIEW.getNodePreviewSurface(), metadata, _node.group);
		
	} else {
		_path = _file + ".pxcc";
		SAVE_COLLECTION(_node, _path, save_surface, metadata, _node.group);
		
	}
	
	PANEL_COLLECTION.updated_path = _path;
	PANEL_COLLECTION.updated_prog = 1;
	PANEL_COLLECTION.refreshContext();
}