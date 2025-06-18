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

function project_get_thumbnail(_path) {
	if(!file_exists_empty(_path)) return undefined;
	
	var rawBuff = buffer_load(_path);
	buffer_to_start(rawBuff);
	
	var _id = buffer_read_text(rawBuff, 4);
	if(_id != "PXCX") return undefined;
	
	var offset = buffer_read(rawBuff, buffer_u32);
	var _id    = buffer_read_text(rawBuff, 4);
	if(_id != "THMB") return undefined;
	
	var thumbLen = buffer_read(rawBuff, buffer_u32);
	var thumbBuf = buffer_create(thumbLen, buffer_fixed, 1);
	buffer_copy(rawBuff, buffer_tell(rawBuff), thumbLen, thumbBuf, 0);
	thumbBuf = buffer_decompress(thumbBuf);
	
	var thumbSurf = surface_create(64, 64);
	buffer_set_surface(thumbBuf, thumbSurf, 0);
	
	var _spr = sprite_create_from_surface(thumbSurf, 0, 0, 64, 64, false, false, 32, 32);
	surface_free(thumbSurf);
	
	return _spr;
}