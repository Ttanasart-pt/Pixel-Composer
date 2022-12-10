function json_load(path) {
	if(!file_exists(path)) return {};
	
	var f = file_text_open_read(path);
	var s = file_text_read_all(f);
	file_text_close(f);
	
	var js = json_decode(s);
	return js;
}

function json_save(path, struct) {
	var s = json_encode(struct);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, s);
	file_text_close(f);
}