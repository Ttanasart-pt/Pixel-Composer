function json_encode_minify(map) {
	return json_minify(json_encode(map));
}

function json_stringify_minify(map) {
	return json_minify(json_stringify(map));
}

function json_load(path) {
	if(!file_exists(path)) return noone;
	
	var s = file_text_read_all(path);
	var js = json_decode(s);
	return js;
}

function json_save(path, map) {
	var s = json_encode_minify(map);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, s);
	file_text_close(f);
}

function json_load_struct(path) {
	if(!file_exists(path)) return noone;
	
	var s = file_text_read_all(path);
	var js = json_try_parse(s);
	return js;
}

function json_save_struct(path, struct, pretty = false) {
	var s;
	
	if(pretty)
		s = json_stringify(struct, true);
	else 
		s = json_stringify_minify(struct);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, s);
	file_text_close(f);
}