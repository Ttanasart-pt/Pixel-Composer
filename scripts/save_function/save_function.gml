globalvar SAVING, IS_SAVING;
SAVING    = false;
IS_SAVING = false;

function NEW() {
	CALL("new");
	
	PROJECT = new Project();
	array_push(PROJECTS, PROJECT);
	
	var graph = new Panel_Graph(PROJECT);
	PANEL_GRAPH.panel.setContent(graph, true);
	PANEL_GRAPH = graph;
}

function SERIALIZE_PROJECT(project = PROJECT) {
	if(!is(project, Project)) return "";
	
	var _map = project.serialize();
	return PREFERENCES.save_file_minify? json_stringify_minify(_map) : json_stringify(_map, true);
}

function SET_PATH(project, path) {
	if(ASSERTING) return;
	
	if(path == "") {
		project.readonly = false;
		
	} else if(!project.readonly) {
		ds_list_remove(RECENT_FILES, path);
		ds_list_insert(RECENT_FILES, 0, path);
		while(ds_list_size(RECENT_FILES) > 64)
			ds_list_delete(RECENT_FILES, ds_list_size(RECENT_FILES) - 1);
		RECENT_SAVE();
		RECENT_REFRESH();
	}
	
	project.path = path;
}

function SAVE_ALL() {
	for( var i = 0, n = array_length(PROJECTS); i < n; i++ )
		SAVE(PROJECTS[i]);
}

function SAVE(project = PROJECT) {
	if(DEMO) return false;
	if(!is(project, Project)) return false;
	
	if(project.path == "" || project.freeze || project.readonly || path_is_backup(project.path))
		return SAVE_AS(project);
		
	return SAVE_AT(project, project.path);
}

function SAVE_AS(project = PROJECT) {
	if(DEMO) return false;
	
	var path = get_save_filename_compat("Pixel Composer project (.pxc)|*.pxc|Compressed Pixel Composer project (.cpxc)|*.cpxc", "");
	
	key_release();
	if(path == "") return false;
	
	if(!path_is_project(path, false))
		path = filename_ext_verify_add(path, ".pxc");
	
	if(file_exists_empty(path))
		log_warning("SAVE", "Overrided file : " + path);
	SAVE_AT(project, path);
	SET_PATH(project, path);
	
	return true;
}

function SAVE_AT(project = PROJECT, path = "", log = "save at ", _thum = true) {
	CALL("save");
	
	if(DEMO) return false;
	
	IS_SAVING = true;
	SAVING    = true;
	
	if(PREFERENCES.save_backup) {
		for(var i = PREFERENCES.save_backup - 1; i >= 0; i--) {
			var _p = path;
			if(i) _p = $"{path}{i}"
			
			if(file_exists(_p)) file_rename(_p, $"{path}{i + 1}");
		}
	}
	
	if(file_exists_empty(path)) file_delete(path);
	var _ext = filename_ext_raw(path);
	var _prj = SERIALIZE_PROJECT(project);
	var _raw = buffer_compress_string(_prj);
	var _buf = buffer_create(1, buffer_grow, 1);
	
	#region thumbnail
		var _thumbSurf = PANEL_PREVIEW.getNodePreviewSurface();
		if(!is_surface(_thumbSurf)) _thumbSurf = PANEL_PREVIEW.panel.content_surface;
		
		var _thumbSize = 64;
		var _thumbLeng = 0;
		var _thumbData = 0;
		var _thumb     = _thum && PREFERENCES.save_thumbnail && is_surface(_thumbSurf);
		
		if(_thumb) {
			var _thumbDrawSurf = surface_create(_thumbSize, _thumbSize);
			surface_set_target(_thumbDrawSurf);
				DRAW_CLEAR
				BLEND_OVERRIDE
				var _sw = surface_get_width(_thumbSurf);
				var _sh = surface_get_height(_thumbSurf);
				var _ss = _thumbSize / min(_sw, _sh);
				var h = _thumbSize / 2;
				
				draw_surface_ext(_thumbSurf, h - _sw * _ss / 2, h - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
				BLEND_NORMAL
			surface_reset_target();
			
			_thumbData = buffer_from_surface(_thumbDrawSurf, false);
			_thumbData = buffer_compress(_thumbData, 0, buffer_get_size(_thumbData));
			_thumbLeng = buffer_get_size(_thumbData);
			
			surface_free(_thumbDrawSurf);
		}
	#endregion
	
	#region write header
		buffer_to_start(_buf);
		buffer_write(_buf, buffer_text, "PXCX");
		buffer_write(_buf, buffer_u32,  0);
		
		if(_thumb) {
			buffer_write(_buf, buffer_text, "THMB");
			buffer_write(_buf, buffer_u32,  _thumbLeng);
			buffer_copy(_thumbData, 0, _thumbLeng, _buf, buffer_tell(_buf));
			
			buffer_seek(_buf, buffer_seek_relative, _thumbLeng);
		}
		
		buffer_write(_buf, buffer_text,   "META");
		var _metaPos = buffer_tell(_buf);
		buffer_write(_buf, buffer_u32,    0);
		buffer_write(_buf, buffer_u32,    SAVE_VERSION);
		buffer_write(_buf, buffer_string, VERSION_STRING);
		var _metaCon = buffer_tell(_buf);
		buffer_write_at(_buf, _metaPos, buffer_u32, _metaCon - _metaPos - 4);
		buffer_seek(_buf, buffer_seek_start, _metaCon);
		
		var _headerSize = buffer_tell(_buf);
		buffer_write_at(_buf, 4, buffer_u32, _headerSize);
		
		buffer_copy(_raw, 0, buffer_get_size(_raw), _buf, _headerSize);
	    buffer_save(_buf, path);
		
		buffer_delete(_raw);
		buffer_delete(_buf);
	#endregion
	
	SAVING = false;
	project.readonly  = false;
	project.modified  = false;
	
	log_message("FILE", log + path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
	
	return true;
}

/////////////////////////////////////////////////////// COLLECTION ///////////////////////////////////////////////////////

function SAVE_COLLECTIONS(_list, _path, save_surface = true, metadata = noone, context = PANEL_GRAPH.getCurrentContext()) {
	var _content = {};
	_content.version = SAVE_VERSION;
	
	var _nodes = [];
	var cx     = 0;
	var cy     = 0;
	var amo    = array_length(_list);
	
	for(var i = 0; i < amo; i++) {
		cx += _list[i].x;
		cy += _list[i].y;
	}
	
	cx = round((cx / amo) / 32) * 32;
	cy = round((cy / amo) / 32) * 32;
	
	if(save_surface) {
		var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
		if(is_surface(preview_surface)) {
			var icon_path = string_copy(_path, 1, string_length(_path) - 5) + ".png";
			surface_save_safe(preview_surface, icon_path);
		}
	}
	
	for(var i = 0; i < amo; i++)
		SAVE_NODE(_nodes, _list[i], cx, cy, true, context);
	_content.nodes = _nodes;
	
	json_save_struct(_path, _content, !PREFERENCES.save_file_minify);
	
	if(metadata != noone) {
		var _meta  = metadata.serialize();
		var _dir   = filename_dir(_path);
		var _name  = filename_name_only(_path);
		var _mpath = $"{_dir}/{_name}.meta";
		
		json_save_struct(_mpath, _meta, true);
	}
	
	var pane = findPanel("Panel_Collection");
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}

function SAVE_NODE(_arr, _node, dx = 0, dy = 0, scale = false, context = PANEL_GRAPH.getCurrentContext()) {
	if(struct_has(_node, "nodes")) {
		for(var i = 0; i < array_length(_node.nodes); i++)
			SAVE_NODE(_arr, _node.nodes[i], dx, dy, scale, context);
	}
	
	var m = _node.serialize(scale);
	if(!is_struct(m)) return;
	
	m.x -= dx;
	m.y -= dy;
	
	if(context != noone && struct_has(m, "group") && m.group == context.node_id) 
		m.group = noone;
	
	array_push(_arr, m);
}

function SAVE_COLLECTION(_node, _path, save_surface = true, metadata = noone, context = PANEL_GRAPH.getCurrentContext()) {
	if(save_surface) {
		var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
		if(is_surface(preview_surface)) {
			var icon_path = string_replace(_path, filename_ext(_path), "") + ".png";
			surface_save_safe(preview_surface, icon_path);
		}
	}
	
	var _content = {};
	_content.version = SAVE_VERSION;
	
	var _nodes = [];
	SAVE_NODE(_nodes, _node, _node.x, _node.y, true, context);
	_content.nodes = _nodes;
	
	json_save_struct(_path, _content, !PREFERENCES.save_file_minify);
	
	if(metadata != noone) {
		var _meta  = metadata.serialize();
		var _dir   = filename_dir(_path);
		var _name  = filename_name_only(_path);
		var _mpath = $"{_dir}/{_name}.meta";
		
		_meta.version = SAVE_VERSION;
		json_save_struct(_mpath, _meta, true);
	}
	
	var pane = findPanel("Panel_Collection");
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}

function SAVE_PXZ_COLLECTION(_node, _path, _surf = noone, metadata = noone, context = PANEL_GRAPH.getCurrentContext()) {
	var _name = filename_name_only(_path);
	var _path_icon = "";
	var _path_node = "";
	var _path_meta = "";
	
	if(is_surface(_surf)) {
		_path_icon = $"{TEMPDIR}{_name}.png";
		surface_save_safe(_surf, _path_icon);
	}
	
	var _content = {};
	_content.version = SAVE_VERSION;
	
	var _nodes = [];
	SAVE_NODE(_nodes, _node, _node.x, _node.y, true, context);
	_content.nodes = _nodes;
	
	_path_node = $"{TEMPDIR}{_name}.pxcc";
	json_save_struct(_path_node, _content, !PREFERENCES.save_file_minify);
	
	if(metadata != noone) {
		var _meta  = metadata.serialize();
		var _dir   = filename_dir(_path);
		var _name  = filename_name_only(_path);
		_path_meta = $"{TEMPDIR}{_name}.meta";
		
		_meta.version = SAVE_VERSION;
		json_save_struct(_path_meta, _meta, true);
	}
	
	print(_path_node);
	
	var _z = zip_create();
	if(_path_icon != "") zip_add_file(_z, $"{_name}.png",  _path_icon);
	if(_path_node != "") zip_add_file(_z, $"{_name}.pxcc", _path_node);
	if(_path_meta != "") zip_add_file(_z, $"{_name}.meta", _path_meta);
	zip_save(_z, _path);
	
	var pane = findPanel("Panel_Collection");
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}