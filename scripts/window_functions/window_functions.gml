function window_close() {
	var noSave = true;
	
	for( var i = 0, n = array_length(PROJECTS); i < n; i++ ) {
		var project = PROJECTS[i];
		
		//print($"Project {filename_name_only(project)} modified: {project.modified} readonly: {project.readonly}");
		if(project.modified && !project.readonly) {
			var dia = dialogCall(o_dialog_exit,,,, true);
			dia.project = project;
			
			noSave = false;
		}
	}
	
	if(noSave) {
		PREF_SAVE();
		game_end();
	}
}