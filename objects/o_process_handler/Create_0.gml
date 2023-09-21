/// @description 
#region process management
	global.PROC_ID = bool(EnvironmentGetVariableExists("process_id"))? int64(EnvironmentGetVariable("process_id")) : 0;
	EnvironmentSetVariable("process_id", string(global.PROC_ID + 1));
	
	if (global.PROC_ID == 0)
		instance_create(0, 0, o_main);
	else if (global.PROC_ID == 1)
		instance_create(0, 0, o_crash_handler);
#endregion