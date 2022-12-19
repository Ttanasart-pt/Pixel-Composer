function __init_theme() {
	var root = DIRECTORY + "Themes";
	if(!directory_exists(root))
		directory_create(root);
			
	var _l = root + "\\_theme" + string(VERSION);
	
	//if(file_exists(_l)) return;
	log_message("THEME", "unzipping default theme to DIRECTORY.");
	var f = file_text_open_write(_l);
	file_text_write_real(f, 0);
	file_text_close(f);
	
	zip_unzip("data/themes/default.zip", root);
}

function _sprite_path(rel, theme) {
	return DIRECTORY + "themes/" + theme + "/graphics/" + string_replace_all(rel, "./", "");
}

function _sprite_load_from_struct(str, theme, key) {
	var path = _sprite_path(str.path, theme);
	var s = sprite_add(path, str.subimages, false, false, str.xorigin, str.yorigin);
	if(str.slice) {
		var slice = sprite_nineslice_create();	
		slice.enabled = str.slice.enabled;
		slice.left    = str.slice.left;
		slice.right   = str.slice.right;
		slice.top     = str.slice.top;
		slice.bottom  = str.slice.bottom;
		
		sprite_set_nineslice(s, slice);
	}
	return s; 
}

function __getGraphicList() {
	var path = _sprite_path("./graphics.json", "default");
	var f = file_text_open_read(path);
	var s = file_text_read_all(f);
	file_text_close(f);
	
	return json_parse(s);
}

function loadGraphic(theme = "default") {
	var sprDef = __getGraphicList();
	var path = _sprite_path("./graphics.json", theme);
	
	if(!file_exists(path)) {
		noti_status("Theme not defined at " + path + ", rollback to default theme.");	
		return;
	}
	
	var f = file_text_open_read(path);
	var s = file_text_read_all(f);
	file_text_close(f);
	
	var graphics = variable_struct_get_names(sprDef);
	var sprStr = json_parse(s);
	
	for( var i = 0; i < array_length(graphics); i++ ) {
		var key = graphics[i];
		
		if(variable_struct_exists(sprStr, key)) {
			var str = variable_struct_get(sprStr, key);
			variable_struct_set(THEME, key, _sprite_load_from_struct(str, theme, key));
		} else {
			noti_status("Graphic resource for " + string(key) + " not found. Rollback to default directory.");
			
			var str = variable_struct_get(sprDef, key);
			variable_struct_set(THEME, key, _sprite_load_from_struct(str, "default", key));
		}
	}
}