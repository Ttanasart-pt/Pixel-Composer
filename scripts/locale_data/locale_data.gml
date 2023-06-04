#region locale
	globalvar LOCALE;
	LOCALE = {}
	
	function __initLocale() {
		var lfile = $"data/locale/en.json";
		var root  = $"{DIRECTORY}Locale";
		var path  = $"{root}/en.json";
		
		if(!directory_exists(root))
			directory_create(root);
		if(file_exists(path))
			file_delete(path);
		file_copy(lfile, path);
		
		loadLocale();
	}
	
	function loadLocale() {
		var path = $"{DIRECTORY}Locale/{PREF_MAP[? "local"]}.json";
		if(!file_exists(path)) 
			path = $"{DIRECTORY}Locale/en.json";
		
		LOCALE = json_load_struct(path);
	}
	
	function __txtx(key, def = "") {
		if(!struct_has(LOCALE, key)) {
			print($"LOCAL \"{key}\": \"{def}\",");
			return def;
		}
		
		return ""//LOCALE[$ key];
	}
	
	function __txt(txt, prefix = "") {
		var key = string_lower(txt);
		    key = string_replace_all(key, " ", "_");
			
		return __txtx(prefix + key, txt);
	}
#endregion