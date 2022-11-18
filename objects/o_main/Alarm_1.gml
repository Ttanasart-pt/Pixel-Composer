/// @description init
#region prefload
	//RECENT_LOAD();
	
	//LOAD_SAMPLE();
	//INIT_FOLDERS();
	
	if(!file_exists(file_open_parameter) && PREF_MAP[? "show_splash"]) {
		var dia = dialogCall(o_dialog_warning);
		dia.warning_text = 
@"Vanila build

This build is a strip down version of Pixel Composer 
for stability check only. Some feature may be unstable, non-funtional.";
	}
#endregion