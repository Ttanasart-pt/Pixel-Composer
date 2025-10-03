function FileObject(_path) constructor {
	static loadThumbnailAsync = true;
	
	path = _path;
	name = filename_name_only(path);
	ext  = filename_ext_raw(path);
	
	spr        = -1;
	spr_path   = filename_ext_verify(path, ".png");
	spr_data   = undefined;
	sprFetchID = noone;
	
	size    = file_size(path);
	content = -1;
	
	meta_path  = filename_ext_verify(path, ".meta");
	meta	   = noone;
	type	   = FILE_TYPE.assets;
	
	retrive_data	= false;
	thumbnail_data	= -1;
	thumbnail		= noone;
	
	switch(ext) {
		case "png" :
		case "jpg" :
		case "gif" :
			type = FILE_TYPE.assets;
			break;
			
		case "pxc"  : 
		case "cpxc" : 
			type = FILE_TYPE.project;
			break;
			
		case "pxcc" : 
			type = FILE_TYPE.collection;
			break;
			
		case "pxz"  : 
			type    = FILE_TYPE.collection;
			pxz_dir = $"{TEMPDIR}{name}_{seed_random(5)}_unzip";
			break;
	}
	
	if(ext == "png") {
		var amo = 1;
		var spl = string_pos("strip", path);
		if(spl) {
			var _amo = string_copy(path, spl, string_length(path) - spl + 1);
				_amo = string_digits(_amo);
			     amo = toNumber(_amo);
		}
		
		spr_data = [ path, amo, false ];
		
	} else {
		if(file_exists_empty(spr_path))
			spr_data = [ spr_path, sprite_get_splices(spr_path), true ];
	}
	
	static getName  = function() /*=>*/ {return name};
	
	static getThumbnail = function() {
		if(!retrive_data) getMetadata();									// Metadata not loaded
		if(thumbnail != noone && is_surface(thumbnail)) return thumbnail;	// Thumbnail loaded
		if(thumbnail == undefined) return thumbnail;
		
		if(type == FILE_TYPE.project) {
			thumbnail = project_get_thumbnail_surface(path);
			return thumbnail;
		}
		
		if(thumbnail_data == -1) return noone;								// Metadata does not contains thumbnail
		if(!is_struct(thumbnail_data)) return noone;
		
		thumbnail = surface_decode(thumbnail_data);
		return thumbnail;
	}
	
	static getSpr = function() {
		if(!retrive_data) getMetadata();									// Metadata not loaded
		if(spr != -1 && sprite_exists(spr))	return spr;
		if(sprFetchID != noone) return -1;
		
		if(type == FILE_TYPE.project) {
			var s = project_get_thumbnail(path);
			if(sprite_exists(s)) { spr = s; return spr; }
		}
		
		if(spr_data == undefined) {
			spr_path = filename_ext_verify(path, ".png");
			
			if(loadThumbnailAsync) {
				sprFetchID = sprite_add_ext(spr_path, 0, 0, 0, true);
				IMAGE_FETCH_MAP[? sprFetchID] = function(_res) /*=>*/ {
					spr = _res[? "id"];
					if(spr) sprite_set_center(spr);
				}
				
			} else {
				spr = sprite_add(spr_path, 0, 0, 0, 0, 0);
				if(spr) sprite_set_center(spr);
			}
			
			return spr;
		}
		
		spr_path  = array_safe_get_fast(spr_data, 0);
		var _amo  = array_safe_get_fast(spr_data, 1);
		if(!file_exists_empty(spr_path)) return -1;
		
		if(loadThumbnailAsync) {
			sprFetchID = sprite_add_ext(spr_path, _amo, 0, 0, true);
			IMAGE_FETCH_MAP[? sprFetchID] = function(load_result) {
				spr = load_result[? "id"];
				if(spr && array_safe_get_fast(spr_data, 2))
					sprite_set_center(spr);
			}
		} else {
			spr = sprite_add(spr_path, _amo, 0, 0, 0, 0);
			if(spr && array_safe_get_fast(spr_data, 2))
				sprite_set_center(spr);
		}
		
		return spr;
	}
	
	static getMetadata = function(_createnew = false) {
		retrive_data = true;
		
		if(meta != noone)			 return meta;  
		if(meta == undefined)		 return noone; 
		if(!file_exists_empty(path)) return noone;
		
		meta = new MetaDataManager();
		
		if(ext == "pxz") {
			directory_verify(pxz_dir);
			directory_clear(pxz_dir);
			zip_unzip(path, pxz_dir);
			
			meta_path  = filename_combine(pxz_dir, $"{name}.meta");
			var _spath = filename_combine(pxz_dir, $"{name}.png");
			if(file_exists_empty(_spath)) 
				spr_data = [ _spath, sprite_get_splices(_spath), true ];
		}
		
		if(file_exists_empty(meta_path)) {
			meta.deserialize(json_load_struct(meta_path));
			
		} else {
			var m  = json_load_struct(path);
			
			if(struct_has(m, "metadata")) meta.deserialize(m.metadata);
			if(struct_has(m, "preview"))  thumbnail_data = json_try_parse(m.preview, -1);
			
			if(_createnew) json_save_struct(meta_path, meta);
		}
		
		meta.name = name;
		
		switch(filename_ext_raw(path)) {
			case "pxc"  : 
			case "cpxc" : meta.type = FILE_TYPE.project;	break;
			case "pxcc" : meta.type = FILE_TYPE.collection;	break;
			default :	  meta.type = FILE_TYPE.assets;		break;
		}
		
		return meta;
	}

	static free = function() {
		sprite_delete_safe(spr);
		surface_free_safe(thumbnail);
	}
}

function DirectoryObject(_path) constructor {
	name = filename_name_only(_path);
	path = _path;
	icon = THEME.folder_content;
	icon_blend = undefined
	
	subDir    = [];
	content   = [];
	open      = false;
	triggered = false;
	scanned   = false;
	
	static getName = function() /*=>*/ {return name};
	
	static scan = function(file_type) {
		if(path == "") return;
		
		scanned = true;
		
		var _temp_name = [];
		var _file      = file_find_first(path + "/*", fa_directory);
		while(_file != "") {
			array_push(_temp_name, _file);
			_file = file_find_next();
		}
		file_find_close();
		
		subDir  = [];
		content = [];
		
		array_sort(_temp_name, true);
		for( var i = 0; i < array_length(_temp_name); i++ ) {
			var file  = _temp_name[i];
			var _path = path + "/" + file;
			
			if(array_exists(file_type, "NodeObject") && __Node_IsFileObject(_path)) {
				var _ndir = new NodeFileObject(_path);
				array_push(content, _ndir);
				
			} else if(directory_exists(_path)) {
				var fol = new DirectoryObject(_path).scan(file_type);
				array_push(subDir, fol);
				
			} else if(array_exists(file_type, filename_ext(file))) {
				var f = new FileObject(_path);
				array_push(content, f);
			}
		}
		
		return self;
	}
	
	static draw = function(parent, _x, _y, _m, _w, _hover, _focus, _homedir, _params = {}) {
		var font = struct_try_get(_params, "font", f_p2);
		var hg   = line_get_height(font, 5);
		var hh   = 0;
		
		if(!array_empty(subDir) && _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ui(32), _y + hg - 1)) {
			draw_sprite_stretched_ext(THEME.button_hide_fill, 1, _x + ui(4), _y, ui(32 - 8), hg, CDEF.main_white, 1);
			
			if(mouse_press(mb_left, _focus)) {
				open = !open;
				MOUSE_BLOCK = true;
			}
		}
		
		var _bx = _x + ui(32);
		var _bw = _w - ui(36);
		
		if(_hover && point_in_rectangle(_m[0], _m[1], _bx, _y, _bx + _bw, _y + hg - 1)) {
			draw_sprite_stretched_ext(THEME.button_hide_fill, 1, _bx - ui(4), _y, _bw + ui(4), hg, CDEF.main_white, 1);
			if(!triggered && mouse_press(mb_left, _focus)) {
				if(!array_empty(subDir) && !open) {
					open = true;
					MOUSE_BLOCK = true;
				}
				
				parent.setContext(parent.context == self? _homedir : self);
				triggered = true;
			}
		} else if(_hover)
			triggered = false;
			
		if(triggered && mouse_release(mb_left))
			triggered = false;
		
		gpu_set_texfilter(true);
		var _spr_ind = array_empty(subDir)? parent.context == self : open;
		var _spr_bld = array_empty(subDir)? COLORS.collection_folder_empty : COLORS.collection_folder_nonempty;
		if(icon_blend != undefined) _spr_bld = icon_blend;
		
		var _spr_sca = (hg - ui(5)) / ui(24);
		draw_sprite_ui_uniform(icon, _spr_ind, _x + ui(16), _y + hg / 2 - 1, _spr_sca, _spr_bld);
		gpu_set_texfilter(false);
		
		draw_set_text(font, fa_left, fa_center, path == parent.context.path? COLORS._main_text_accent : COLORS._main_text_inner);
		draw_text_add(_x + ui(32), _y + hg / 2, name);
		hh += hg;
		_y += hg;
		
		if(open && !array_empty(subDir)) {
			var l_y = _y;
			for(var i = 0; i < array_length(subDir); i++) {
				var _hg = subDir[i].draw(parent, _x + ui(16), _y, _m, _w - ui(16), _hover, _focus, _homedir, _params);
				
				hh += _hg;
				_y += _hg;
			}
			draw_set_color(COLORS.collection_tree_line);
			draw_line(_x + ui(12), l_y, _x + ui(12), _y - ui(4));
		}
		
		return hh;
	}
	
	static destroy = function() {  }
	
	static free = function() {
		for( var i = 0, n = array_length(subDir); i < n; i++ ) 
			subDir[i].free();
			
		for( var i = 0, n = array_length(content); i < n; i++ ) 
			content[i].free();
	}
}

function readFolder(path, arr = []) {
	var _fil = file_find_first(path + "/*", 0);
	while(_fil != "") {
		array_push(arr, path + "/" + _fil);
		_fil = file_find_next();
	}
	file_find_close();
	
	var _dir  = file_find_first(path + "/*", fa_directory);
	var _dirs = [];
	while(_dir != "") {
		array_push(_dirs, path + "/" + _dir);
		_dir = file_find_next();
	}
	file_find_close();
	
	for( var i = 0, n = array_length(_dirs); i < n; i++ ) readFolder(_dirs[i], arr);
	
	return arr;
}