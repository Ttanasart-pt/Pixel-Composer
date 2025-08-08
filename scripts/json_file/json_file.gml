function json_encode_minify(map) {
	gml_pragma("forceinline");
	
	return json_minify(json_encode(map));
}

function json_stringify_minify(map) {
	gml_pragma("forceinline");
	
	return json_minify(json_stringify(map));
}

function json_load(path) {
	gml_pragma("forceinline");
	
	if(!file_exists_empty(path)) return noone;
	
	var s = file_read_all(path);
	var js = json_decode(s);
	return js;
}

function json_save(path, map) {
	gml_pragma("forceinline");
	
	var s = json_encode_minify(map);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, s);
	file_text_close(f);
}

function json_load_struct(path, def = {}) {
	gml_pragma("forceinline");
	
	if(!file_exists_empty(path)) return noone;
	
	var s  = file_read_all(path);
	var js = json_try_parse(s, def);
	return js;
}

function json_save_struct(path, struct, pretty = false) {
	gml_pragma("forceinline");
	
	var s;
	if(pretty) s = json_stringify(struct, true);
	else       s = json_stringify_minify(struct);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, s);
	file_text_close(f);
	
	// show_debug_message($"Save struct at {path}");
}