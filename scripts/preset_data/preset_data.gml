global.PRESETS_MAP      = ds_map_create();
global.PRESETS_MAP_NODE = ds_map_create();

function __initPresets() {
	ds_map_clear(global.PRESETS_MAP);
	ds_map_clear(global.PRESETS_MAP_NODE);
	
	var _preset_path = $"{working_directory}data/Preset.zip";
	var root = DIRECTORY + "Presets";
	
	directory_verify(root);
	if(check_version($"{root}/version") && file_exists_empty(_preset_path))
		zip_unzip(_preset_path, root);
	
	global.PRESETS = new DirectoryObject(root);
	global.PRESETS.scan([".json"]);
	
	for( var i = 0; i < array_length(global.PRESETS.subDir); i++ ) {
		var l   = [];
		var grp = global.PRESETS.subDir[i];
		global.PRESETS_MAP[? grp.name] = l;
		
		for( var j = 0; j < array_length(grp.content); j++ ) {
			var pth = grp.content[j].path;
			var f   = new FileObject(pth);
			array_push(l, f);
			
			var _fName = $"{grp.name}>{f.name}";
			global.PRESETS_MAP_NODE[? _fName] = f;
		}
	}
}