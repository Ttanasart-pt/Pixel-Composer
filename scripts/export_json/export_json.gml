function exportJSON(project = PROJECT) {
	if(DEMO) return false;
	
	var path = get_save_filename_compat("JSON (.json)|*.json", ""); 
	key_release();
	if(path == "") return false;
	
	var _map = project.serialize();
	var _str = json_stringify(_map, true);
	file_text_write_all(path, _str);
	
	return true;
}