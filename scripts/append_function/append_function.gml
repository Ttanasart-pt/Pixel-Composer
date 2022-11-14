function APPEND(_path) {
	APPENDING	= true;
	
	if(_path == "") return;
	
	var file = file_text_open_read(_path);
	var load_str = "";
	while(!file_text_eof(file)) {
		load_str += file_text_readln(file);
	}
	var _map = json_decode(load_str);
	
	if(ds_map_exists(_map, "version")) {
		var _v = _map[? "version"];
		if(_v != SAVEFILE_VERSION) {
			var warn = "File version mismatch : loading file verion " + string(_v) + " to Pixel Composer " + string(SAVEFILE_VERSION);
			log_warning("FILE", warn)
		}
	} else {
		var warn = "File version mismatch : loading old format to Pixel Composer " + string(SAVEFILE_VERSION);
		log_warning("FILE", warn)
	}
	
	var _node_list = _map[? "nodes"];
	var appended_list = ds_list_create();
	var node_create = ds_list_create();
	
	ds_queue_clear(CONNECTION_CONFLICT);
	ds_map_clear(APPEND_MAP);
	
	for(var i = 0; i < ds_list_size(_node_list); i++) {
		var _node = nodeLoad(_node_list[| i], true);
		if(_node) ds_list_add(appended_list, _node);
	}
	file_text_close(file);
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++) {
			var _node = appended_list[| i];
			_node.loadGroup();
		
			if(_node.group == PANEL_GRAPH.getCurrentContext())
				ds_list_add(node_create, _node);
		}
	} catch(e) {
		log_warning("APPEND, node", e.longMessage);
	}
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].postDeserialize();
	} catch(e) {
		log_warning("APPEND, deserialize", e.longMessage);
	}
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].preConnect();
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].connect();
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].postConnect();
	} catch(e) {
		log_warning("APPEND, connect", e.longMessage);
	}
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].doUpdate();
	} catch(e) {
		log_warning("APPEND, update", e.longMessage);
	}
	
	ds_list_destroy(appended_list);
	
	renderAll();
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		try {
			while(++pass < 3 && !ds_queue_empty(CONNECTION_CONFLICT)) {
				var size = ds_queue_size(CONNECTION_CONFLICT);
				log_message("APPEND", "[Connect] " + string(size) + " Connection conflict(s) detected ( pass: " + string(pass) + " )");
				repeat(size) {
					var junc = ds_queue_dequeue(CONNECTION_CONFLICT);
					var res = junc.connect(true);	
					
					log_message("APPEND", "[Connect] Reconnecting " + string(junc.name) + " " + (res? "SUCCESS" : "FAILED"));
				}
				renderAll();
			}
		
			if(!ds_queue_empty(CONNECTION_CONFLICT))
				log_warning("APPEND", "Some connection(s) is unsolved. This may caused by render node not being update properly, or image path is broken.");
		} catch(e) {
			log_warning("APPEND, Conflict solver error : ", e.longMessage);
		}
	}
	
	APPENDING = false;
	PANEL_ANIMATION.updatePropertyList();
	
	log_message("FILE", "append file " + _path, s_noti_icon_file_load);
	
	ds_map_destroy(_map);
	return node_create;
}

function GetAppendID(old_id) {
	if(ds_map_exists(APPEND_MAP, old_id)) 
		return APPEND_MAP[? old_id];
	return -1;
}