function FileObject(_path) constructor {
	static loadThumbnailAsync = true;
	
	name = filename_name_only(_path);
	path = _path;
	
	spr_path   = [];
	spr        = -1;
	sprFetchID = noone;
	
	size    = file_size(path);
	content = -1;
	
	var _mdir  = filename_dir(path);
	var _mname = filename_name_only(path);
	meta_path  = $"{_mdir}/{_mname}.meta";	
	meta	   = noone;
	type	   = FILE_TYPE.assets;
	
	switch(filename_ext_raw(path)) {
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
		case "pxz"  : 
			type = FILE_TYPE.collection;
			break;
	}
	
	retrive_data	= false;
	thumbnail_data	= -1;
	thumbnail		= noone;
	
	static getName  = function() /*=>*/ {return name};
	
	static getThumbnail = function() {
		if(thumbnail != noone && is_surface(thumbnail)) return thumbnail;	// Thumbnail loaded
		
		if(size > 100000) return noone;										// File too large
		if(!retrive_data) getMetadata();									// Metadata not loaded
		
		if(thumbnail_data == -1) return noone;								// Metadata does not contains thumbnail
		if(!is_struct(thumbnail_data)) return noone;
		
		thumbnail = surface_decode(thumbnail_data);
		return thumbnail;
	}
	
	static getSpr = function() {
		if(spr != -1 && sprite_exists(spr))	return spr;
		if(sprFetchID != noone) return -1;
		
		if(array_empty(spr_path)) {
			if(loadThumbnailAsync) {
				sprFetchID = sprite_add_ext(self.path, 0, 0, 0, true);
				IMAGE_FETCH_MAP[? sprFetchID] = function(load_result) {
					spr = load_result[? "id"];
					if(spr) sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
				};
			} else {
				spr = sprite_add(self.path, 0, 0, 0, 0, 0);
				if(spr) sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
			}
			
			return spr;
		}
		
		var _path = array_safe_get_fast(spr_path, 0);
		var _amo  = array_safe_get_fast(spr_path, 1);
		
		if(!file_exists_empty(_path)) return -1;
		
		if(loadThumbnailAsync) {
			sprFetchID = sprite_add_ext(_path, _amo, 0, 0, true);
			IMAGE_FETCH_MAP[? sprFetchID] = function(load_result) {
				spr = load_result[? "id"];
				if(spr && array_safe_get_fast(spr_path, 2))
					sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
			}
		} else {
			spr = sprite_add(_path, _amo, 0, 0, 0, 0);
			if(spr && array_safe_get_fast(spr_path, 2))
				sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
		}
		
		return spr;
	}
	
	static getMetadata = function(_createnew = false) {
		retrive_data = true;
		
		if(meta != noone)			 return meta;  
		if(meta == undefined)		 return noone; 
		if(!file_exists_empty(path)) return noone;
		
		meta = new MetaDataManager();
		
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
}

function DirectoryObject(_path) constructor {
	name = filename_name_only(_path);
	path = _path;
	icon = THEME.folder_content;
	icon_blend = undefined
	
	subDir    = ds_list_create();
	content   = ds_list_create();
	open      = false;
	triggered = false;
	scanned   = false;
	
	static destroy = function() { ds_list_destroy(subDir); }
	static getName = function() { return name; }
	
	static scan = function(file_type) {
		scanned = true;
		
		var _temp_name = [];
		var _file      = file_find_first(path + "/*", fa_directory);
		while(_file != "") {
			array_push(_temp_name, _file);
			_file = file_find_next();
		}
		file_find_close();
		
		ds_list_clear(subDir);
		ds_list_clear(content);
		
		array_sort(_temp_name, true);
		for( var i = 0; i < array_length(_temp_name); i++ ) {
			var file  = _temp_name[i];
			var _path = path + "/" + file;
			
			if(array_exists(file_type, "NodeObject") && __Node_IsFileObject(_path)) {
				var _ndir = new NodeFileObject(_path);
				ds_list_add(content, _ndir);
				
			} else if(directory_exists(_path)) {
				var fol = new DirectoryObject(_path)
								.scan(file_type);
				ds_list_add(subDir, fol);
				
			} else if(array_exists(file_type, filename_ext(file))) {
				var f = new FileObject(_path);
				ds_list_add(content, f);
				
				if(string_lower(filename_ext(file)) == ".png") {
					var icon_path = _path;
					var amo = 1;
					var p = string_pos("strip", icon_path);
					if(p) {
						var _amo = string_copy(icon_path, p, string_length(icon_path) - p + 1);
							_amo = string_digits(_amo);
						     amo = toNumber(_amo);
					}
					f.spr_path = [icon_path, amo, false];
					
				} else {
					var icon_path = path + "/" + filename_change_ext(file, ".png");
					if(!file_exists_empty(icon_path)) continue;
					
					var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
					var ww    = sprite_get_width(_temp);
					var hh    = sprite_get_height(_temp);
					var amo   = safe_mod(ww, hh) == 0? ww / hh : 1;
					sprite_delete(_temp);
					
					f.spr_path = [icon_path, amo, true];
				}
			}
		}
		
		return self;
	}
	
	static draw = function(parent, _x, _y, _m, _w, _hover, _focus, _homedir, _params = {}) {
		var font = struct_try_get(_params, "font", f_p1);
		var hg   = line_get_height(font, 5);
		var hh   = 0;
		
		if(!ds_list_empty(subDir) && _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ui(32), _y + hg - 1)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x, _y, ui(32), hg, CDEF.main_white, 1);
			if(mouse_press(mb_left, _focus)) {
				open = !open;
				MOUSE_BLOCK = true;
			}
		}
		
		var _bx = _x + ui(32);
		var _bw = _w - ui(36);
		
		if(_hover && point_in_rectangle(_m[0], _m[1], _bx, _y, _bx + _bw, _y + hg - 1)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _bx - ui(4), _y, _bw + ui(4), hg, CDEF.main_white, 1);
			if(!triggered && mouse_press(mb_left, _focus)) {
				if(!ds_list_empty(subDir) && !open) {
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
		var _spr_ind = ds_list_empty(subDir)? parent.context == self : open;
		var _spr_bld = ds_list_empty(subDir)? COLORS.collection_folder_empty : COLORS.collection_folder_nonempty;
		if(icon_blend != undefined) _spr_bld = icon_blend;
		
		var _spr_sca = (hg - ui(5)) / 24;
		draw_sprite_uniform(icon, _spr_ind, _x + ui(16), _y + hg / 2 - 1, _spr_sca, _spr_bld);
		gpu_set_texfilter(false);
		
		draw_set_text(font, fa_left, fa_center, path == parent.context.path? COLORS._main_text_accent : COLORS._main_text_inner);
		draw_text_add(_x + ui(32), _y + hg / 2, name);
		hh += hg;
		_y += hg;
		
		if(open && !ds_list_empty(subDir)) {
			var l_y = _y;
			for(var i = 0; i < ds_list_size(subDir); i++) {
				var _hg = subDir[| i].draw(parent, _x + ui(16), _y, _m, _w - ui(16), _hover, _focus, _homedir, _params);
				
				hh += _hg;
				_y += _hg;
			}
			draw_set_color(COLORS.collection_tree_line);
			draw_line(_x + ui(12), l_y, _x + ui(12), _y - ui(4));
		}
		
		return hh;
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