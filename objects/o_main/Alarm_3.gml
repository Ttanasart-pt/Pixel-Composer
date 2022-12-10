/// @description file drop
#region drop
	PANEL_GRAPH.stepBegin();
	
	if(PANEL_GRAPH.dropFile(file_dropping)) {
		Render(false);
	} else
		load_file_path(file_dropping, true);
	file_dropping = "";
#endregion
