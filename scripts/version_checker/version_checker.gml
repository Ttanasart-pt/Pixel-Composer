function check_version(path) {
	if(!file_exists(path)) {
		json_save_struct(path, { version: BUILD_NUMBER });
		return true;
	}
	
	if(TESTING) return true;
	
	var res = json_load_struct(path);
	return struct_try_get(res, "version") != BUILD_NUMBER;
}