function GetAppendID(old_id) { return ds_map_try_get(APPEND_MAP, old_id, old_id); }

function APPEND(_path, context = PANEL_GRAPH.getCurrentContext()) {
	CALL("append");
	
	if(_path == "") return noone;
	var _map = json_load_struct(_path);
	
	if(_map == -1) {
		printIf(log, "Decode error");
		return noone;
	}
	
	var node_create = __APPEND_MAP(_map, context);
	recordAction(ACTION_TYPE.collection_loaded, array_clone(node_create), _path);
	log_message("FILE", "append file " + _path, THEME.noti_icon_file_load);
	
	return node_create;
}

function __APPEND_MAP(_map, context = PANEL_GRAPH.getCurrentContext(), appended_list = []) {
	static log   = false;
	UNDO_HOLDING = true;
	
	if(struct_has(_map, "version")) {
		var _v = _map.version;
		LOADING_VERSION = _v;
		
		if(PREFERENCES.notify_load_version && floor(_v) != floor(SAVE_VERSION)) {
			var warn = $"File version mismatch : loading file version {_v} to Pixel Composer {SAVE_VERSION}";
			log_warning("FILE", warn)
		}
	}
	
	if(!struct_has(_map, "nodes")) return noone;
	var _node_list	  = _map.nodes;
	var node_create   = [];
	
	APPENDING = true;
	
	ds_queue_clear(CONNECTION_CONFLICT);
	if(!CLONING) ds_map_clear(APPEND_MAP);
	
	var t = current_time;
	
	for(var i = 0; i < array_length(_node_list); i++) {
		var ex = ds_map_exists(APPEND_MAP, _node_list[i].id);
		
		var _node = nodeLoad(_node_list[i], true, context);
		if(_node == noone) continue;
		
		_node.load_scale = !CLONING;
		if(!ex) array_push(appended_list, _node);
	}
	printIf(log, $"Load time: {current_time - t}"); t = current_time;
	
	try {
		for(var i = 0; i < array_length(appended_list); i++) {
			var _node = appended_list[i];
			_node.loadGroup(context);
		
			if(_node.group == context) array_push(node_create, _node);
		}
	} catch(e) {
		log_warning("APPEND, node", exception_print(e));
	}
	printIf(log, $"Load group time: {current_time - t}"); t = current_time;
	
	try {
		for(var i = 0; i < array_length(appended_list); i++)
			appended_list[i].postDeserialize();
	} catch(e) {
		log_warning("APPEND, deserialize", exception_print(e));
	}
	printIf(log, $"Deserialize time: {current_time - t}"); t = current_time;
	
	try {
		for(var i = 0; i < array_length(appended_list); i++)
			appended_list[i].applyDeserialize();
	} catch(e) {
		log_warning("LOAD, apply deserialize", exception_print(e));
	}
	printIf(log, $"Apply deserialize time: {current_time - t}"); t = current_time;
	
	try {
		// var _conn_list = array_substract(appended_list, node_create);
		var _conn_list = appended_list;
		
		for(var i = 0; i < array_length(_conn_list); i++) _conn_list[i].preConnect();
		for(var i = 0; i < array_length(_conn_list); i++) _conn_list[i].connect();
		for(var i = 0; i < array_length(_conn_list); i++) _conn_list[i].postConnect();
			
	} catch(e) {
		log_warning("APPEND, connect", exception_print(e));
	}
	printIf(log, $"Connect time: {current_time - t}"); t = current_time;
	
	try {
		for(var i = 0; i < array_length(appended_list); i++)
			appended_list[i].doUpdate();
	} catch(e) {
		log_warning("APPEND, update", exception_print(e));
	}
	printIf(log, $"Update time: {current_time - t}"); t = current_time;
	
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
	printIf(log, $"Conflict time: {current_time - t}"); t = current_time;
	
	try {
		for(var i = 0; i < array_length(appended_list); i++)
			appended_list[i].postLoad();
	} catch(e) {
		log_warning("APPEND, connect", exception_print(e));
	}
	
	UNDO_HOLDING = false;
	APPENDING    = false;
	
	if(struct_has(_map, "metadata")) {
		var meta = _map.metadata;
		for( var i = 0; i < array_length(node_create); i++ ) {
			var _node = node_create[i];
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
}