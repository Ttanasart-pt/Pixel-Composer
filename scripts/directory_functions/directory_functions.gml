function directory_verify(path) {
	INLINE
	
	if(directory_exists(path)) return;
	directory_create(path);
}