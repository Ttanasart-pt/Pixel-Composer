#region loading
	global.PRESETS_MAP = ds_map_create();
	
	function __initPresets() {
		ds_map_clear(global.PRESETS_MAP);
		
		var root = DIRECTORY + "Presets";
		if(!directory_exists(root))
			directory_create(root);
		
		var _l = root + "\\version";
		if(file_exists(_l)) {
			var res = json_load_struct(_l);
			if(res.version < VERSION) 
				zip_unzip("data/Preset.zip", root);
		} else 
			zip_unzip("data/Preset.zip", root);
		json_save_struct(_l, { version: VERSION });
	
		global.PRESETS = new DirectoryObject("Presets", root);
		global.PRESETS.scan([".json"]);
		
		for( var i = 0; i < ds_list_size(global.PRESETS.subDir); i++ ) {
			var l = [];
			var grp = global.PRESETS.subDir[| i];
			for( var j = 0; j < ds_list_size(grp.content); j++ ) {
				var pth = grp.content[| j].path;
				var f = new FileObject(grp.content[| j].name, pth);
				f.content = json_load(pth); 
				array_push(l, f);
			}
			global.PRESETS_MAP[? grp.name] = l;
		}
	}
#endregion