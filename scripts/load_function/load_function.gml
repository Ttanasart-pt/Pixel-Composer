function __loadParams(readonly = false, override = false, apply_layout = false) constructor {
	self.readonly = readonly;
	self.override = override;
	
	self.apply_layout = apply_layout;
}

function LOAD_SAFE() { LOAD(true); }

function LOAD(safe = false) {
	if(DEMO) return false;
	
	var path = get_open_filename_compat("Pixel Composer project (.pxc)|*.pxc;*.cpxc", "");
	key_release();
	if(path == "") return;
	
	if(!path_is_project(path)) return;
				
	gc_collect();
	var proj = LOAD_PATH(path, false, safe);
}

function TEST_PATH(path) {
	TESTING    = true;
	TEST_ERROR = true;
	
	PROJECT.cleanup();
	PROJECT = new Project();
	
	LOAD_AT(path);
	Render();
	closeProject(PROJECT);
}

function LOAD_PATH(path, readonly = false, safe_mode = false) {
	var _rep = false;
	
	for( var i = array_length(PROJECTS) - 1; i >= 0; i-- ) {
		var _p = array_safe_get_fast(PROJECTS, i);
		if(!is_instanceof(_p, Project)) continue;
		
		if(_p.path == path) {
			_rep = true;
			closeProject(_p);
		}
	}
	
	var _PROJECT = PROJECT;
	PROJECT = new Project();
	
	if(_PROJECT == noone) {
		PROJECTS = [ PROJECT ];
		
	} else if(!_rep && ((_PROJECT.path == "" || _PROJECT.readonly) && !_PROJECT.modified)) {
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
	
	var res = LOAD_AT(path, new __loadParams(readonly));
	if(!res) return false;
	
	PROJECT.safeMode = safe_mode;
	if(!IS_CMD) setFocus(PANEL_GRAPH.panel);
	
	if(PROJECT.meta.author_steam_id) PROJECT.meta.steam = FILE_STEAM_TYPE.steamOpen;
	
	return PROJECT;
}

function LOAD_AT(path, params = new __loadParams()) {
	static log = 0;
	
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
	
	if(params.override) {
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
	ds_map_clear(APPEND_MAP);
	
	var temp_file_path = TEMPDIR + string(UUID_generate(6));
	if(file_exists_empty(temp_file_path)) file_delete(temp_file_path);
	file_copy(path, temp_file_path);
	
	PROJECT.readonly = params.readonly;
	SET_PATH(PROJECT, path);
	
	printIf(log, $" > Create temp : {(get_timer() - t1) / 1000} ms"); t1 = get_timer();
	
	#region read 
		var _ext    = filename_ext_raw(path), s;
		var rawBuff = buffer_load(path);
		var offset  = 0;
		buffer_to_start(rawBuff);
		
		var _id = buffer_read_text(rawBuff, 4);
		var contBuff = rawBuff;
		
		if(_id == "PXCX") {
			offset   = buffer_read(rawBuff, buffer_u32);
			contBuff = buffer_create(1, buffer_grow, 1);
			buffer_copy(rawBuff, offset, buffer_get_size(rawBuff) - offset, contBuff, 0);
		}
		
		var compBuff = buffer_decompress(contBuff);
		if(compBuff == -1) {
			s = buffer_read(contBuff, buffer_string);
		} else {
			s = buffer_read(compBuff, buffer_string);
			buffer_delete(compBuff);
		}
		
		buffer_delete_safe(rawBuff);
		buffer_delete_safe(contBuff);
	#endregion
	
	var content = json_try_parse(s);
	printIf(log, $" > Load struct : {(get_timer() - t1) / 1000} ms");
	
	return instance_create(0, 0, project_loader, { path, content, log, params, t0, t1 });
}

function __EXPORT_ZIP()	{ exportPortable(PROJECT); }
function __IMPORT_ZIP() {
	var _path = get_open_filename_compat("Pixel Composer portable project (.zip)|*.zip", "");
	if(!file_exists_empty(_path)) return;
	
	var _fname = filename_name_only(_path);
	var _fext  = filename_ext(_path);
	if(_fext != ".zip") return false;
	
	directory_verify(TEMPDIR + "proj/");
	var _dir = TEMPDIR + "proj/" + _fname;
	directory_create(_dir);
	zip_unzip(_path, _dir);
	
	var _f    = file_find_first(_dir + "/*.pxc", fa_none);
	var _proj = $"{_dir}/{_f}";
	print(_proj);
	if(!file_exists_empty(_proj)) return false;
	
	LOAD_PATH(_proj, true);
}