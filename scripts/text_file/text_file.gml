function file_read_all(path) {
	INLINE
	
	var f = file_text_open_read(path);
	var s = "";
	while(!file_text_eof(f))
		s += file_text_readln(f);
	file_text_close(f);
	return s;
}

function file_text_read_all_lines(path) {
	INLINE
	
	var f = file_text_open_read(path);
	var s = [];
	while(!file_text_eof(f))
		array_push(s, file_text_readln(f));
	file_text_close(f);
	return s;
}

function file_text_write_all(path, str) {
	INLINE
	
	if(file_exists_empty(path)) file_delete(path);
	
	var f = file_text_open_write(path);
	file_text_write_string(f, str);
	file_text_close(f);
}