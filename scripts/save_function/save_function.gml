function NEW() {
	clearNodes();
	setPanel();
	room_restart();
				
	gc_collect();
	CURRENT_PATH = "";
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
	PANEL_MENU.showNoti("File saved", s_noti_icon_file_save);
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