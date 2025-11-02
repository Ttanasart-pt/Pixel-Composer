/// @description init
event_inherited();

#region data
	nodes = [
		ALL_NODES[$ "Node_Image"],
		ALL_NODES[$ "Node_Image_Sequence"],
		ALL_NODES[$ "Node_Image_Animated"],
		ALL_NODES[$ "Node_Canvas"],
	];
	
	destroy_on_click_out = true;
	title_h   = ui(32);
	content_h = ui(132);
	
	dialog_w  = ui(50 + 80 * array_length(nodes));
	dialog_h  = title_h + content_h + ui(12);
	
	paths	      = "";
	is_dir	      = false;
	dir_recursive = false;
	dir_filter    = ".png;.jpg;.jpeg";
	
	function setPath(path) {
		paths	= path;
		is_dir	= directory_exists(path[0]);
		
		if(is_dir) {
			dialog_h += ui(96);
			dialog_w += ui(80);
			array_push(nodes, ALL_NODES[$ "Node_Directory_Search"]);
		}
	}
	
	cb_recursive = new checkBox(function()  /*=>*/ { dir_recursive = !dir_recursive; });
	tb_filter    = textBox_Text(function(s) /*=>*/ { dir_filter = s; })
#endregion