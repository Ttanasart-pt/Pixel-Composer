function directory_verify(path) {
	if(directory_exists(path)) return;
	directory_create(path);
}