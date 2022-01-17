function read_ase(path) {
	var file = file_bin_open(path, 0);
	var load_str = "";
	
	bin_read_dword(file);
	bin_read_word(file);
	var frames = bin_read_word(file);
	var width  = bin_read_word(file);
	var height = bin_read_word(file);
	
	var pos = 128;
	file_bin_seek(file, pos);
	
	repeat(frames) {
		bin_read_dword(file);
		bin_read_word(file);
		
		var old_chunk = bin_read_word(file);
		
		bin_read_word(file);
		bin_read_word(file);
		bin_read_word(file);
		
		var new_chunk = bin_read_dword(file);
		
		var chunks = new_chunk == 0? old_chunk : new_chunk;
		
		
	}
	
	file_bin_close(file);
}