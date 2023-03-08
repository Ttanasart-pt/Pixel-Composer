#region locale
	globalvar LOCALE;
	LOCALE = {}
	
	function __initLocale() {
		var lfile = "data/locale/en.json";
		var root = DIRECTORY + "Locale";
		var path = root + "/en.json";
		
		if(!directory_exists(root))
			directory_create(root);
		
		file_copy(lfile, path);
		LOCALE = json_load_struct(path);
	}
	
	function get_text(key, def = "") {
		if(!struct_has(LOCALE, key)) return def;
		return LOCALE[$ key];
	}
#endregion