function Program_Close() {
	PREF_SAVE();
	game_end();
}

function Program_Restart() {
	var _exePath = program_directory;
	shell_execute("", $"start \"\" /D \"{_exePath}\" \"PixelComposer.exe\"");
	Program_Close();
}

function window_close() {
	CALL("exit");
	
	var noSave = true;
	
	for( var i = 0, n = array_length(PROJECTS); i < n; i++ ) {
		var project = PROJECTS[i];
		
		if(project.modified && !project.readonly) {
			var dia = dialogCall(o_dialog_exit,,,, true);
			dia.project = project;
			
			noSave = false;
		}
	}
	
	if(noSave) Program_Close();
}
