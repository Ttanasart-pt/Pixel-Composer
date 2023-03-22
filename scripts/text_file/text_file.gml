function file_text_read_all(path) {
	var f = file_text_open_read(path);
	var s = "";
	while(!file_text_eof(f))	
		s += string(file_text_readln(f));
	file_text_close(f);
	return s;
}

function file_text_read_all_lines(path) {
	var f = file_text_open_read(path);
	var s = [];
	while(!file_text_eof(f))
		array_push(s, file_text_readln(f));
	file_text_close(f);
	return s;
}

function file_text_write_all(path, str) {
	var f = file_text_open_write(path);
	file_text_write_string(f, str);
	file_text_close(f);
}