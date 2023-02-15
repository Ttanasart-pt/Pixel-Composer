function NEW() {
	nodeCleanUp();
	setPanel();
	instance_destroy(_p_dialog);
	room_restart();
	
	gc_collect();
	SET_PATH("");
	
	SAFE_MODE = false;
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
	
	var _graph_map = ds_map_create();
	_graph_map[? "graph_x"] = PANEL_GRAPH.graph_x;
	_graph_map[? "graph_y"] = PANEL_GRAPH.graph_y;
	ds_map_add_map(_map, "graph", _graph_map);
	
	ds_map_add_map(_map, "metadata", METADATA.serialize());
	
	var val  = json_encode_minify(_map);
	ds_map_destroy(_map);
	return val;
}

function SET_PATH(path) {
	if(path == "") {
		READONLY = false;
	} else if(!READONLY) {
		var index = ds_list_find_index(RECENT_FILES, path);
		if(CURRENT_PATH != path) {
			if(index != -1)
				ds_list_delete(RECENT_FILES, index);
			ds_list_insert(RECENT_FILES, 0, path);
			RECENT_SAVE();
		}
		CURRENT_PATH = filename_name(path);
	}
	
	CURRENT_PATH = path;
}

function SAVE() {
	if(DEMO) return false;
	
	if(CURRENT_PATH == "" || READONLY)
		return SAVE_AS();
	return SAVE_AT(CURRENT_PATH);
}

function SAVE_AS() {
	if(DEMO) return false;
	
	var path = get_save_filename("Pixel Composer project (.pxc)|*.pxc", "");	
	if(path == "") return false;
	
	if(filename_ext(path) != ".pxc")
		path += ".pxc";
	
	if(file_exists(path))
		log_warning("SAVE", "Overrided file : " + path);
	SAVE_AT(path);
	SET_PATH(path);
	
	return true;
}

function SAVE_AT(path, log = "save at ") {
	if(DEMO) return false;
	
	if(file_exists(path))
		file_delete(path);
	var file = file_text_open_write(path);
	file_text_write_string(file, save_serialize());
	file_text_close(file);
	
	READONLY  = false;
	MODIFIED  = false;
	
	log_message("FILE", log + path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
	
	return true;
}

function SAVE_COLLECTIONS(_list, _path, save_surface = true, metadata = noone) {
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
		var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
		if(is_surface(preview_surface)) {
			var icon_path = string_copy(_path, 1, string_length(_path) - 5) + ".png";
			surface_save(preview_surface, icon_path);
		}
	}
	
	for(var i = 0; i < ds_list_size(_list); i++)
		SAVE_NODE(_node_list, _list[| i], cx, cy, true);
	ds_map_add_list(_map, "nodes", _node_list);
	
	if(metadata != noone)
		ds_map_add_map(_map, "metadata", metadata.serialize());
	
	var file = file_text_open_write(_path);
	file_text_write_string(file, json_encode_minify(_map));
	file_text_close(file);
	
	ds_map_destroy(_map);
	var pane = findPanel(Panel_Collection, PANEL_MAIN, noone);
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}

function SAVE_COLLECTION(_node, _path, save_surface = true, metadata = noone) {
	if(save_surface) {
		var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
		if(is_surface(preview_surface)) {
			var icon_path = string_copy(_path, 1, string_length(_path) - 5) + ".png";
			surface_save(preview_surface, icon_path);
		}
	}
	
	var _map  = ds_map_create();
	_map[? "version"] = SAVEFILE_VERSION;
	
	var _node_list = ds_list_create();
	SAVE_NODE(_node_list, _node, _node.x, _node.y, true);
	ds_map_add_list(_map, "nodes", _node_list);
	
	if(metadata != noone)
		ds_map_add_map(_map, "metadata", metadata.serialize());
	
	var file = file_text_open_write(_path);
	file_text_write_string(file, json_encode_minify(_map));
	file_text_close(file);
	
	ds_map_destroy(_map);
	var pane = findPanel(Panel_Collection, PANEL_MAIN, noone);
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
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