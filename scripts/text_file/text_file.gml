function file_read_all(path) {
	gml_pragma("forceinline");
	
	var f = file_text_open_read(path);
	var s = file_text_read_all(f);
	file_text_close(f);
	return s;
}

function file_text_read_all_lines(path) {
	gml_pragma("forceinline");
	
	var f = file_text_open_read(path);
	var s = [];
	while(!file_text_eof(f))
		array_push(s, file_text_readln(f));
	file_text_close(f);
	return s;
}

function file_text_write_all(path, str) {
	gml_pragma("forceinline");
	
	if(file_exists(path)) file_delete(path);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, str);
	file_text_close(f);
}