function file_copy_override(src, dest) {
	if(file_exists(dest)) file_delete(dest);
	file_copy(src, dest);
}