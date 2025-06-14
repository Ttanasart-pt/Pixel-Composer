globalvar THEME_DEF; THEME_DEF = true;
globalvar THEME; 

function sprite_drawer(_draw) constructor {
	static draw = function(_x, _y, scale, color, alpha) {}
	draw = _draw;
}

function __initTheme() {
	var root = DIRECTORY + "Themes";
	var t    = get_timer();
	
	directory_verify(root);
	
	if(check_version($"{root}/version")) {
		zip_unzip($"{working_directory}data/theme.zip", root);	printDebug($"     > Unzip theme  | complete in {get_timer() - t}");    t = get_timer();
	}
	
	loadColor(PREFERENCES.theme);			printDebug($"     > Load color   | complete in {get_timer() - t}");    t = get_timer();
	loadGraphic(PREFERENCES.theme);			printDebug($"     > Load graphic | complete in {get_timer() - t}");    t = get_timer();
}

function _sprite_path(rel, theme) { INLINE return $"{DIRECTORY}Themes/{theme}/graphics/{string_replace_all(rel, "./", "")}"; }

function _sprite_load_from_struct(str, theme, key) {
	var path = _sprite_path(str.path, theme);
	var numb = struct_try_get(str, "s", 1);
	var sx   = struct_try_get(str, "x", 0) * THEME_SCALE;
	var sy   = struct_try_get(str, "y", 0) * THEME_SCALE;
	
	var _path = filename_os(path);
	
	if(!file_exists_empty(_path)) { log_message("THEME", $"Load sprite {_path} failed: Path not exists."); return 0; }
	
	var s = sprite_add(_path, numb, false, true, sx, sy);
	if( s < 0) { log_message("THEME", $"Load sprite {_path} failed: Cannot read file."); return 0; }
	
	if(!struct_has(str, "slice")) return s;
	
	var slice = sprite_nineslice_create();	
	slice.enabled = true;
	
	var _sw = sprite_get_width(s);
	var _sh = sprite_get_height(s);
	
	if(is_array(str.slice)) {
		slice.left    = str.slice[0] > 0? str.slice[0] : _sw / 2 + str.slice[0];
		slice.right   = str.slice[1] > 0? str.slice[1] : _sw / 2 + str.slice[1];
		slice.top     = str.slice[2] > 0? str.slice[2] : _sh / 2 + str.slice[2];
		slice.bottom  = str.slice[3] > 0? str.slice[3] : _sh / 2 + str.slice[3];
		
	} else if(is_real(str.slice)) {
		var _sl = str.slice > 0? str.slice : _sw / 2 + str.slice;
		slice.left    = _sl;
		slice.right   = _sl;
		slice.top     = _sl;
		slice.bottom  = _sl;
		
	}
	
	if(struct_has(str, "slicemode"))
		slice.tilemode = array_create(5, str.slicemode);
	
	sprite_set_nineslice(s, slice);
	
	return s; 
}

function loadGraphic(theme = "default") {
	THEME = {};
	
	var path   = _sprite_path("./graphics.json", theme);
	var sprDef = json_load_struct(_sprite_path("./graphics.json", "default"));
	var _metaP = $"{DIRECTORY}Themes/{theme}/meta.json";
	
	if(!file_exists_empty(_metaP))
		noti_warning("Loading theme made for older version.");
	else {
		var _meta = json_load_struct(_metaP);
		if(_meta[$ "version"] < VERSION)
			noti_warning("Loading theme made for older version.");
	}
	
	printDebug($"Loading theme {theme}");
	if(!file_exists_empty(path)) { print($"Theme not defined at {path}, rollback to default theme."); return; }
	
	var sprStr   = json_load_struct(path);
	var graphics = variable_struct_get_names(sprStr);
	var str, key;
	
	for( var i = 0, n = array_length(graphics); i < n; i++ ) {
		key = graphics[i];
		str = sprStr[$ key];
		
		THEME[$ key] = _sprite_load_from_struct(str, theme, key);
	}
	
	THEME.dPath_open = new sprite_drawer(function(_x, _y, scale, color, alpha) /*=>*/ {
		draw_sprite_ui_uniform(THEME.path_open, 0, _x, _y, scale, color, alpha);
		draw_sprite_ui_uniform(THEME.path_open, 1, _x, _y, scale, c_white, alpha);
	});
	
}