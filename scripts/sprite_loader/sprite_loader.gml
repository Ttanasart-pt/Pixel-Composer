globalvar THEME_DEF;
THEME_DEF = true;

function __initTheme() { #region
	var root = DIRECTORY + "Themes";
	
	directory_verify(root);
	
	if(check_version($"{root}/version")) {
		log_message("THEME", $"unzipping default theme to {root}.");
		zip_unzip("data/Theme.zip", root);
	}
	
	var t = get_timer();
	
	loadGraphic(PREFERENCES.theme);	print($"     > Load graphic | complete in {get_timer() - t}");    t = get_timer();
	loadColor(PREFERENCES.theme);	print($"     > Load color   | complete in {get_timer() - t}");    t = get_timer();
} #endregion

function _sprite_path(rel, theme) { #region
	INLINE
	return $"{DIRECTORY}Themes/{theme}/graphics/{string_replace_all(rel, "./", "")}";
} #endregion

function _sprite_load_from_struct(str, theme, key) { #region
	INLINE
	
	var path = _sprite_path(str.path, theme);
	var s    = sprite_add(path, str.subimages, false, true, str.xorigin, str.yorigin);
	
	if(str.slice) {
		var slice = sprite_nineslice_create();	
		slice.enabled = str.slice.enabled;
		slice.left    = str.slice.left;
		slice.right   = str.slice.right;
		slice.top     = str.slice.top;
		slice.bottom  = str.slice.bottom;
		
		if(struct_has(str.slice, "tilemode"))
			slice.tilemode = str.slice.tilemode;
		
		if(s >= 0) sprite_set_nineslice(s, slice);
		else log_message("THEME", $"Load sprite {path} failed.");
	}
	return s; 
} #endregion

function loadGraphic(theme = "default") { #region
	var path   = _sprite_path("./graphics.json", theme);
	
	if(THEME_DEF) {
		var sprStr   = json_load_struct(path);
		var graphics = variable_struct_get_names(sprStr);
		var str;
	
		for( var i = 0, n = array_length(graphics); i < n; i++ ) {
			var key = graphics[i];
			
			if(struct_has(sprStr, key)) {
				str = sprStr[$ key];
				THEME[$ key] = _sprite_load_from_struct(str, theme, key);
			} else {
				noti_status($"Graphic resource for {key} not found. Rollback to default directory.");
			
				str = sprDef[$ key];
				THEME[$ key] = _sprite_load_from_struct(str, "default", key);
			}
		}
		return;
	}
	
	var sprDef = json_load_struct(_sprite_path("./graphics.json", "default"));
	var _metaP = $"{DIRECTORY}Themes/{theme}/meta.json";
	
	if(!file_exists_empty(_metaP))
		noti_warning("Loading theme made for older version.");
	else {
		var _meta = json_load_struct(_metaP);
		if(_meta[$ "version"] < VERSION)
			noti_warning("Loading theme made for older version.");
	}
	
	print($"Loading theme {theme}");
	if(!file_exists_empty(path)) {
		print("Theme not defined at " + path + ", rollback to default theme.");	
		return;
	}
	
	var graphics = variable_struct_get_names(sprDef);
	var sprStr   = json_load_struct(path);
	var str;
	
	for( var i = 0, n = array_length(graphics); i < n; i++ ) {
		var key = graphics[i];
			
		if(struct_has(sprStr, key)) {
			str = sprStr[$ key];
			THEME[$ key] = _sprite_load_from_struct(str, theme, key);
		} else {
			noti_status($"Graphic resource for {key} not found. Rollback to default directory.");
			
			str = sprDef[$ key];
			THEME[$ key] = _sprite_load_from_struct(str, "default", key);
		}
	}
} #endregion