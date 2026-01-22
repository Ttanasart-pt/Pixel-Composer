function __addonDefault(root) {
	if(check_version($"{root}/version")) {
		printDebug("unzipping default addon to DIRECTORY.");
		zip_unzip($"{working_directory}data/addons.zip", root);
	}
}

function __initAddon() { 
	var dirPath = DIRECTORY + "Addons";
	globalvar ADDONS, ADDONS_ON_START;
	ADDONS = [];
	ADDONS_ON_START = [];
	
	directory_verify(dirPath);
	__addonDefault(dirPath);
	
	var f = file_find_first(dirPath + "/*", fa_directory);
	var _f = "";
	
	while(f != "" && f != _f) {
		_f = f;
		var _path = dirPath + "/" + f;
		var _meta = _path + "/meta.json";
		
		if(!file_exists_empty(_meta)) {
			f = file_find_next();
			continue;
		}
		
		var _mSrt = json_load_struct(_meta);
		var _str  = {
			name: f,
			path: _path,
			meta: struct_try_get(_mSrt, "meta", {}),
			
			open: false
		};
		
		array_push(ADDONS, _str);	
		f = file_find_next();
	}
	
	file_find_close();
	
	loadAddon();
}

function loadAddon() {
	var _path = DIRECTORY + "Addons/__init.json";
	if(!file_exists_empty(_path)) return;
	
	ADDONS_ON_START = json_load_struct(_path);
	for( var i = 0, n = array_length(ADDONS_ON_START); i < n; i++ ) 
		addonTrigger(ADDONS_ON_START[i], false);
}