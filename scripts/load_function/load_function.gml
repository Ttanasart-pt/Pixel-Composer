function LOAD() {	
	if(DEMO) return false;
	
	var path = get_open_filename("Pixel Composer project (.pxc)|*.pxc", "");
	key_release();
	if(path == "") return;
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") return;
				
	gc_collect();
	LOAD_PATH(path);
	
	ds_list_clear(STATUSES);
	ds_list_clear(WARNING);
	ds_list_clear(ERRORS);
}

function TEST_PATH(path) {
	TESTING = true;
	TEST_ERROR = true;
	__LOAD_PATH(path, false, false);
}

function LOAD_PATH(path, readonly = false, safe_mode = false) {
	if(MODIFIED && !READONLY) {
		var dia = dialogCall(o_dialog_load);
		dia.path		= path;
		dia.readonly	= readonly;
		dia.safe_mode	= safe_mode;
	} else
		__LOAD_PATH(path, readonly, safe_mode);
}

function __LOAD_PATH(path, readonly = false, safe_mode = false) {
	SAFE_MODE = safe_mode;
	
	if(DEMO) return false;
	
	if(!file_exists(path)) {
		log_warning("LOAD", "File not found");
		return false;
	}
	
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") {
		log_warning("LOAD", "File not a valid project");
		return false;
	}
	
	LOADING = true;
		
	nodeCleanUp();
	clearPanel();
	setPanel();
	if(!TESTING)
		instance_destroy(_p_dialog);
	ds_list_clear(ERRORS);
	
	var temp_path = DIRECTORY + "_temp";
	if(file_exists(temp_path)) file_delete(temp_path);
	file_copy(path, temp_path);
	
	ALWAYS_FULL = false;
	READONLY	= readonly;
	SET_PATH(path);
	
	var _load_content = json_load_struct(temp_path);
	
	if(struct_has(_load_content, "version")) {
		var _v = _load_content.version;
		LOADING_VERSION = _v;
		if(_v != SAVEFILE_VERSION) {
			var warn = "File version mismatch : loading file verion " + string(_v) + " to Pixel Composer " + string(SAVEFILE_VERSION);
			log_warning("LOAD", warn);
		}
	} else {
		var warn = "File version mismatch : loading old format to Pixel Composer " + string(SAVEFILE_VERSION);
		log_warning("LOAD", warn);
	}
	
	nodeCleanUp();
	
	var create_list = ds_list_create();
	if(struct_has(_load_content, "nodes")) {
		try {
			var _node_list = _load_content.nodes;
			for(var i = 0; i < array_length(_node_list); i++) {
				var _node = nodeLoad(_node_list[i]);
				if(_node) ds_list_add(create_list, _node);
			}
		} catch(e) {
			log_warning("LOAD", exception_print(e));
		}
	}
	
	try {
		if(struct_has(_load_content, "animator")) {
			var _anim_map			= _load_content.animator;
			ANIMATOR.frames_total	= _anim_map.frames_total;
			ANIMATOR.framerate		= _anim_map.framerate;
		}
	} catch(e) {
		log_warning("LOAD, animator", exception_print(e));
	}
	
	try {
		if(struct_has(_load_content, "metadata"))
			METADATA.deserialize(_load_content.metadata);
	} catch(e) {
		log_warning("LOAD, metadata", exception_print(e));
	}
	
	GLOBAL = new Node_Global();
	try {
		if(struct_has(_load_content, "global"))
			GLOBAL.deserialize(_load_content.global);
	} catch(e) {
		log_warning("LOAD, global", exception_print(e));
	}
	
	try {
		if(struct_has(_load_content, "addon")) {
			var _addon = _load_content.addon;
			LOAD_ADDON = _addon;
			struct_foreach(_addon, function(_name, _value) { addonLoad(_name, false); });
		} else 
			LOAD_ADDON = {};
	} catch(e) {
		log_warning("LOAD, addon", exception_print(e));
	}
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].loadGroup();
	} catch(e) {
		log_warning("LOAD, group", exception_print(e));
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].postDeserialize();
	} catch(e) {
		log_warning("LOAD, deserialize", exception_print(e));
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].applyDeserialize();
	} catch(e) {
		log_warning("LOAD, apply deserialize", exception_print(e));
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].preConnect();
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].connect();
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].doUpdate();
	} catch(e) {
		log_warning("LOAD, update", exception_print(e));
	}
	
	Render(, true);
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		try {
			while(++pass < 4 && !ds_queue_empty(CONNECTION_CONFLICT)) {
				var size = ds_queue_size(CONNECTION_CONFLICT);
				log_message("LOAD", $"[Connect] {size} Connection conflict(s) detected (pass: {pass})");
				repeat(size)
					ds_queue_dequeue(CONNECTION_CONFLICT).connect();
				Render();
			}
			
			if(!ds_queue_empty(CONNECTION_CONFLICT))
				log_warning("LOAD", "Some connection(s) is unsolved. This may caused by render node not being update properly, or image path is broken.");
		} catch(e) {
			log_warning("LOAD, connect solver", exception_print(e));
		}
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].postConnect();
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	Render();
	
	LOADING = false;
	MODIFIED = false;
	
	PANEL_ANIMATION.updatePropertyList();
	
	log_message("FILE", "load " + path, THEME.noti_icon_file_load);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_load);
	
	refreshNodeMap();
	
	return true;
}