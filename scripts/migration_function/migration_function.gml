function __migration_check() {
	var oldDir = environment_get_variable("userprofile") + "/AppData/Local/Pixels_Composer/";
	if(!directory_exists(oldDir)) return;
	
	var mig = oldDir + "migration";
	if(file_exists_empty(mig)) return;
	
	var f = file_text_open_write(mig);	
	file_text_close(f);
	
	dialogCall(o_dialog_migration);
}