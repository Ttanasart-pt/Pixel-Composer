#region data
	globalvar LOCALE; LOCALE       = { fontDir: "", config: { per_character_line_break: false } }
	globalvar TEST_LOCALE; TEST_LOCALE  = false;
	globalvar LOCALE_DEF; LOCALE_DEF   = true;
	
	globalvar LOCALE_NOTE_DATA; LOCALE_NOTE_DATA = {};
	globalvar LOCALE_NOTE_JUNC; LOCALE_NOTE_JUNC = {};
	
	global.missing_locale     = {}
	global.missing_lfile      = "";
	
	globalvar LOCALE_CACHE; LOCALE_CACHE = {};
	globalvar __txt; __txt        = undefined;
	
	function useDefaultLocale(_def) {
		LOCALE_DEF = _def;
		__txt = method(undefined, _def? __txtDef : __txtLoc);
		if(TEST_LOCALE) __txt = method(undefined, __txtTest);
	}
#endregion

function __locale_file(file) {
	var dirr = $"{DIRECTORY}Locale/{PREFERENCES.local}";
	if(!directory_exists(dirr) || !file_exists_empty(dirr + file)) 
		dirr = $"{DIRECTORY}Locale/en";
	
	return filename_combine(dirr, file);
}

function __initLocale() {
	var root  = $"{DIRECTORY}Locale";
	global.missing_lfile = $"{root}/missing.json";
	
	directory_verify(root);
	if(check_version($"{root}/version"))
		zip_unzip($"{working_directory}pack/locale.zip", root);
	
	if(!LOCALE_DEF || TEST_LOCALE) loadLocale();
	loadLocaleNotes();
}

function loadLocaleNotes() {
	LOCALE_NOTE_DATA = {};
	
	LOCALE_NOTE_JUNC = json_load_struct(__locale_file("/junctions.json"));
	var _noteD = $"{DIRECTORY}Locale/{PREFERENCES.local}/notes"
	if(!directory_exists(_noteD)) _noteD = $"{DIRECTORY}Locale/en/notes";
	
	var _notes = directory_get_files_ext(_noteD, [".md"]);
	for( var i = 0, n = array_length(_notes); i < n; i++ ) {
		var _n = _notes[i];
		var _p = $"{_noteD}/{_n}";
		
		LOCALE_NOTE_DATA[$ _n] = file_read_all(_p);
	}
}

function loadLocale() {
	var _word     = json_load_struct(__locale_file("/words.json"));
	var _ui       = json_load_struct(__locale_file("/UI.json"));
	LOCALE.texts  = struct_append(_word, _ui);
	print(__locale_file("/words.json"), json_stringify(_word, true));
	
	LOCALE.node   = json_load_struct(__locale_file("/nodes.json"));
	LOCALE.config = json_load_struct(__locale_file("/config.json"));
	
	var fontDir = $"{DIRECTORY}Locale/{PREFERENCES.local}/fonts/";
	LOCALE.fontDir = directory_exists(fontDir)? fontDir : noone;
	
}

function __txtLoc(  txt, def = txt ) { return LOCALE.texts[$ string_replace_all(string_lower(txt), " ", "_")] ?? def; }
function __txtDef(  txt, def = txt ) { return def; }
function __txtTest( txt, def = txt ) {
	var key = string_replace_all(string_lower(txt), " ", "_");
	if(key != "" && !has(LOCALE.texts, key) && !has(global.missing_locale, key)) {
		global.missing_locale[$ key] = def;
		file_text_write_all(global.missing_lfile, json_stringify(global.missing_locale));
	}
	
	return def;
}

function __txts(keys) { array_map_ext(keys, function(k,i) /*=>*/ {return __txt(k)}); return keys; } 
function __txta(txt) {
	var _txt = __txt(txt);
	for(var i = 1; i < argument_count; i++)
		_txt = string_replace_all(_txt, "{" + string(i) + "}", string(argument[i]));
	return _txt;
}

function __txt_node_name(node, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE && node != "Node_Custom" && node != "Node_Custom_Shader" && !has(LOCALE.node, node)) {
		show_debug_message($"LOCALE_[NODE]| \"{node}\": \"{def}\",");
		return def;
	}
	
	if(!has(LOCALE.node, node)) return def;
	return LOCALE.node[$ node][$ name] ?? def;
}

function __txt_node_tooltip(node, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
		
	if(TEST_LOCALE && node != "Node_Custom" && node != "Node_Custom_Shader" && !has(LOCALE.node, node)) {
		show_debug_message($"LOCALE_[TIP]| \"{node}\": \"{def}\",");
		return def;
	}
	
	if(!has(LOCALE.node, node)) return def;
	return LOCALE.node[$ node][$ "tooltip"] ?? def;
}

function __txt_junction_name(node, type, index, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE && !has(LOCALE.node, node)) {
		show_debug_message($"LOCALE_[JNAME]| \"{node}\": \"{def}\",");
		return def;
	}
	
	if(!has(LOCALE.node, node)) return def;
	
	var nde = LOCALE.node[$ node];
	var lst = type == CONNECT_TYPE.input? nde.inputs : nde.outputs;
	if(index >= array_length(lst)) return def;
	
	return lst[index][$ "name"] ?? def;
}

function __txt_junction_tooltip(node, type, index, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE && !has(LOCALE.node, node)) {
		show_debug_message($"LOCALE_[JTIP]| \"{node}\": \"{def}\",");
		return def;
	}
	
	if(!has(LOCALE.node, node)) return def;
	
	var nde = LOCALE.node[$ node];
	var lst = type == CONNECT_TYPE.input? nde.inputs : nde.outputs;
	if(index >= array_length(lst)) return def;
	
	return lst[index][$ "tooltip"] ?? def
}

function __txt_junction_data(node, type, index, def = []) {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE && !has(LOCALE.node, node)) {
		show_debug_message($"LOCALE_[DDATA]| \"{node}\": \"{def}\",");
		return def;
	}
	
	if(!has(LOCALE.node, node)) 
		return def;
		
	var nde = LOCALE.node[$ node];
	var lst = type == CONNECT_TYPE.input? nde.inputs : nde.outputs;
	if(index >= array_length(lst)) return def;
	
	return lst[index][$ "display_data"] ?? def;
}

useDefaultLocale(true);