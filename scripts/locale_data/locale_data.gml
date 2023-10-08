#region locale
	globalvar LOCALE, TEST_LOCALE;
	LOCALE = {}
	TEST_LOCALE = false;
	
	function __initLocale() {
		var lfile = $"data/locale/en.zip";
		var root  = $"{DIRECTORY}Locale";
		
		if(!directory_exists(root))
			directory_create(root);
		zip_unzip(lfile, root);
		
		loadLocale();
	}
	
	function __locale_file(file) {
		var dirr = $"{DIRECTORY}Locale/{PREF_MAP[? "local"]}";
		if(!directory_exists(dirr) || !file_exists(dirr + file)) 
			dirr = $"{DIRECTORY}Locale/en";
		return dirr + file;
	}
	
	function loadLocale() {
		LOCALE.word = json_load_struct(__locale_file("/words.json"));
		LOCALE.ui   = json_load_struct(__locale_file("/UI.json"));
		LOCALE.node = json_load_struct(__locale_file("/nodes.json"));
		LOCALE.config = json_load_struct(__locale_file("/config.json"));
		
		var fontDir = $"{DIRECTORY}Locale/{PREF_MAP[? "local"]}/fonts/";
		LOCALE.fontDir = directory_exists(fontDir)? fontDir : noone;
		
		print("FONT DIR: " + fontDir);
	}
	
	function __txtx(key, def = "") {
		gml_pragma("forceinline");
		
		if(TEST_LOCALE) {
			if(!struct_has(LOCALE.word, key) && !struct_has(LOCALE.ui, key)) {
				show_debug_message($"LOCALE: \"{key}\": \"{def}\",");
				//return def;
			}
			
			return "";
		}
		
		if(struct_has(LOCALE.word, key))
			return LOCALE.word[$ key];
		if(struct_has(LOCALE.ui, key)) 
			return LOCALE.ui[$ key];
		
		return def;
	}
	
	function __txt(txt, prefix = "") {
		gml_pragma("forceinline");
		
		var key = string_lower(txt);
		    key = string_replace_all(key, " ", "_");
			
		return __txtx(prefix + key, txt);
	}
	
	function __txta(txt) {
		var _txt = __txt(txt);
		for(var i = 1; i < argument_count; i++)
			_txt = string_replace_all(_txt, "{" + string(i) + "}", string(argument[i]));
		
		return _txt;
	}
	
	function __txt_node_name(node, def = "") {
		gml_pragma("forceinline");
		
		//if(TESTING) return def;
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
			
		if(TEST_LOCALE) return "";
		return def;
	}
	
	function __txt_node_tooltip(node, def = "") {
		gml_pragma("forceinline");
		
		//if(TESTING) return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
			
		if(TEST_LOCALE) return "";
		return LOCALE.node[$ node].tooltip;
	}
	
	function __txt_junction_name(node, type, index, def = "") {
		gml_pragma("forceinline");
		
		//if(TESTING) return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		if(TEST_LOCALE) return "";
		return lst[index].name;
	}
	
	function __txt_junction_tooltip(node, type, index, def = "") {
		gml_pragma("forceinline");
		
		//if(TESTING) return def;
		
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		if(TEST_LOCALE) return "";
		return lst[index].tooltip;
	}
	
	function __txt_junction_data(node, type, index, def = []) {
		gml_pragma("forceinline");
		
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