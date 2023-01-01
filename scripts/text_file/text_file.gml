function file_text_read_all(file) {
	var s = "";
	while(!file_text_eof(file))	
		s += file_text_readln(file);
	return s;
}

function file_text_write_all(file, str) {
	var f = file_text_open_write(file);
	file_text_write_string(f, str);
	file_text_close(f);
}