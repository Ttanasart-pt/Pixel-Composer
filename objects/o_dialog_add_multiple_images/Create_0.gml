/// @description init
event_inherited();

#region data
	nodes = [
		ALL_NODES[? "Node_Image"],
		ALL_NODES[? "Node_Image_Sequence"],
		ALL_NODES[? "Node_Image_Animated"],
		ALL_NODES[? "Node_Canvas"],
	];
	
	destroy_on_click_out = true;
	dialog_w = ui(50 + 80 * array_length(nodes));
	dialog_h = ui(176);
	
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
	
	cb_recursive = new checkBox(function() /*=>*/ { dir_recursive = !dir_recursive; });
	tb_filter    = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { dir_filter = str; })
#endregion