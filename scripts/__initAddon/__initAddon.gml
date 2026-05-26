globalvar ADDONS, ADDON_MAP;
globalvar ADDONS_ON_START;

function addonWrapper(_name) constructor {
	name = _name;
	ADDON_MAP[$ name] = self;
	
	type = 0;       static setType = function(n) /*=>*/ { type = n; return self; }
	meta = {};      static setMeta = function(n) /*=>*/ { meta = n; return self; }
	
	path   = "";    static setPath   = function(n) /*=>*/ { path   = n; return self; }
	object = noone; static setObject = function(n) /*=>*/ { object = n; return self; }
	
	open      = false;
	activated = false;
	activatedInstance = noone;
	
	static isActivated = function() /*=>*/ {return activated};
	
	static activate = function(_openDialog = false) /*=>*/ {
		if(isActivated()) return false;
		
		switch(type) {
			case 0 :
				activatedInstance = instance_create(0, 0, object);
				if(_openDialog && activatedInstance.panelMain)
					dialogPanelCall(new activatedInstance.panelMain(activatedInstance));
				activated = true;
				return true;
				
			case 1 : 
				if(!directory_exists(path)) return;
				activatedInstance = instance_create(0, 0, _addon_custom);
				activatedInstance.init(path, _openDialog);
				activated = true;
				return true;
		}
		
		return false;
	}
	
	static deactivate = function() /*=>*/ {
		if(!isActivated()) return false;
		
		instance_destroy(activatedInstance);
		activatedInstance = noone;
		activated = false;
		return true;
	}
	
	static trigger = function() /*=>*/ {
		if(isActivated()) deactivate();
		else activate();
		return self;
	}
}

function __addonDefault(root) {
	if(check_version($"{root}/version")) {
		printDebug("  - unzipping default addon to DIRECTORY.");
		zip_unzip($"{working_directory}pack/addons.zip", root);
	}
}

function __initAddon() { 
	var dirPath = $"{DIRECTORY}Addons";
	ADDON_MAP = {};
	ADDONS    = [
		new addonWrapper("Key Display").setObject(addon_key_displayer).setMeta({
			author: "MakhamDev", description: "Display pressing keys on screen for screen sharing and debugging."
		}),
		new addonWrapper("Remote Terminal").setObject(addon_remote_terminal).setMeta({
			author: "MakhamDev", description: "Open webSocket port for receiving and executing terminal commands."
		}),
	];
	
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
		var _str  = new addonWrapper(f).setType(1).setPath(_path)
			.setMeta(struct_try_get(_mSrt, "meta", {}));
		
		array_push(ADDONS, _str);	
		f = file_find_next();
	}
	
	file_find_close();
	
	var _path = DIRECTORY + "Addons/__init.json";
	if(!file_exists_empty(_path)) return;
	
	ADDONS_ON_START = json_load_struct(_path);
	for( var i = 0, n = array_length(ADDONS_ON_START); i < n; i++ ) {
		var _addon = ADDONS_ON_START[i];
		if(has(ADDON_MAP, _addon)) ADDON_MAP[$ _addon].activate();
	}
}