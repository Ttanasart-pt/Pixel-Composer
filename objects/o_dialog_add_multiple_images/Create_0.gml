/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	dialog_w = ui(290);
	dialog_h = ui(172);
	
	paths	= "";
	is_dir	= false;
	dir_recursive = false;
	dir_filter    = "*";
	
	function setPath(path) {
		paths	= path;
		is_dir	= directory_exists(path);
		
		if(is_dir) {
			dialog_h += ui(96);
		}
	}
	
	cb_recursive = new checkBox(function(val) { dir_recursive = !dir_recursive; });
	
	tb_filter = new textBox(TEXTBOX_INPUT.text, function(str) { dir_filter = str; })
#endregion

#region nodes
	nodes = [
		nodeFind("Image"),
		nodeFind("Image array"),
		nodeFind("Animation"),
	];
#endregion