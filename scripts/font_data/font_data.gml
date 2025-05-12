globalvar FONT_MAP;
FONT_MAP = {};

function __initFontFolder() {
	var root = DIRECTORY + "Fonts";
	directory_verify(root);
	
	FONT_MAP = {};
	
	var _files = directory_get_files_ext(root, ".ttf");
	for( var i = 0, n = array_length(_files); i < n; i++ ) {
		var _f = _files[i];
		
		var _fname = filename_name_only(_f);
		var _path  = root + "/" + _f;
		
		FONT_MAP[$ _fname] = _path;
	}
}