#region node preset
	globalvar PRESETS_MAP; PRESETS_MAP = {};
	
	function __initPresets() {
		PRESETS_MAP = {};
		
		var _preset_path = $"{working_directory}data/Preset.zip";
		var root = DIRECTORY + "Presets";
		
		directory_verify(root);
		if(check_version($"{root}/version") && file_exists_empty(_preset_path))
			zip_unzip(_preset_path, root);
		
		global.PRESETS = new DirectoryObject(root);
		global.PRESETS.scan([".json"]);
		
		for( var i = 0; i < array_length(global.PRESETS.subDir); i++ ) {
			var grp = global.PRESETS.subDir[i];
			var pre = {};
			PRESETS_MAP[$ grp.name] = pre;
			
			for( var j = 0; j < array_length(grp.content); j++ ) {
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
	globalvar PALETTES; PALETTES       = [];
	globalvar PALETTE_LOSPEC; PALETTE_LOSPEC = 0;
	globalvar PALETTES_FOLDER;
	
	function __initPalette() {
		PALETTES = [];
		
		var path = DIRECTORY + "Palettes/";
		PALETTES_FOLDER = new DirectoryObject(path).scan([".hex", ".gpl", ".pal", ".png"]);
		
		// var file = file_find_first(path + "*", 0);
		// while(file != "") {
			// if(isPaletteFile(file)) {
		// 		array_push(PALETTES, {
		// 			name:    filename_name_only(file),
		// 			path:    path + file,
		// 			palette: loadPalette(path + file)
		// 		});
		// 	}
		// 	file = file_find_next();
		// }
		// file_find_close();
	}
#endregion

#region gradient
	globalvar GRADIENTS_FOLDER;
	
	function __initGradient() {
		var path = DIRECTORY + "Gradients/"
		GRADIENTS_FOLDER = new DirectoryObject(path).scan([".txt"]);
	}
#endregion

#region curves
	globalvar CURVES; CURVES = [];
	
	function __initCurve() {
		
	}
#endregion