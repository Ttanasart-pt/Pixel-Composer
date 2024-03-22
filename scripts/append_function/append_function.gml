function APPEND(_path, context = PANEL_GRAPH.getCurrentContext()) { #region
	CALL("append");
	
	if(_path == "") return noone;
	var _map = json_load_struct(_path);
	
	if(_map == -1) {
		printIf(log, "Decode error");
		return noone;
	}
	
	var node_create = __APPEND_MAP(_map, context);
	recordAction(ACTION_TYPE.collection_loaded, array_create_from_list(node_create), _path);
	log_message("FILE", "append file " + _path, THEME.noti_icon_file_load);
	
	return node_create;
} #endregion

function __APPEND_MAP(_map, context = PANEL_GRAPH.getCurrentContext()) { #region
	static log   = false;
	UNDO_HOLDING = true;
	
	if(struct_has(_map, "version")) {
		var _v = _map.version;
		PROJECT.version = _v;
		if(PREFERENCES.notify_load_version && floor(_v) != floor(SAVE_VERSION)) {
			var warn = $"File version mismatch : loading file version {_v} to Pixel Composer {SAVE_VERSION}";
			log_warning("FILE", warn)
		}
	}
	
	if(!struct_has(_map, "nodes")) return noone;
	var _node_list	  = _map.nodes;
	var appended_list = ds_list_create();
	var node_create   = ds_list_create();
	
	APPENDING = true;
	
	ds_queue_clear(CONNECTION_CONFLICT);
	ds_map_clear(APPEND_MAP);
	var t = current_time;
	
	for(var i = 0; i < array_length(_node_list); i++) {
		var _node = nodeLoad(_node_list[i], true, context);
		if(_node) ds_list_add(appended_list, _node);
	}
	printIf(log, "Load time: " + string(current_time - t)); t = current_time;
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++) {
			var _node = appended_list[| i];
			_node.loadGroup(context);
		
			if(_node.group == context)
				ds_list_add(node_create, _node);
		}
	} catch(e) {
		log_warning("APPEND, node", exception_print(e));
	}
	printIf(log, "Load group time: " + string(current_time - t)); t = current_time;
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].postDeserialize();
	} catch(e) {
		log_warning("APPEND, deserialize", exception_print(e));
	}
	printIf(log, "Deserialize time: " + string(current_time - t)); t = current_time;
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].applyDeserialize();
	} catch(e) {
		log_warning("LOAD, apply deserialize", exception_print(e));
	}
	printIf(log, "Apply deserialize time: " + string(current_time - t)); t = current_time;
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].preConnect();
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].connect();
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].postConnect();
	} catch(e) {
		log_warning("APPEND, connect", exception_print(e));
	}
	printIf(log, "Connect time: " + string(current_time - t)); t = current_time;
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].doUpdate();
	} catch(e) {
		log_warning("APPEND, update", exception_print(e));
	}
	printIf(log, "Update time: " + string(current_time - t)); t = current_time;
	
	Render(true);
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		try {
			while(++pass < 3 && !ds_queue_empty(CONNECTION_CONFLICT)) {
				var size = ds_queue_size(CONNECTION_CONFLICT);
				log_message("APPEND", $"[Connect] {size} Connection conflict(s) detected (pass: {pass})");
				repeat(size) {
					var junc = ds_queue_dequeue(CONNECTION_CONFLICT);
					var res = junc.connect(true);	
					
					log_message("APPEND", $"[Connect] Reconnecting {junc.name} {res? "SUCCESS" : "FAILED"}");
				}
				Render(true);
			}
		
			if(!ds_queue_empty(CONNECTION_CONFLICT))
				log_warning("APPEND", "Some connection(s) is unresolved. This may caused by render node not being update properly, or image path is broken.");
		} catch(e) {
			log_warning("APPEND, Conflict solver error : ", exception_print(e));
		}
	}
	printIf(log, "Conflict time: " + string(current_time - t)); t = current_time;
	
	try {
		for(var i = 0; i < ds_list_size(appended_list); i++)
			appended_list[| i].postLoad();
	} catch(e) {
		log_warning("APPEND, connect", exception_print(e));
	}
	
	UNDO_HOLDING = false;
	
	ds_list_destroy(appended_list);
	
	APPENDING = false;
	
	if(struct_has(_map, "metadata")) {
		var meta = _map.metadata;
		for( var i = 0; i < ds_list_size(node_create); i++ ) {
			var _node = node_create[| i];
			if(!struct_has(_node, "metadata")) continue;
			
			_node.metadata.deserialize(meta, true);
		}
	}
	
	refreshNodeMap();
	RENDER_ALL_REORDER
	
	if(struct_has(_map, "timelines")) {
		var _time = new timelineItemGroup().deserialize(_map.timelines);
		array_append(PROJECT.timelines.contents, _time.contents);
	}
	
	return node_create;
} #endregion

function GetAppendID(old_id) { #region
	if(old_id == noone) return noone;
	
	if(ds_map_exists(APPEND_MAP, old_id)) 
		return APPEND_MAP[? old_id];
	print("Get append ID error: " + string(old_id));
	return noone;
} #endregion