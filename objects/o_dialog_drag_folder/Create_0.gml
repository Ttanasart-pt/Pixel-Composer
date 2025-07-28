/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	title_h   = ui(32);
	
	dialog_w  = ui(290);
	dialog_h  = title_h + ui(148);
	
	target			= noone;
	dir_paths		= "";
	dir_recursive	= false;
	dir_filter		= ".png";
	
	cb_recursive = new checkBox(function()  /*=>*/ { dir_recursive = !dir_recursive; });
	tb_filter    = textBox_Text(function(s) /*=>*/ { dir_filter = s; })
#endregion