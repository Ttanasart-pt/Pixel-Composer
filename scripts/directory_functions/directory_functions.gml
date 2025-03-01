function directory_verify(path) {
	if(directory_exists(path)) return;
	directory_create(path);
}

function directory_clear(path) {
	if(!directory_exists(path)) return;
	directory_destroy(path);
	directory_create(path);
}

function directory_size_mb(dir) {
	if(!directory_exists(dir)) return 0;
	return directory_size(dir) / (1024*1024);
}