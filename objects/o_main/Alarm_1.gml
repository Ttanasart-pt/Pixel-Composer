/// @description init
#region prefload
	__migration_check();
	
	if(!file_exists_empty(PROGRAM_ARGUMENTS._path) && PREFERENCES.show_splash)
		dialogCall(o_dialog_splash);
#endregion