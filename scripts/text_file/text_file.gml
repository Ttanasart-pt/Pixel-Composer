function file_read_all(path) { #region
	INLINE
	
	var f = file_text_open_read(path);
	if(!f) return "";
	
	var s = "";
	while(!file_text_eof(f))
		s += string(file_text_readln(f));
	file_text_close(f);
	return s;
} #endregion

function file_text_read_all_lines(path) { #region
	INLINE
	
	var f = file_text_open_read(path);
	if(!f) return "";
	
	var s = [];
	while(!file_text_eof(f))
		array_push(s, file_text_readln(f));
	file_text_close(f);
	return s;
} #endregion

function file_text_write_all(path, str) { #region
	INLINE
	
	if(file_exists_empty(path)) file_delete(path);
	
	var f = file_text_open_write(path);
	if(!f) return "";
	
	file_text_write_string(f, str);
	file_text_close(f);
} #endregion