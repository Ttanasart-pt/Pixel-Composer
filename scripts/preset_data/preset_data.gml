#region loading
	global.PRESETS_MAP = ds_map_create();
	
	function __initPresets() {
		ds_map_clear(global.PRESETS_MAP);
		
		var root = DIRECTORY + "Presets";
		if(!directory_exists(root))
			directory_create(root);
		
		var _l = root + "/version";
		var _preset_path = "data/Preset.zip";
		if(file_exists(_preset_path)) {
			if(file_exists(_l)) {
				var res = json_load_struct(_l);
				if(!is_struct(res) || !struct_has(res, "version") || res.version != BUILD_NUMBER) 
					zip_unzip(_preset_path, root);
			} else 
				zip_unzip(_preset_path, root);
		}
		json_save_struct(_l, { version: BUILD_NUMBER });
	
		global.PRESETS = new DirectoryObject("Presets", root);
		global.PRESETS.scan([".json"]);
		
		for( var i = 0; i < ds_list_size(global.PRESETS.subDir); i++ ) {
			var l = [];
			var grp = global.PRESETS.subDir[| i];
			for( var j = 0; j < ds_list_size(grp.content); j++ ) {
				var pth = grp.content[| j].path;
				var f = new FileObject(grp.content[| j].name, pth);
				f.content = json_load_struct(pth); 
				array_push(l, f);
			}
			global.PRESETS_MAP[? grp.name] = l;
		}
	}
#endregion