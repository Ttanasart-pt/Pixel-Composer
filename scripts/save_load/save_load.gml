function NEW() {
	clearNodes();
	setPanel();
	room_restart();
				
	gc_collect();
}

function clearNodes() {
	var key = ds_map_find_first(NODE_MAP);
	repeat(ds_map_size(NODE_MAP)) {
		if(NODE_MAP[? key])
			delete NODE_MAP[? key];
		key = ds_map_find_next(NODE_MAP, key);
	}
	ds_map_clear(NODE_MAP);
	ds_list_clear(NODES);	
}

function save_serialize() {
	var _map  = ds_map_create();
	_map[? "version"] = SAVEFILE_VERSION;
	
	var _node_list = ds_list_create();
	var _key = ds_map_find_first(NODE_MAP);
	
	repeat(ds_map_size(NODE_MAP)) {
		var _node = NODE_MAP[? _key];
		if(_node.active) {
			ds_list_add_map(_node_list, _node.serialize());
		}
		
		_key = ds_map_find_next(NODE_MAP, _key);	
	}
	ds_map_add_list(_map, "nodes", _node_list);
	
	var _anim_map = ds_map_create();
	_anim_map[? "frames_total"] = ANIMATOR.frames_total;
	_anim_map[? "framerate"] = ANIMATOR.framerate;
	ds_map_add_map(_map, "animator", _anim_map);
	
	var val  = json_encode(_map);
	ds_map_destroy(_map);
	return val;
}

function load_deserialize(_map) {
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
	
	clearNodes();
	
	if(ds_map_exists(_map, "nodes")) {
		var _node_list = _map[? "nodes"];
		for(var i = 0; i < ds_list_size(_node_list); i++) {
			nodeLoad(_node_list[| i]);
		}
	}
	
	if(ds_map_exists(_map, "animator")) {
		var _anim_map			= _map[? "animator"];
		ANIMATOR.frames_total	= _anim_map[? "frames_total"];
		ANIMATOR.framerate		= _anim_map[? "framerate"];
	}
}

function SET_PATH(path) {
	if(READONLY)
		window_set_caption("[READ ONLY] " + filename_name(path) + " - Pixel Composer");
	else {
		var index = ds_list_find_index(RECENT_FILES, path);
		if(CURRENT_PATH != path) {
			if(index != -1)
				ds_list_delete(RECENT_FILES, index);
			ds_list_insert(RECENT_FILES, 0, path);
			RECENT_SAVE();
		}
		window_set_caption(filename_name(path) + " - Pixel Composer");
	}
	
	CURRENT_PATH = path;
}

function SAVE() {
	if(CURRENT_PATH == "" || READONLY) {
		SAVE_AS();
	} else {
		SAVE_AT(CURRENT_PATH);
	}
}

function SAVE_AS() {
	var path = get_save_filename(".pxc", "");
	if(path == "") return;
	
	if(filename_ext(path) == "") {
		path += ".pxc";
	} else if(filename_ext(path) != ".pxc") {
		path = string_replace(path, filename_ext(path), ".pxc");
	}
	
	if(file_exists(path))
		PANEL_MENU.addNotiExtra("Overrided file : " + path);
	SAVE_AT(path);
	SET_PATH(path);
}

function SAVE_AT(path) {
	if(file_exists(path))
		file_delete(path);
	var file = file_text_open_write(path);
	file_text_write_string(file, save_serialize());
	file_text_close(file);
	
	READONLY  = false;
	
	log_message("FILE", "save at " + path);
	PANEL_MENU.showNoti("File saved", s_noti_icon_save);
}

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
	
	APPEND_ID	= 0;
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
	load_deserialize(_map);
	ds_map_destroy(_map);
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	var _key = ds_map_find_first(NODE_MAP);
	repeat(ds_map_size(NODE_MAP)) {
		var _node = NODE_MAP[? _key];
		if(_node.is_dynamic_output) {
			_node.connect();
			_node.update();
		}
		
		_key = ds_map_find_next(NODE_MAP, _key);
	}
	
	var _key = ds_map_find_first(NODE_MAP);
	repeat(ds_map_size(NODE_MAP)) {
		var _node = NODE_MAP[? _key];
		_node.connect();
		_node.rendered = false;
		
		_key = ds_map_find_next(NODE_MAP, _key);
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
	PANEL_MENU.showNoti("File loaded", s_noti_icon_file);
	return true;
}

function APPEND(_path) {
	APPEND_ID	= NODE_ID + 1;
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
			PANEL_MENU.addNotiExtra(warn);
		}
	} else {
		var warn = "File version mismatch : loading old format to Pixel Composer " + string(SAVEFILE_VERSION);
		log_warning("FILE", warn)
		PANEL_MENU.addNotiExtra(warn);
	}
	
	var _node_list = _map[? "nodes"];
	var appended_list = ds_list_create();
	var node_create = ds_list_create();
	
	for(var i = 0; i < ds_list_size(_node_list); i++) {
		var _node = nodeLoad(_node_list[| i], true);
		if(_node)
			ds_list_add(appended_list, _node);
	}
	ds_map_destroy(_map);
	file_text_close(file);
	
	for(var i = 0; i < ds_list_size(appended_list); i++) {
		var _node = appended_list[| i];
		_node.connect();
		
		if(_node.group == PANEL_GRAPH.getCurrentContext())
			ds_list_add(node_create, _node);
	}
	
	for(var i = 0; i < ds_list_size(appended_list); i++) {
		appended_list[| i].doUpdate();
	}
	
	ds_list_destroy(appended_list);
	
	renderAll();
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		while(++pass < 2 && !ds_queue_empty(CONNECTION_CONFLICT)) {
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
	
	APPENDING = false;
	PANEL_ANIMATION.updatePropertyList();
	
	log_message("FILE", "append file " + _path);
	return node_create;
}

function SAVE_COLLECTIONS(_list, _path, save_surface = true) {
	var file = file_text_open_write(_path);
	var _map  = ds_map_create();
	_map[? "version"] = SAVEFILE_VERSION;
	
	var _node_list = ds_list_create();
	var cx = 0;
	var cy = 0;
	for(var i = 0; i < ds_list_size(_list); i++) {
		cx += _list[| i].x;
		cy += _list[| i].y;
	}
	cx = round((cx / ds_list_size(_list)) / 32) * 32;
	cy = round((cy / ds_list_size(_list)) / 32) * 32;
	
	if(save_surface) {
		if(PANEL_PREVIEW.preview_surface && is_surface(PANEL_PREVIEW.preview_surface)) {
			var icon_path = string_copy(_path, 1, string_length(_path) - 5) + ".png";
			surface_save(PANEL_PREVIEW.preview_surface, icon_path);
		}
	}
	
	for(var i = 0; i < ds_list_size(_list); i++)
		SAVE_NODE(_node_list, _list[| i], cx, cy, true);
	ds_map_add_list(_map, "nodes", _node_list);
		
	file_text_write_string(file, json_encode(_map));
	file_text_close(file);
	
	ds_map_destroy(_map);
	var pane = findPanel("Panel_Collection", PANEL_MAIN, noone);
	if(pane) pane.searchFolder();
}

function SAVE_COLLECTION(_node, _path, save_surface = true) {
	if(save_surface) {
		if(PANEL_PREVIEW.preview_surface && is_surface(PANEL_PREVIEW.preview_surface)) {
			var icon_path = string_copy(_path, 1, string_length(_path) - 5) + ".png";
			surface_save(PANEL_PREVIEW.preview_surface, icon_path);
		}
	}
	
	var file = file_text_open_write(_path);
	var _map  = ds_map_create();
	_map[? "version"] = SAVEFILE_VERSION;
	
	var _node_list = ds_list_create();
	SAVE_NODE(_node_list, _node, _node.x, _node.y, true);
	ds_map_add_list(_map, "nodes", _node_list);
		
	file_text_write_string(file, json_encode(_map));
	file_text_close(file);
	
	ds_map_destroy(_map);
	var pane = findPanel("Panel_Collection", PANEL_MAIN, noone);
	if(pane) pane.searchFolder();
}

function SAVE_NODE(_list, _node, dx = 0, dy = 0, scale = false) {
	if(variable_struct_exists(_node, "nodes")) {
		for(var i = 0; i < ds_list_size(_node.nodes); i++) {
			var _n = _node.nodes[| i];
			SAVE_NODE(_list, _n, dx, dy, scale);
		}
	}
	
	var m = _node.serialize(scale);
	m[? "x"] -= dx;
	m[? "y"] -= dy;
	var c = PANEL_GRAPH.getCurrentContext();
	if(c != -1) c = c.node_id;
	if(m[? "group"] == c)
		m[? "group"] = -1;
	
	ds_list_add(_list, m);
	ds_list_mark_as_map(_list, ds_list_size(_list) - 1);
}