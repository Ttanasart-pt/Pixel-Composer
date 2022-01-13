function FileContext(_name, _path) constructor {
	name = _name;
	path = _path;
	spr  = -1;
}

function __init_collection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = ds_list_create();
	
	var _ = DIRECTORY + "Collections";
	var _l = _ + "\\coll" + string(VERSION);
	if(!file_exists(_l)) {
		log_message("COLLECTION", "unzipping new collection to DIRECTORY.");
		var f = file_text_open_write(_l);
		file_text_write_real(f, 0);
		file_text_close(f);
		
		zip_unzip("Collections.zip", _);
	}
	
	searchCollections();
}

function searchCollections() {
	log_message("COLLECTION", "refreshing collection base folder.");
	ds_list_clear(COLLECTIONS);
	var f = new FileContext("Base node", "");
	ds_list_add(COLLECTIONS, f);
	
	if(!directory_exists(DIRECTORY + "Collections")) {
		directory_create(DIRECTORY + "Collections");
		return;
	}
	
	var _l = DIRECTORY + "Collections";
	var folder = file_find_first(_l + "/*", fa_directory);
	while(folder != "") {
		if(directory_exists(_l + "\\" + folder))
			ds_list_add(COLLECTIONS, new FileContext(folder, _l + "\\" + folder));
		folder = file_find_next();
	}
	file_find_close();
}