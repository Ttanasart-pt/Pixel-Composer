function check_version(path, key = "version") {
	if(!file_exists_empty(path)) {
		var str = {}; 
		str[$ key] = BUILD_NUMBER;
		json_save_struct(path, str);
		return true;
	}
	
	if(TESTING) return true;
	
	var res = json_load_struct(path);
	var chk = res[$ key] ?? 0;
	res[$ key] = BUILD_NUMBER;
	json_save_struct(path, res);
	
	return chk != BUILD_NUMBER;
}