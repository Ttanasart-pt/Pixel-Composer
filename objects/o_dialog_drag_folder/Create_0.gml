/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	dialog_w = ui(290);
	dialog_h = ui(188);
	
	target			= noone;
	dir_paths		= "";
	dir_recursive	= false;
	dir_filter		= ".png";
	
	cb_recursive = new checkBox(function(val) { dir_recursive = !dir_recursive; });
	
	tb_filter = new textBox(TEXTBOX_INPUT.text, function(str) { dir_filter = str; })
#endregion