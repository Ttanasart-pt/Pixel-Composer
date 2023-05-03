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
		var _path = dirPath + "\\" + f;
		var _meta = _path + "\\meta.json";
		
		if(!file_exists(_meta)) continue;
		var _mSrt = json_load_struct(_meta);
		var _str = {
			name: f,
			path: _path,
			meta: _mSrt.meta,
			
			open: false
		};
		
		array_push(ADDONS, _str);	
		f = file_find_next();
	}
}