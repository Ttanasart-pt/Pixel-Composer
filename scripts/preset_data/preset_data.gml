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
}