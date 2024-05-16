/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	dialog_w = ui(290);
	dialog_h = ui(180);
	
	paths	= "";
	is_dir	= false;
	dir_recursive = false;
	dir_filter    = ".png";
	
	function setPath(path) {
		paths	= path;
		is_dir	= directory_exists(path[0]);
		
		if(is_dir) {
			dialog_h += ui(96);
			dialog_w += ui(80);
			array_push(nodes, ALL_NODES[? "Node_Directory_Search"]);
		}
	}
	
	cb_recursive = new checkBox(function(val) { dir_recursive = !dir_recursive; });
	
	tb_filter = new textBox(TEXTBOX_INPUT.text, function(str) { dir_filter = str; })
#endregion

#region nodes
	nodes = [
		ALL_NODES[? "Node_Image"],
		ALL_NODES[? "Node_Image_Sequence"],
		ALL_NODES[? "Node_Image_Animated"],
	];
#endregion