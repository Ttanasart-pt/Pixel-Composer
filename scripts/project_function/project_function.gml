function closeProject(project) {
	CALL("close");
	
	project.active = false;
	array_remove(PROJECTS, project);
	
	if(array_empty(PROJECTS)) {
		PROJECT  = new Project();
		PROJECTS = [ PROJECT ];
	}
	
	var panels = findPanels("Panel_Graph");
	
	for( var i = array_length(panels) - 1; i >= 0; i-- ) {
		var panel = panels[i];
		
		if(panel.project != project) 
			continue;
		
		if(array_length(panels) == 1) {
			panel.setProject(PROJECT);
			panel.reset();
			
		} else {
			panel.panel.remove(panel);
			array_remove(panels, panel);
		}
	}
		
	project.cleanup();
}