/// @description init
#region prefload
	__migration_check();
	
	if(!file_exists_empty(file_open_parameter) && PREFERENCES.show_splash)
		dialogCall(o_dialog_splash);
#endregion