/// @description init
event_inherited();

#region data
	nodes = [
		ALL_NODES[$ "Node_Json_File_Read"],
		ALL_NODES[$ "Node_3D_Mesh_Json"],
	];
	
	destroy_on_click_out = true;
	title_h   = ui(32);
	content_h = ui(132);
	
	dialog_w  = ui(50 + 80 * array_length(nodes));
	dialog_h  = title_h + content_h;
	
	path = "";
	function setPath(_path) { path = _path; }
#endregion