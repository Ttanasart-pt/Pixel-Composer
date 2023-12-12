/// @description 
#region process management
	global.PROC_ID = int64(environment_get_variable_exists("process_id")? environment_get_variable("process_id") : 0);
	environment_set_variable("process_id", string(global.PROC_ID + 1));
	
	     if (global.PROC_ID == 0) instance_create(0, 0, o_main);
	else if (global.PROC_ID == 1) instance_create(0, 0, o_crash_handler);
#endregion