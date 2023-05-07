#region locale
	globalvar LOCALE;
	LOCALE = {}
	
	function __initLocale() {
		var lfile = "data/locale/en.json";
		var root = DIRECTORY + "Locale";
		var path = root + "/en.json";
		
		if(!directory_exists(root))
			directory_create(root);
		
		var _l = root + "/version";
		if(file_exists(_l)) {
			var res = json_load_struct(_l);
			if(!is_struct(res) || !struct_has(res, "version") || res.version != BUILD_NUMBER) 
				file_copy(lfile, path);
		} else 
			file_copy(lfile, path);
		
		LOCALE = json_load_struct(path);
		
		json_save_struct(_l, { version: BUILD_NUMBER });
	}
	
	function get_text(key, def = "") {
		if(!struct_has(LOCALE, key)) return def;
		return LOCALE[$ key];
	}
#endregion