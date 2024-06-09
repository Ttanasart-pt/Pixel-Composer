function LOAD(safe = false) { #region
	if(DEMO) return false;
	
	var path = get_open_filename_pxc("Pixel Composer project (.pxc)|*.pxc;*.cpxc", "");
	key_release();
	if(path == "") return;
	if(!path_is_project(path)) return;
				
	gc_collect();
	var proj = LOAD_PATH(path, false, safe);
} #endregion

function TEST_PATH(path) { #region
	TESTING    = true;
	TEST_ERROR = true;
	
	PROJECT.cleanup();
	PROJECT = new Project();
	PANEL_GRAPH.setProject(PROJECT);
	
	LOAD_AT(path);
} #endregion

function LOAD_PATH(path, readonly = false, safe_mode = false) { #region
	for( var i = 0, n = array_length(PROJECTS); i < n; i++ )
		if(PROJECTS[i].path == path) closeProject(PROJECTS[i]);
	
	var _PROJECT = PROJECT;
	PROJECT = new Project();
	
	if(_PROJECT == noone) {
		PROJECTS = [ PROJECT ];
		
	} else if(_PROJECT.path == "" && !_PROJECT.modified) {
		var ind = array_find(PROJECTS, _PROJECT);
		if(ind == -1) ind = 0;
		PROJECTS[ind] = PROJECT;
		
		if(!IS_CMD) PANEL_GRAPH.setProject(PROJECT);
		
	} else {
		if(!IS_CMD) {
			var graph = new Panel_Graph(PROJECT);
			PANEL_GRAPH.panel.setContent(graph, true);
			PANEL_GRAPH = graph;
		}
		array_push(PROJECTS, PROJECT);
	}
	
	var res = LOAD_AT(path, readonly);
	if(!res) return false;
	
	PROJECT.safeMode = safe_mode;
	if(!IS_CMD) 
		setFocus(PANEL_GRAPH.panel);
	
	return PROJECT;
} #endregion

function LOAD_AT(path, readonly = false, override = false) { #region
	static log = false;
	
	CALL("load");
	
	printIf(log, $"========== Loading {path} =========="); var t0 = get_timer(), t1 = get_timer();
	
	if(DEMO) return false;
	
	if(!file_exists_empty(path)) {
		log_warning("LOAD", $"File not found: {path}");
		return false;
	}
	
	if(!path_is_project(path)) {
		log_warning("LOAD", "File not a valid PROJECT");
		return false;
	}
	
	LOADING = true;
	
	if(override) {
		nodeCleanUp();
		clearPanel();
		setPanel();
		if(!TESTING)
			instance_destroy(_p_dialog);
		ds_list_clear(ERRORS);
	}
	
	printIf(log, $" > Check file : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	var temp_path = TEMPDIR;
	directory_verify(temp_path);
	
	var temp_file_path = TEMPDIR + string(UUID_generate(6));
	if(file_exists_empty(temp_file_path)) file_delete(temp_file_path);
	file_copy(path, temp_file_path);
	
	PROJECT.readonly = readonly;
	SET_PATH(PROJECT, path);
	
	printIf(log, $" > Create temp : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	var _load_content;
	var _ext = filename_ext_raw(path);
	var s;
	
	if(_ext == "pxc") {
		var f = file_text_open_read(path);
		s = file_text_read_all(f);
		file_text_close(f);
		
	} else if(_ext == "cpxc") {
		var b = buffer_decompress(buffer_load(path));
		s = buffer_read(b, buffer_string);
	}
	
	_load_content = json_try_parse(s);
	
	printIf(log, $" > Load struct : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	if(struct_has(_load_content, "version")) {
		var _v = _load_content.version;
		
		PROJECT.version = _v;
		LOADING_VERSION = _v;
		
		if(PREFERENCES.notify_load_version && floor(_v) != floor(SAVE_VERSION)) {
			var warn = $"File version mismatch : loading file version {_v} to Pixel Composer {SAVE_VERSION}";
			log_warning("LOAD", warn);
		}
	} else {
		var warn = $"File version mismatch : loading old format to Pixel Composer {SAVE_VERSION}";
		log_warning("LOAD", warn);
	}
	
	printIf(log, $" > Load meta : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	var create_list = [];
	if(struct_has(_load_content, "nodes")) {
		try {
			var _node_list = _load_content.nodes;
			for(var i = 0, n = array_length(_node_list); i < n; i++) {
				var _node = nodeLoad(_node_list[i]);
				if(_node) array_push(create_list, _node);
			}
		} catch(e) {
			log_warning("LOAD", exception_print(e));
		}
	}
	
	PROJECT.deserialize(_load_content);
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	try {
		array_foreach(create_list, function(node) { node.loadGroup(); } );
		
	} catch(e) {
		log_warning("LOAD, group", exception_print(e));
		return false;
	}
	
	printIf(log, $" > Load group : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		array_foreach(create_list, function(node) { node.postDeserialize(); } );
	} catch(e) {
		log_warning("LOAD, deserialize", exception_print(e));
	}
	
	printIf(log, $" > Deserialize: {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		array_foreach(create_list, function(node) { node.applyDeserialize(); } );
	} catch(e) {
		log_warning("LOAD, apply deserialize", exception_print(e));
	}
	
	printIf(log, $" > Apply deserialize : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		array_foreach(create_list, function(node) { node.preConnect();  } );
		array_foreach(create_list, function(node) { node.connect();     } );
		array_foreach(create_list, function(node) { node.postConnect(); } );
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	printIf(log, $" > Connect : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		try {
			while(++pass < 4 && !ds_queue_empty(CONNECTION_CONFLICT)) {
				var size = ds_queue_size(CONNECTION_CONFLICT);
				log_message("LOAD", $"[Connect] {size} Connection conflict(s) detected (pass: {pass})");
				repeat(size) ds_queue_dequeue(CONNECTION_CONFLICT).connect();
				repeat(size) ds_queue_dequeue(CONNECTION_CONFLICT).postConnect();
				Render();
			}
			
			if(!ds_queue_empty(CONNECTION_CONFLICT))
				log_warning("LOAD", "Some connection(s) is unsolved. This may caused by render node not being update properly, or image path is broken.");
		} catch(e) {
			log_warning("LOAD, connect solver", exception_print(e));
		}
	}
	
	printIf(log, $" > Conflict : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		array_foreach(create_list, function(node) { node.postLoad(); } );
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	printIf(log, $" > Post load : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		array_foreach(create_list, function(node) { node.clearInputCache(); } );
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	printIf(log, $" > Clear cache : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	RENDER_ALL_REORDER
	
	LOADING = false;
	PROJECT.modified = false;
	
	log_message("FILE", "load " + path, THEME.noti_icon_file_load);
	log_console("Loaded project: " + path);
	
	if(!IS_CMD) PANEL_MENU.setNotiIcon(THEME.noti_icon_file_load);
	
	refreshNodeMap();
	
	printIf(log, $" > Refresh map : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	if(struct_has(_load_content, "timelines") && !array_empty(_load_content.timelines.contents))
		PROJECT.timelines.deserialize(_load_content.timelines);
	
	printIf(log, $" > Timeline : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	if(!IS_CMD) run_in(1, PANEL_GRAPH.toCenterNode);
	
	printIf(log, $"========== Load {array_length(PROJECT.allNodes)} nodes completed in {(get_timer() - t0) / 1000} ms ==========");
	
	return true;
} #endregion

function __IMPORT_ZIP() { #region
	var path = get_open_filename_pxc("Pixel Composer portable project (.zip)|*.zip", "");
	
	var _fname = filename_name_only(path);
	var _fext  = filename_ext(path);
	if(_fext != ".zip") return false;
	
	directory_verify(TEMPDIR + "proj/");
	var _dir = TEMPDIR + "proj/" + _fname;
	directory_create(_dir);
	zip_unzip(path, _dir);
	
	var _f    = file_find_first(_dir + "/*.pxc", fa_none);
	var _proj = $"{_dir}/{_f}";
	print(_proj);
	if(!file_exists_empty(_proj)) return false;
	
	LOAD_PATH(_proj, true);
} #endregion