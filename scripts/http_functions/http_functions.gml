global.HTTP_FILE_CACHE = {};

function http_get_sprite(_path) {
	var _pathSplit = string_split(_path, "/");
	var _pathName  = array_last(_pathSplit);
	
	if(has(global.HTTP_FILE_CACHE, _path))
		return global.HTTP_FILE_CACHE[$ _path];
		
	var _cachePath = $"{DIRECTORY}Cache/{_pathName}";
	
	if(file_exists_empty(_cachePath)) {
		global.HTTP_FILE_CACHE[$ _path] = sprite_add(_cachePath, 0, false, false, 0, 0);
		return global.HTTP_FILE_CACHE[$ _path];
	}
	
	global.HTTP_FILE_CACHE[$ _path] = -1; // loading
	
	asyncCall(http_get_file(_path, _cachePath), function(_param, _res) /*=>*/ {
		var _stat = _res[? "status"];
    	if(_stat < 0) { print("Fetch Artwork failed"); return 0; }
    	if(_stat != 0) return;
    	
		var _path    = _param.url;
		var _resPath = _res[? "result"];
		
		if(file_exists_empty(_resPath))
			global.HTTP_FILE_CACHE[$ _path] = sprite_add(_resPath, 0, false, false, 0, 0);
	}, {  
		url: _path
	});
	
	return global.HTTP_FILE_CACHE[$ _path];
}