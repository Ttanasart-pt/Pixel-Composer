/// @description init
#region prefload
	__migration_check();
	
	if(!file_exists(file_open_parameter) && PREFERENCES.show_splash)
		dialogCall(o_dialog_splash);
#endregion