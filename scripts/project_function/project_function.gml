function closeProject(project) {
	array_remove(PROJECTS, project);
	if(array_length(PROJECTS) == 0)
		PROJECT = new Project();
	
	var panels = findPanels("Panel_Graph");
	
	for( var i = array_length(panels) - 1; i >= 0; i-- ) {
		var panel = panels[i];
		if(panel.project == project) {
			panel.panel.remove(panel);
			array_remove(panels, panel)
		}
	}
	
	if(array_length(panels) == 0)
		setPanel();
}