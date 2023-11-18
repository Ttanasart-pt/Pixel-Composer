#region locale
	globalvar LOCALE, TEST_LOCALE, LOCALE_USE_DEFAULT;
	LOCALE = {}
	TEST_LOCALE = false;
	LOCALE_USE_DEFAULT = true;
	
	function __initLocale() {
		var lfile = $"data/locale/en.zip";
		var root  = $"{DIRECTORY}Locale";
		
		directory_verify(root);
		if(check_version($"{root}/version"))
			zip_unzip(lfile, root);
		
		loadLocale();
	}
	
	function __locale_file(file) {
		var dirr = $"{DIRECTORY}Locale/{PREFERENCES.local}";
		if(!directory_exists(dirr) || !file_exists(dirr + file)) 
			dirr = $"{DIRECTORY}Locale/en";
		return dirr + file;
	}
	
	function loadLocale() {
		LOCALE.word = json_load_struct(__locale_file("/words.json"));
		LOCALE.ui   = json_load_struct(__locale_file("/UI.json"));
		LOCALE.node = json_load_struct(__locale_file("/nodes.json"));
		LOCALE.config = json_load_struct(__locale_file("/config.json"));
		
		var fontDir = $"{DIRECTORY}Locale/{PREFERENCES.local}/fonts/";
		LOCALE.fontDir = directory_exists(fontDir)? fontDir : noone;
		
		print("FONT DIR: " + fontDir);
	}
	
	function __txtx(key, def = "") {
		INLINE
		
		if(key == "") return "";
		if(TEST_LOCALE) {
			if(!struct_has(LOCALE.word, key) && !struct_has(LOCALE.ui, key)) {
				show_debug_message($"LOCALE: \"{key}\": \"{def}\",");
				return def;
			}
			return "";
		}
		
		if(LOCALE_USE_DEFAULT) return def;
		
		if(struct_has(LOCALE.word, key)) return LOCALE.word[$ key];
		if(struct_has(LOCALE.ui, key))   return LOCALE.ui[$ key];
		
		return def;
	}
	
	function __txt(txt, prefix = "") {
		INLINE
		
		if(txt == "") return "";
		var key = string_lower(txt);
		    key = string_replace_all(key, " ", "_");
			
		if(TEST_LOCALE) {
			if(!struct_has(LOCALE.word, key) && !struct_has(LOCALE.ui, key)) {
				show_debug_message($"LOCALE: \"{key}\": \"{txt}\",");
				return txt;
			}	
			return "";
		}
		if(LOCALE_USE_DEFAULT) return txt;	
		return __txtx(prefix + key, txt);
	}
	
	function __txta(txt) {
		var _txt = __txt(txt);
		for(var i = 1; i < argument_count; i++)
			_txt = string_replace_all(_txt, "{" + string(i) + "}", string(argument[i]));
		
		return _txt;
	}
	
	function __txt_node_name(node, def = "") {
		INLINE
		
		if(LOCALE_USE_DEFAULT) return def;
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
			
		if(TEST_LOCALE) return "";
		return def;
	}
	
	function __txt_node_tooltip(node, def = "") {
		INLINE
		
		if(LOCALE_USE_DEFAULT) return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
			
		if(TEST_LOCALE) return "";
		return LOCALE.node[$ node].tooltip;
	}
	
	function __txt_junction_name(node, type, index, def = "") {
		INLINE
		
		if(LOCALE_USE_DEFAULT) return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		if(TEST_LOCALE) return "";
		return lst[index].name;
	}
	
	function __txt_junction_tooltip(node, type, index, def = "") {
		INLINE
		
		if(LOCALE_USE_DEFAULT) return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		if(TEST_LOCALE) return "";
		return lst[index].tooltip;
	}
	
	function __txt_junction_data(node, type, index, def = []) {
		INLINE
		
		return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		if(!struct_has(lst[index], "display_data"))
			return def;
			
		if(TEST_LOCALE) return [ "" ];
		return lst[index].display_data;
	}
#endregion