function Program_Close() {
	PREF_SAVE();
	game_end();
}

function Program_Restart() {
	var _exePath = program_directory;
	var _exeFile = filename_combine(_exePath, "PixelComposer.exe");
	
	shell_execute("", $"start {_exeFile}");
	Program_Close();
}

function window_close() {
	CALL("exit");
	
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
	
	if(noSave) Program_Close();
}
