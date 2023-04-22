function __initAddon() {
	var dirPath = DIRECTORY + "Addons";
	globalvar ADDONS;
	ADDONS = [];
	
	if(!directory_exists(dirPath)) {
		directory_create(dirPath);
		return;
	}
	
	var f = file_find_first(dirPath + "\\*", fa_directory);
	while(f != "") {
		array_push(ADDONS, f);	
		f = file_find_next();
	}
}