#region action
	global.ACTIONS = [];
	
	function __initAction() {
		global.ACTIONS = [];
		
		var root = DIRECTORY + "Actions";
		directory_verify(root);
		
		if(check_version($"{root}/version"))
			zip_unzip("data/Actions.zip", DIRECTORY);
	}
#endregion