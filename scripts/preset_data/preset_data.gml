#region node preset
	globalvar PRESETS_MAP; PRESETS_MAP = {};
	
	function __initPresets() {
		PRESETS_MAP = {};
		
		var path = $"{working_directory}data/Preset.zip";
		var root = DIRECTORY + "Presets";
		
		directory_verify(root);
		if(check_version($"{root}/version") && file_exists_empty(path))
			zip_unzip(path, root);
		
		global.PRESETS = new DirectoryObject(root);
		global.PRESETS.scan([".json"]);
		
		for( var i = 0, n = array_length(global.PRESETS.subDir); i < n; i++ ) {
			var grp = global.PRESETS.subDir[i];
			var pre = {};
			PRESETS_MAP[$ grp.name] = pre;
			
			for( var j = 0, m = array_length(grp.content); j < m; j++ ) {
				var pth = grp.content[j].path;
				var fil = new FileObject(pth);
				pre[$ fil.name] = fil;
			}
		}
	
		__initPalette();
		__initGradient();
		__initCurve();
	}
#endregion

#region palette
	globalvar PALETTE_LOSPEC; PALETTE_LOSPEC = 0;
	
	globalvar PALETTES_FOLDER;
	globalvar PALETTES_FAV, PALETTES_FAV_DIR;
	
	function __initPalette() {
		var root = DIRECTORY + "Palettes/";
		directory_verify(root);
		
		PALETTES_FOLDER = new DirectoryObject(root).scan([".hex", ".gpl", ".pal", ".png"]);
		__refreshPaletteFav();
	}
	
	function __refreshPaletteFav() {
		var root  = DIRECTORY + "Palettes/";
		var fpath = root + "fav.json";
		var _fav  = json_load_struct(fpath, []);
		
		PALETTES_FAV_DIR = new DirectoryObject("Favorites");
		PALETTES_FAV     = [];
		
		for( var i = 0, n = array_length(_fav); i < n; i++ ) {
			var f = _fav[i];
			var p = root + f;
			if(!has(FILEMAP, p)) continue;
			
			var _file = FILEMAP[$ p];
			_file.fav = true;
			
			array_push(PALETTES_FAV_DIR.content, _file);
		}
		
		array_insert(PALETTES_FOLDER.subDir, 0, PALETTES_FAV_DIR);
	}
	
	function __togglePaletteFav(_file) {
		var root  = DIRECTORY + "Palettes/";
		var fpath = root + "fav.json";
		var path  = string_replace(_file.path, root, "");
		
		_file.fav = !_file.fav;
		
		if(_file.fav) {
			array_push(PALETTES_FAV, path);
			array_push(PALETTES_FAV_DIR.content, _file);
			
		} else {
			array_remove(PALETTES_FAV, path);
			array_remove(PALETTES_FAV_DIR.content, _file);
		}
		
		json_save_struct(fpath, PALETTES_FAV);
	} 
#endregion

#region gradient
	globalvar GRADIENTS_FOLDER;
	globalvar GRADIENTS_FAV, GRADIENTS_FAV_DIR;
	
	function __initGradient() {
		var root = DIRECTORY + "Gradients/"
		directory_verify(root);
		
		GRADIENTS_FOLDER = new DirectoryObject(root).scan([".txt"]);
		__refreshGradientFav();
	}
	
	function __refreshGradientFav() {
		var root  = DIRECTORY + "Gradients/";
		var fpath = root + "fav.json";
		var _fav  = json_load_struct(fpath, []);
		
		GRADIENTS_FAV_DIR = new DirectoryObject("Favorites");
		GRADIENTS_FAV     = [];
		
		for( var i = 0, n = array_length(_fav); i < n; i++ ) {
			var f = _fav[i];
			var p = root + f;
			if(!has(FILEMAP, p)) continue;
			
			var _file = FILEMAP[$ p];
			_file.fav = true;
			
			array_push(GRADIENTS_FAV_DIR.content, _file);
		}
		
		array_insert(GRADIENTS_FOLDER.subDir, 0, GRADIENTS_FAV_DIR);
	}
	
	function __toggleGradientFav(_file) {
		var root  = DIRECTORY + "Gradients/";
		var fpath = root + "fav.json";
		var path  = string_replace(_file.path, root, "");
		
		_file.fav = !_file.fav;
		
		if(_file.fav) {
			array_push(GRADIENTS_FAV, path);
			array_push(GRADIENTS_FAV_DIR.content, _file);
			
		} else {
			array_remove(GRADIENTS_FAV, path);
			array_remove(GRADIENTS_FAV_DIR.content, _file);
		}
		
		json_save_struct(fpath, GRADIENTS_FAV);
	} 
#endregion

#region curves
	globalvar CURVES_FOLDER;
	globalvar CURVES_FAV, CURVES_FAV_DIR;
	
	function __initCurve() {
		var path = $"{working_directory}data/Curves.zip";
		var root = DIRECTORY + "Curves/"
		directory_verify(root);
		
		if(check_version($"{root}/version") && file_exists_empty(path))
			zip_unzip(path, root);
			
		CURVES_FOLDER = new DirectoryObject(root).scan([".json"]);
		__refreshCurveFav();
	}
	
	function __refreshCurveFav() {
		var root  = DIRECTORY + "Curves/";
		var fpath = root + "fav.json";
		var _fav  = json_load_struct(fpath, []);
		
		CURVES_FAV_DIR = new DirectoryObject("Favorites");
		CURVES_FAV     = [];
		
		for( var i = 0, n = array_length(_fav); i < n; i++ ) {
			var f = _fav[i];
			var p = root + f;
			if(!has(FILEMAP, p)) continue;
			
			var _file = FILEMAP[$ p];
			_file.fav = true;
			
			array_push(CURVES_FAV_DIR.content, _file);
		}
		
		array_insert(CURVES_FOLDER.subDir, 0, CURVES_FAV_DIR);
	}
	
	function __toggleCurveFav(_file) {
		var root  = DIRECTORY + "Curves/";
		var fpath = root + "fav.json";
		var path  = string_replace(_file.path, root, "");
		
		_file.fav = !_file.fav;
		
		if(_file.fav) {
			array_push(CURVES_FAV, path);
			array_push(CURVES_FAV_DIR.content, _file);
			
		} else {
			array_remove(CURVES_FAV, path);
			array_remove(CURVES_FAV_DIR.content, _file);
		}
		
		json_save_struct(fpath, CURVES_FAV);
	} 
#endregion