function FileContext(_name, _path, _subfolder = false) constructor {
	name = _name;
	path = _path;
	spr  = -1;
	
	subfolder = _subfolder;
}

function __init_collection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
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
	
	if(!directory_exists(DIRECTORY + "Collections")) {
		directory_create(DIRECTORY + "Collections");
		return;
	}
	
	COLLECTIONS = new DirectoryObject("Collections", DIRECTORY + "Collections");
	COLLECTIONS.open = true;
}