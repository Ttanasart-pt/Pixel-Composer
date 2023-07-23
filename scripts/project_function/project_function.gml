/// @desc Function Description
/// @param {Struct.Project} project Description
function closeProject(project) {
	//print($"Close {PROJECT.path}");
	
	PROJECT.active = false;
	array_remove(PROJECTS, project);
	if(array_length(PROJECTS) == 0)
		PROJECT = new Project();
	
	var panels = findPanels("Panel_Graph");
	
	for( var i = array_length(panels) - 1; i >= 0; i-- ) {
		var panel = panels[i];
		//print($" Check {panel.project.path}");
		if(panel.project == project) {
			panel.panel.remove(panel);
			array_remove(panels, panel)
		}
	}
	
	if(array_length(panels) == 0)
		setPanel();
		
	project.cleanup();
}