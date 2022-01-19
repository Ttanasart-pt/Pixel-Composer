function LOAD() {
	var path = get_open_filename("*.pxc;*.json", "");
	if(path == "") return;
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") return;
	
	LOAD_PATH(path);
}

function LOAD_PATH(path, readonly = false) {
	if(!file_exists(path)) {
		PANEL_MENU.showNoti("File not found", s_noti_icon_warning);
		return false;
	}
	
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") {
		PANEL_MENU.showNoti("File not a valid project", s_noti_icon_warning);
		return false;
	}
	
	var temp_path = DIRECTORY + "\_temp";
	if(file_exists(temp_path)) file_delete(temp_path);
	file_copy(path, temp_path);
	
	LOADING		= true;
	READONLY	= readonly;
	SET_PATH(path);
	
	var file = file_text_open_read(temp_path);
	var load_str = "";
	
	while(!file_text_eof(file)) {
		load_str += file_text_readln(file);
	}
	file_text_close(file);
	
	var _map = json_decode(load_str);
	if(ds_map_exists(_map, "version")) {
		var _v = _map[? "version"];
		if(_v != SAVEFILE_VERSION) {
			var warn = "File version mismatch : loading file verion " + string(_v) + " to Pixel Composer " + string(SAVEFILE_VERSION);
			log_warning("FILE", warn)
			PANEL_MENU.addNotiExtra(warn);
		}
	} else {
		var warn = "File version mismatch : loading old format to Pixel Composer " + string(SAVEFILE_VERSION);
		log_warning("FILE", warn)
		PANEL_MENU.addNotiExtra(warn);
	}
	
	nodeCleanUp();
	
	var create_list = ds_list_create();
	if(ds_map_exists(_map, "nodes")) {
		var _node_list = _map[? "nodes"];
		for(var i = 0; i < ds_list_size(_node_list); i++) {
			var _node = nodeLoad(_node_list[| i]);
			if(_node) ds_list_add(create_list, _node);
		}
	}
	
	if(ds_map_exists(_map, "animator")) {
		var _anim_map			= _map[? "animator"];
		ANIMATOR.frames_total	= _anim_map[? "frames_total"];
		ANIMATOR.framerate		= _anim_map[? "framerate"];
	}
	ds_map_destroy(_map);
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	for(var i = 0; i < ds_list_size(create_list); i++) {
		create_list[| i].loadGroup();
	}
	
	for(var i = 0; i < ds_list_size(create_list); i++) {
		create_list[| i].postDeserialize();
	}
	
	for(var i = 0; i < ds_list_size(create_list); i++) {
		create_list[| i].preConnect();
	}
	
	for(var i = 0; i < ds_list_size(create_list); i++) {
		create_list[| i].connect();
	}
	
	for(var i = 0; i < ds_list_size(create_list); i++) {
		create_list[| i].postConnect();
	}
	
	for(var i = 0; i < ds_list_size(create_list); i++) {
		create_list[| i].doUpdate();
	}
	
	renderAll();
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		while(++pass < 4 && !ds_queue_empty(CONNECTION_CONFLICT)) {
			var size = ds_queue_size(CONNECTION_CONFLICT);
			log_message("LOAD", "[Connect] " + string(size) + " Connection conflict(s) detected ( pass: " + string(pass) + " )");
			repeat(size) {
				ds_queue_dequeue(CONNECTION_CONFLICT).connect();	
			}
			renderAll();
		}
		
		if(!ds_queue_empty(CONNECTION_CONFLICT))
			PANEL_MENU.addNotiExtra("Some connection(s) is unsolved. This may caused by render node not being update properly, or image path is broken.");
	}
	
	LOADING = false;
	
	PANEL_GRAPH.fullView();
	PANEL_ANIMATION.updatePropertyList();
	
	log_message("FILE", "load at " + path);
	PANEL_MENU.showNoti("File loaded", s_noti_icon_file_load);
	return true;
}
