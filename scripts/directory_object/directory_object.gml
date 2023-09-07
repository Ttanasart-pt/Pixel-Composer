function FileObject(_name, _path) constructor {
	static loadThumbnailAsync = false;
	
	name = _name;
	path = _path;
	spr_path = [];
	spr        = -1;
	sprFetchID = noone;
	
	content   = -1;
	surface   = noone;
	
	var _mdir  = filename_dir(path);
	var _mname = filename_name_only(path);
	meta_path  = $"{_mdir}/{_mname}.meta";	
	meta	   = noone;
	type	   = FILE_TYPE.collection;
	
	switch(string_lower(filename_ext(path))) {
		case ".png" :	
		case ".jpg" :	
		case ".gif" :	
			type = FILE_TYPE.assets;
			break;
		case ".pxc" :	
			type = FILE_TYPE.project;
			break;
	}
	
	retrive_data = false;
	thumbnail_data = -1;
	thumbnail = noone;
	size = file_size(path);
	
	static getName = function() { return name; }
	
	static getSurface = function() {
		if(is_surface(surface)) return surface;
		var spr = getSpr();
		surface = surface_create_from_sprite_ext(spr, 0);
		return surface;
	}
	
	static getThumbnail = function() { 
		if(size > 100000) return noone;
		if(!retrive_data) getMetadata();
		
		if(thumbnail_data == -1) return noone;
		if(thumbnail != noone && is_surface(thumbnail)) return thumbnail;
		
		thumbnail = surface_decode(thumbnail_data);
	}
	
	static getSpr = function() {
		if(sprite_exists(spr))  return spr;
		if(sprFetchID != noone) return -1;
		
		if(array_length(spr_path) == 0) {
			if(loadThumbnailAsync) {
				sprFetchID = sprite_add_ext(self.path, 0, 0, 0, true);
				IMAGE_FETCH_MAP[? sprFetchID] = function(load_result) {
					spr = load_result[? "id"];
					if(spr) sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
				};
			} else {
				spr = sprite_add(self.path, 0, false, false, 0, 0);
				if(spr) sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
			}
			return spr;
		}
		
		var path = array_safe_get(spr_path, 0);
		var amo  = array_safe_get(spr_path, 1);
		
		if(path == 0) return -1;
		
		if(loadThumbnailAsync) {
			sprFetchID = sprite_add_ext(path, amo, 0, 0, true);
			IMAGE_FETCH_MAP[? sprFetchID] = function(load_result) {
				spr = load_result[? "id"];
				if(spr && array_safe_get(spr_path, 2))
					sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
			}
		} else {
			spr = sprite_add(path, amo, false, false, 0, 0);
			if(spr && array_safe_get(spr_path, 2))
				sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2);
		}
		
		return spr;
	}
	
	static getMetadata = function() { 
		retrive_data = true;
		
		if(!file_exists(path))	return noone; 
		if(meta != noone)		return meta;  
		if(meta == undefined)	return noone; 
		
		meta = new MetaDataManager();
		
		if(file_exists(meta_path)) {
			meta.deserialize(json_load_struct(meta_path));
		} else {
			var m  = json_load_struct(path);
			
			if(struct_has(m, "metadata")) meta.deserialize(m.metadata);
			if(struct_has(m, "preview"))  thumbnail_data = json_try_parse(m.preview, -1);
		}
		
		meta.name = name;
		
		switch(filename_ext(path)) {
			case ".pxc"  : meta.type = FILE_TYPE.project;		break;
			case ".pxcc" : meta.type = FILE_TYPE.collection;	break;
			default :	   meta.type = FILE_TYPE.assets;		break;
		}
		
		return meta;
	}
}

function DirectoryObject(name, path) constructor {
	self.name = name;
	self.path = path;
	
	subDir  = ds_list_create();
	content = ds_list_create();
	open    = false;
	
	static destroy = function() { ds_list_destroy(subDir); }
	static getName = function() { return name; }
	
	static scan = function(file_type) {
		var _temp_name = ds_list_create();
		var folder = file_find_first(path + "/*", fa_directory);
		while(folder != "") {
			ds_list_add(_temp_name, folder);
			folder = file_find_next();
		}
		file_find_close();
		
		ds_list_clear(subDir);
		ds_list_clear(content);
		
		ds_list_sort(_temp_name, true);
		for( var i = 0; i < ds_list_size(_temp_name); i++ ) {
			var file = _temp_name[| i];
			
			if(directory_exists(path + "/" + file)) {
				var _fol_path = path + "/" + file;
				var fol = new DirectoryObject(file, _fol_path);
				fol.scan(file_type);
				ds_list_add(subDir, fol);
			} else if(array_exists(file_type, filename_ext(file))) {
				var f = new FileObject(string_replace(file, filename_ext(file), ""), path + "/" + file);
				ds_list_add(content, f);
				
				if(string_lower(filename_ext(file)) == ".png") {
					var icon_path = path + "/" + file;
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
					if(!file_exists(icon_path)) continue;
					
					var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
					var ww = sprite_get_width(_temp);
					var hh = sprite_get_height(_temp);
					var amo = safe_mod(ww, hh) == 0? ww / hh : 1;
					sprite_delete(_temp);
					
					f.spr_path = [icon_path, amo, true];
				}
			}
		}
		
		ds_list_destroy(_temp_name);
	}
	
	static draw = function(parent, _x, _y, _m, _w, _hover, _focus, _homedir) {
		var hg = ui(28);
		var hh = 0;
		
		if(path == parent.context.path)
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x + ui(28), _y, _w - ui(36), hg, COLORS.collection_path_current_bg, 1); 
		
		if(!ds_list_empty(subDir) && _hover && point_in_rectangle(_m[0], _m[1], _x, _y, ui(32), _y + hg - 1)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x, _y, ui(32), hg, COLORS.collection_path_current_bg, 1);
			if(mouse_press(mb_left, _focus))
				open = !open;
		}
		
		if(_hover && point_in_rectangle(_m[0], _m[1], _x + ui(32), _y, _w, _y + hg - 1)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x + ui(28), _y, _w - ui(36), hg, COLORS.collection_path_current_bg, 1);
			if(mouse_press(mb_left, _focus)) {
				if(!ds_list_empty(subDir))
					open = !open;
				
				if(parent.context == self)
					parent.setContext(_homedir);
				else
					parent.setContext(self);
			}
		}
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
		
		if(ds_list_empty(subDir))
			draw_sprite_ui_uniform(THEME.folder_content, parent.context == self, _x + ui(16), _y + hg / 2 - 1, 1, COLORS.collection_folder_empty);
		else
			draw_sprite_ui_uniform(THEME.folder_content, open, _x + ui(16), _y + hg / 2 - 1, 1, COLORS.collection_folder_nonempty);
		
		draw_text(_x + ui(32), _y + hg / 2, name);
		hh += hg;
		_y += hg;
		
		if(open && !ds_list_empty(subDir)) {
			var l_y = _y;
			for(var i = 0; i < ds_list_size(subDir); i++) {
				var _hg = subDir[| i].draw(parent, _x + ui(16), _y, _m, _w - ui(16), _hover, _focus, _homedir);
				draw_set_color(COLORS.collection_tree_line);
				draw_line(_x + ui(12), _y + hg / 2, _x + ui(16), _y + hg / 2);
				
				hh += _hg;
				_y += _hg;
			}
			draw_set_color(COLORS.collection_tree_line);
			draw_line(_x + ui(12), l_y, _x + ui(12), _y - hg / 2);
		}
		
		return hh;
	}
}