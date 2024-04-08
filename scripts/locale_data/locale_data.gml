#region locale
	globalvar LOCALE, TEST_LOCALE, LOCALE_DEF;
	LOCALE      = {
		fontDir: "",
		config: { per_character_line_break: false },
	};
	global.missing_locale = {}
	
	TEST_LOCALE = false;
	LOCALE_DEF  =  true;
	
	function __initLocale() { #region
		var lfile = $"data/Locale/en.zip";
		var root  = $"{DIRECTORY}Locale";
		
		directory_verify(root);
		if(check_version($"{root}/version")) {
			zip_unzip(lfile, root);
			file_copy($"data/Locale/LOCALIZATION GUIDES.txt", $"{DIRECTORY}Locale/LOCALIZATION GUIDES.txt");
		}
		
		if(LOCALE_DEF && !TEST_LOCALE) return;
		
		loadLocale();
	} #endregion
	
	function __locale_file(file) { #region
		var dirr = $"{DIRECTORY}Locale/{PREFERENCES.local}";
		if(!directory_exists(dirr) || !file_exists_empty(dirr + file)) 
			dirr = $"{DIRECTORY}Locale/en";
		return dirr + file;
	} #endregion
	
	function loadLocale() { #region
		LOCALE.word   = json_load_struct(__locale_file("/words.json"));
		LOCALE.ui     = json_load_struct(__locale_file("/UI.json"));
		LOCALE.node   = json_load_struct(__locale_file("/nodes.json"));
		LOCALE.config = json_load_struct(__locale_file("/config.json"));
		
		var fontDir = $"{DIRECTORY}Locale/{PREFERENCES.local}/fonts/";
		LOCALE.fontDir = directory_exists(fontDir)? fontDir : noone;
	} #endregion
	
	function __txtx(key, def = "") { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return def;
		
		if(TEST_LOCALE) {
			if(key != "" && !struct_has(LOCALE.word, key) && !struct_has(LOCALE.ui, key)) {
				global.missing_locale[$ key] = def;
				show_debug_message($"LOCALE: {global.missing_locale}");
				return def;
			}
			return "";
		}
		
		if(struct_has(LOCALE.word, key)) return LOCALE.word[$ key];
		if(struct_has(LOCALE.ui, key))   return LOCALE.ui[$ key];
		
		return def;
	} #endregion
	
	function __txt(txt, prefix = "") { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return txt;
		
		var key = string_lower(txt);
		    key = string_replace_all(key, " ", "_");
			
		if(TEST_LOCALE) {
			if(key != "" && !struct_has(LOCALE.word, key) && !struct_has(LOCALE.ui, key)) {
				global.missing_locale[$ key] = txt;
				show_debug_message($"LOCALE: {global.missing_locale}");
				return txt;
			}	
			return "";
		}
		
		return __txtx(prefix + key, txt);
	} #endregion
	
	function __txta(txt) { #region
		var _txt = __txt(txt);
		for(var i = 1; i < argument_count; i++)
			_txt = string_replace_all(_txt, $"\{{i}\}", string(argument[i]));
		
		return _txt;
	} #endregion
	
	function __txt_node_name(node, def = "") { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return def;
		
		if(TEST_LOCALE) {
			if(node != "Node_Custom" && !struct_has(LOCALE.node, node)) {
				show_debug_message($"LOCALE [NODE]: \"{node}\": \"{def}\",");
				return def;
			}
			return "";
		}
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
		
		return LOCALE.node[$ node].name;
	} #endregion
	
	function __txt_node_tooltip(node, def = "") { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return def;
			
		if(TEST_LOCALE) {
			if(node != "Node_Custom" && !struct_has(LOCALE.node, node)) {
				show_debug_message($"LOCALE [TIP]: \"{node}\": \"{def}\",");
				return def;
			}
			return "";
		}
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
		
		return LOCALE.node[$ node].tooltip;
	} #endregion
	
	function __txt_junction_name(node, type, index, def = "") { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return def;
		
		if(TEST_LOCALE) {
			if(!struct_has(LOCALE.node, node)) {
				show_debug_message($"LOCALE [JNAME]: \"{node}\": \"{def}\",");
				return def;
			}
			return "";
		}
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		return lst[index].name;
	} #endregion
	
	function __txt_junction_tooltip(node, type, index, def = "") { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return def;
		
		if(TEST_LOCALE) {
			if(!struct_has(LOCALE.node, node)) {
				show_debug_message($"LOCALE [JTIP]: \"{node}\": \"{def}\",");
				return def;
			}
			return "";
		}
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
		
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		return lst[index].tooltip;
	} #endregion
	
	function __txt_junction_data(node, type, index, def = []) { #region
		INLINE
		
		if(LOCALE_DEF && !TEST_LOCALE) return def;
		
		if(TEST_LOCALE) {
			if(!struct_has(LOCALE.node, node)) {
				show_debug_message($"LOCALE [DDATA]: \"{node}\": \"{def}\",");
				return def;
			}
			return [ "" ];
		}
		
		if(!struct_has(LOCALE.node, node)) 
			return def;
			
		var nde = LOCALE.node[$ node];
		var lst = type == JUNCTION_CONNECT.input? nde.inputs : nde.outputs;
		if(index >= array_length(lst)) return def;
		
		if(!struct_has(lst[index], "display_data"))
			return def;
		
		return lst[index].display_data;
	} #endregion
#endregion