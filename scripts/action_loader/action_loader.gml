#region action
	global.ACTIONS = [];
	
	function __initAction() {
		global.ACTIONS = [];
		
		var root = DIRECTORY + "Actions";
		if(!directory_exists(root))
			directory_create(root);
		
		var _l = root + "/version";
		if(file_exists(_l)) {
			var res = json_load_struct(_l);
			if(!is_struct(res) || !struct_has(res, "version") || res.version != BUILD_NUMBER) 
				zip_unzip("data/Actions.zip", DIRECTORY);
		} else 
			zip_unzip("data/Actions.zip", DIRECTORY);
		json_save_struct(_l, { version: BUILD_NUMBER });
	}
#endregion