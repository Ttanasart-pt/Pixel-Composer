function __get_node_custom_directory(dir) {
	if(!directory_exists(dir)) return false;
	
	var _info = $"{dir}/info.json";
	if(file_exists(_info)) return true;
	
	var _res  = false;
	var _dirs = [];
	var _f = file_find_first(dir + "/*", fa_directory);
	var f, p;
	
	while(_f != "") {
		 f = _f;
		 p = dir + "/" + f;
		_f = file_find_next();
		
		if(!directory_exists(p)) continue;
		array_push(_dirs, p);
	}
	
	file_find_close();
	
	for( var i = 0, n = array_length(_dirs); i < n; i++ )
		_res = __get_node_custom_directory(_dirs[i]) || _res;
	return _res;
}


function files_drop_global(files) {
    
    for( var i = 0, n = array_length(files); i < n; i++ ) {
        var _file = files[i];
        
        if(__get_node_custom_directory(_file)) {
        	dialogPanelCall(new Panel_Node_Custom_Import(files));
        	return true;
        }
    }
    
    return false;
}