function LOAD(safe = false) { #region
	if(DEMO) return false;
	
	var path = get_open_filename("Pixel Composer project (.pxc)|*.pxc;*.cpxc", "");
	key_release();
	if(path == "") return;
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") return;
				
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
	
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc" && filename_ext(path) != ".cpxc") {
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
	var _ext = filename_ext(path);
	var s;
	
	if(_ext == ".pxc") {
		var f = file_text_open_read(path);
		s = file_text_read_all(f);
		file_text_close(f);
		
	} else if(_ext == ".cpxc") {
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
	
	var create_list = ds_list_create();
	if(struct_has(_load_content, "nodes")) {
		try {
			var _node_list = _load_content.nodes;
			for(var i = 0, n = array_length(_node_list); i < n; i++) {
				// printIf(log, $"   >> Loading nodes : {_node_list[i].type}");
				var _node = nodeLoad(_node_list[i]);
				if(_node) ds_list_add(create_list, _node);
			}
		} catch(e) {
			log_warning("LOAD", exception_print(e));
		}
	}
	
	printIf(log, $" > Load nodes : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		if(struct_has(_load_content, "animator")) {
			var _anim_map = _load_content.animator;
			PROJECT.animator.frames_total	= struct_try_get(_anim_map, "frames_total",   30);
			PROJECT.animator.framerate		= struct_try_get(_anim_map, "framerate",      30);
			PROJECT.animator.frame_range	= struct_try_get(_anim_map, "frame_range", noone);
		}
	} catch(e) {
		log_warning("LOAD, animator", exception_print(e));
	}
	
	if(struct_has(_load_content, "onion_skin"))
		struct_override(PROJECT.onion_skin, _load_content.onion_skin);
	
	if(struct_has(_load_content, "previewGrid"))
		struct_override(PROJECT.previewGrid, _load_content.previewGrid);
	
	if(struct_has(_load_content, "graphGrid"))
		struct_override(PROJECT.graphGrid, _load_content.graphGrid);
	
	if(struct_has(_load_content, "attributes"))
		struct_override(PROJECT.attributes, _load_content.attributes);
	PROJECT.setPalette();
	
	if(struct_has(_load_content, "notes")) {
		PROJECT.notes = array_create(array_length(_load_content.notes));
		for( var i = 0, n = array_length(_load_content.notes); i < n; i++ )
			PROJECT.notes[i] = new Note.deserialize(_load_content.notes[i]);
	}
	
	try {
		if(struct_has(_load_content, "metadata"))
			PROJECT.meta.deserialize(_load_content.metadata);
	} catch(e) {
		log_warning("LOAD, metadata", exception_print(e));
	}
	
	PROJECT.globalNode = new Node_Global();
	try {
		if(struct_has(_load_content, "global"))
			PROJECT.globalNode.deserialize(_load_content.global);
		else if(struct_has(_load_content, "global_node"))
			PROJECT.globalNode.deserialize(_load_content.global_node);
	} catch(e) {
		log_warning("LOAD, global", exception_print(e));
	}
	
	try {
		if(struct_has(_load_content, "addon")) {
			var _addon = _load_content.addon;
			PROJECT.addons = _addon;
			struct_foreach(_addon, function(_name, _value) { addonLoad(_name, false); });
		} else 
			PROJECT.addons = {};
	} catch(e) {
		log_warning("LOAD, addon", exception_print(e));
	}
	
	printIf(log, $" > Load data : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].loadGroup();
	} catch(e) {
		log_warning("LOAD, group", exception_print(e));
		return false;
	}
	
	printIf(log, $" > Load group : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].postDeserialize();
	} catch(e) {
		log_warning("LOAD, deserialize", exception_print(e));
	}
	
	printIf(log, $" > Deserialize: {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].applyDeserialize();
	} catch(e) {
		log_warning("LOAD, apply deserialize", exception_print(e));
	}
	
	printIf(log, $" > Apply deserialize : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].preConnect();
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].connect();
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].postConnect();
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
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].postLoad();
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	printIf(log, $" > Post load : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].clearInputCache();
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
	
	printIf(log, $"========== Load {ds_map_size(PROJECT.nodeMap)} nodes completed in {(get_timer() - t0) / 1000} ms ==========");
	
	return true;
} #endregion

function __IMPORT_ZIP() { #region
	var path = get_open_filename("Pixel Composer portable project (.zip)|*.zip", "");
	
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