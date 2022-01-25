function DirectoryObject(name, path) constructor {
	self.name = name;
	self.path = path;
	
	subDir = ds_list_create();
	content = ds_list_create();
	open = false;
	
	static destroy = function() {
		ds_list_destroy(subDir);
	}
	
	static getSub = function() {
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
			
			if(directory_exists(path + "\\" + file)) {
				var _fol_path = path + "\\" + file;
				var fol = new DirectoryObject(file, _fol_path);
				ds_list_add(subDir, fol);
			} else if(filename_ext(file) == ".json" || filename_ext(file) == ".pxcc") {
				var f = new FileObject(string_copy(file, 1, string_length(file) - 5), path + "\\" + file);
				ds_list_add(content, f);
				var icon_path = path + "\\" + string_copy(file, 1, string_length(file) - 5) + ".png";
				
				if(file_exists(icon_path)) {
					var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
					var ww = sprite_get_width(_temp);
					var hh = sprite_get_height(_temp);
					var amo = ww % hh == 0? ww / hh : 1;
					sprite_delete(_temp);
					
					f.spr = sprite_add(icon_path, amo, false, false, 0, 0);
					sprite_set_offset(f.spr, sprite_get_width(f.spr) / 2, sprite_get_height(f.spr) / 2);
				}
			}
		}
		
		ds_list_destroy(_temp_name);
	}
	getSub();
	
	static draw = function(_x, _y, _m, _w) {
		var hg = 28;
		var hh = 0;
		
		if(path == PANEL_COLLECTION.context.path)
			draw_sprite_stretched_ext(s_ui_panel_bg, 0, _x, _y, _w, hg, c_ui_blue_ltgrey, 1); 
		
		if(HOVER == PANEL_COLLECTION.panel && point_in_rectangle(_m[0], _m[1], 0, _y, _w, _y + hg - 1)) {
			draw_sprite_stretched_ext(s_ui_panel_bg, 0, _x, _y, _w, hg, c_ui_blue_white, 1);
			if(FOCUS == PANEL_COLLECTION.panel && mouse_check_button_pressed(mb_left)) {
				open = !open;
				
				if(PANEL_COLLECTION.context = self)
					PANEL_COLLECTION.setContext(COLLECTIONS);
				else
					PANEL_COLLECTION.setContext(self);
			}
		}
					
		draw_set_text(f_p0, fa_left, fa_center, c_white);
		if(ds_list_empty(subDir)) {
			draw_sprite_ext(s_folder_24, 0, _x + 16, _y + hg / 2 - 1, 1, 1, 0, c_ui_blue_dkgrey, 1);
		} else {
			draw_sprite_ext(s_folder_content_24, open, _x + 16, _y + hg / 2 - 1, 1, 1, 0, c_ui_blue_grey, 1);
		}
		draw_text(_x + 8 + 24, _y + hg / 2, name);
		hh += hg;
		_y += hg;
		
		if(open && !ds_list_empty(subDir)) {
			var l_y = _y;
			for(var i = 0; i < ds_list_size(subDir); i++) {
				var _hg = subDir[| i].draw(_x + 16, _y, _m, _w - 16);
				draw_set_color(c_ui_blue_dkgrey);
				draw_line(_x + 12, _y + hg / 2, _x + 12 + 4, _y + hg / 2);
				
				hh += _hg;
				_y += _hg;
			}
			draw_set_color(c_ui_blue_dkgrey);
			draw_line(_x + 12, l_y, _x + 12, _y - hg / 2);
		}
		
		return hh;
	}
}

function FileObject(_name, _path) constructor {
	name = _name;
	path = _path;
	spr  = -1;
}

function __init_collection() {
	log_message("COLLECTION", "init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
	var _ = DIRECTORY + "Collections";
	var _l = _ + "\\coll" + string(VERSION);
	if(!file_exists(_l)) {
		log_message("COLLECTION", "unzipping new collection to DIRECTORY.");
		var f = file_text_open_write(_l);
		file_text_write_real(f, 0);
		file_text_close(f);
		
		zip_unzip("Collections.zip", _);
	}
	
	refreshCollections();
}

function refreshCollections() {
	log_message("COLLECTION", "refreshing collection base folder.");
	
	if(!directory_exists(DIRECTORY + "Collections")) {
		directory_create(DIRECTORY + "Collections");
		return;
	}
	
	COLLECTIONS = new DirectoryObject("Collections", DIRECTORY + "Collections");
	COLLECTIONS.open = true;
}

function searchCollection(_list, _search_str, _claer_list = true) {
	if(_claer_list)
		ds_list_clear(_list);
	
	if(_search_str == "") return;
	var search_lower = string_lower(_search_str);
		
	var st = ds_stack_create();
	ds_stack_push(st, COLLECTIONS);
		
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < ds_list_size(_st.content); i++ ) {
			var _nd = _st.content[| i];
				
			var match = string_pos(search_lower, string_lower(_nd.name)) > 0;
			if(match) {
				ds_list_add(_list, _nd);
			}
		}
			
		for( var i = 0; i < ds_list_size(_st.subDir); i++ ) {
			ds_stack_push(st, _st.subDir[| i]);
		}
	}
		
	ds_stack_destroy(st);
}