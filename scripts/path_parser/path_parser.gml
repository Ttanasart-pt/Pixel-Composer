function __path_get(path) {
	INLINE
	
	if(file_exists_empty(path)) return path;
		
	var local_path = $"{filename_dir(PROJECT.path)}/{path}";
	if(file_exists_empty(local_path))
		return local_path;
	
	return -1;
}

function path_get(path) {
	INLINE
	
	if(!is_array(path)) return __path_get(path);
	
	var _res = array_create(array_length(path));
	for( var i = 0, n = array_length(path); i < n; i++ )
		_res[i] = __path_get(path[i]);
	
	return _res;
}