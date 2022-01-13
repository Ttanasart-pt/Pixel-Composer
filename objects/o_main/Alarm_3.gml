/// @description file drop
#region drop
	PANEL_GRAPH.stepBegin();
	
	if(PANEL_GRAPH.dropFile(file_dropping)) {
		renderAll();
	} else
		load_file_path(file_dropping);
	file_dropping = "";
#endregion
