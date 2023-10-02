function LOAD() {
	if(DEMO) return false;
	
	var path = get_open_filename("Pixel Composer PROJECT (.pxc)|*.pxc", "");
	key_release();
	if(path == "") return;
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") return;
				
	gc_collect();
	LOAD_PATH(path);
}

function TEST_PATH(path) {
	TESTING = true;
	TEST_ERROR = true;
	
	PROJECT.cleanup();
	PROJECT = new Project();
	PANEL_GRAPH.setProject(PROJECT);
	
	__LOAD_PATH(path, false, false);
}

function LOAD_PATH(path, readonly = false, safe_mode = false) {
	for( var i = 0, n = array_length(PROJECTS); i < n; i++ )
		if(PROJECTS[i].path == path) return;
	
	var _PROJECT = PROJECT;
	PROJECT = new Project();
	if(PANEL_GRAPH.project.path == "" && !PANEL_GRAPH.project.modified) {
		var ind = array_find(PROJECTS, PANEL_GRAPH.project);
		if(ind == -1) ind = 0;
		PROJECTS[ind] = PROJECT;
		
		PANEL_GRAPH.setProject(PROJECT);
	} else {
		var graph = new Panel_Graph(PROJECT);
		PANEL_GRAPH.panel.setContent(graph, true);
		PANEL_GRAPH = graph;
		array_push(PROJECTS, PROJECT);
	}
	
	var res = __LOAD_PATH(path, readonly, safe_mode);
	if(!res) return false;
	
	PANEL_ANIMATION.updatePropertyList();
	setFocus(PANEL_GRAPH.panel);
	
	return PROJECT;
}

function __LOAD_PATH(path, readonly = false, safe_mode = false, override = false) {
	SAFE_MODE = safe_mode;
	
	if(DEMO) return false;
	
	if(!file_exists(path)) {
		log_warning("LOAD", "File not found");
		return false;
	}
	
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") {
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
	
	var temp_path = DIRECTORY + "temp";
	if(!directory_exists(temp_path))
		directory_create(temp_path);
	
	var temp_file_path = temp_path + "/" + string(UUID_generate(6));
	if(file_exists(temp_file_path)) file_delete(temp_file_path);
	file_copy(path, temp_file_path);
	
	//ALWAYS_FULL = false;
	PROJECT.readonly = readonly;
	SET_PATH(PROJECT, path);
	
	var _load_content = json_load_struct(temp_file_path);
	
	if(struct_has(_load_content, "version")) {
		var _v = _load_content.version;
		PROJECT.version = _v;
		if(_v != SAVE_VERSION) {
			var warn = $"File version mismatch : loading file version {_v} to Pixel Composer {SAVE_VERSION}";
			log_warning("LOAD", warn);
		}
	} else {
		var warn = $"File version mismatch : loading old format to Pixel Composer {SAVE_VERSION}";
		log_warning("LOAD", warn);
	}
	
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
			var _anim_map = _load_content.animator;
			PROJECT.animator.frames_total	= _anim_map.frames_total;
			PROJECT.animator.framerate		= _anim_map.framerate;
		}
	} catch(e) {
		log_warning("LOAD, animator", exception_print(e));
	}
	
	if(struct_has(_load_content, "onion_skin"))
		PROJECT.onion_skin = _load_content.onion_skin;
	
	if(struct_has(_load_content, "previewGrid"))
		PROJECT.previewGrid = _load_content.previewGrid;
	
	if(struct_has(_load_content, "graphGrid"))
		PROJECT.graphGrid = _load_content.graphGrid;
	
	try {
		if(struct_has(_load_content, "metadata"))
			METADATA.deserialize(_load_content.metadata);
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
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].loadGroup();
	} catch(e) {
		log_warning("LOAD, group", exception_print(e));
		return false;
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
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].clearInputCache();
	} catch(e) {
		log_warning("LOAD, connect", exception_print(e));
	}
	
	RENDER_ALL_REORDER
	
	LOADING = false;
	PROJECT.modified = false;
	
	log_message("FILE", "load " + path, THEME.noti_icon_file_load);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_load);
	
	refreshNodeMap();
	
	return true;
}