#region locale
	globalvar LOCALE;
	LOCALE = {}
	
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
		
		var fontDir = $"{DIRECTORY}Locale/{PREF_MAP[? "local"]}/fonts/";
		LOCALE.fontDir = directory_exists(fontDir)? fontDir : noone;
		
		print("FONT DIR: " + fontDir);
	}
	
	function __txtx(key, def = "") {
		if(struct_has(LOCALE.word, key))
			return LOCALE.word[$ key]
		if(struct_has(LOCALE.ui, key)) 
			return LOCALE.ui[$ key]
		
		print($"LOCAL \"{key}\": \"{def}\",");
		return def;
	}
	
	function __txt(txt, prefix = "") {
		var key = string_lower(txt);
		    key = string_replace_all(key, " ", "_");
			
		return __txtx(prefix + key, txt);
	}
	
	function __txt_node_name(node) {
		if(struct_has(LOCALE.node, node))
			return LOCALE.node[$ node].name;
		return node;
	}
	
	function __txt_node_tooltip(node, def = "") {
		if(struct_has(LOCALE.node, node))
			return LOCALE.node[$ node].tooltip;
		return def;
	}
	
	function __txt_junction_name(node, type, index, def = "") {
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		return lst[index].name;
	}
	
	function __txt_junction_tooltip(node, type, index, def = "") {
		if(!struct_has(LOCALE.node, node))
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		return lst[index].tooltip;
	}
	
#endregion