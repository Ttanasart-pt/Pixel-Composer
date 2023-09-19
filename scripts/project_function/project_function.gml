function closeProject(project) {
	project.active = false;
	array_remove(PROJECTS, project);
	if(array_length(PROJECTS) == 0) {
		PROJECT  = new Project();
		PROJECTS = [ PROJECT ];
	}
	
	var panels = findPanels("Panel_Graph");
	
	for( var i = array_length(panels) - 1; i >= 0; i-- ) {
		var panel = panels[i];
		//print($" Check {panel.project.path}");
		if(panel.project != project) 
			continue;
		
		if(array_length(panels) == 1) {
			panel.setProject(PROJECT);
			panel.onFocusBegin();
			panel.resetContext();
		} else {
			panel.panel.remove(panel);
			array_remove(panels, panel);
		}
	}
		
	project.cleanup();
}