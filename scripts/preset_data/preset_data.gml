global.PRESETS_MAP = ds_map_create();

function __initPresets() {
	ds_map_clear(global.PRESETS_MAP);
	
	var _preset_path = "data/Preset.zip";
	var root = DIRECTORY + "Presets";
	directory_verify(root);
	if(check_version($"{root}/version") && file_exists_empty(_preset_path))
		zip_unzip(_preset_path, root);

	global.PRESETS = new DirectoryObject("Presets", root);
	global.PRESETS.scan([".json"]);
	
	for( var i = 0; i < ds_list_size(global.PRESETS.subDir); i++ ) {
		var l   = [];
		var grp = global.PRESETS.subDir[| i];
		global.PRESETS_MAP[? grp.name] = l;
		
		for( var j = 0; j < ds_list_size(grp.content); j++ ) {
			var pth = grp.content[| j].path;
			var f   = new FileObject(grp.content[| j].name, pth);
			array_push(l, f);
		}
	}
}

function loadPreset(preset) {
	INLINE
	if(preset.content == -1) {
		preset.content        = json_load_struct(preset.path);
		preset.thumbnail_data = struct_try_get(preset.content, "thumbnail", -1);
	}
	
	return preset.content;
}