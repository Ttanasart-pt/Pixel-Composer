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

	////- Winwin
	
function winwin_start(window, clear = undefined) {
	if(!is_winwin(window)) return;
	
	winwin_draw_begin(window); 
	winwin_draw_clear(c_black, 0);
	WINWIN_CURRENT = window;
}


function winwin_end() {
	checkTOOLTIP();
	if(is_winwin(WINWIN_CURRENT))
		winwin_draw_end();
	WINWIN_CURRENT = undefined;
}