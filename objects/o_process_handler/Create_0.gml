/// @description 
#region process management
	global.PROC_ID = bool(EnvironmentGetVariableExists("process_id"))? int64(EnvironmentGetVariable("process_id")) : 0;
	EnvironmentSetVariable("process_id", string(global.PROC_ID + 1));
	
	if (global.PROC_ID == 1) { // if spawn after the main windows
		instance_destroy(o_main, false);
		instance_create(0, 0, o_crash_handler);
	}
#endregion