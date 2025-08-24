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

global.project_get_thumbnail_surface = surface_create(64, 64);

function project_get_thumbnail(_path) {
	if(!file_exists_empty(_path)) return undefined;
	
	var rawBuff = buffer_load(_path);
	if(!buffer_exists(rawBuff)) return undefined;
	
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
	
	global.project_get_thumbnail_surface = surface_verify(global.project_get_thumbnail_surface, 64, 64);
	buffer_set_surface(thumbBuf, global.project_get_thumbnail_surface, 0);
	
	var _spr = sprite_create_from_surface(global.project_get_thumbnail_surface, 0, 0, 64, 64, false, false, 32, 32);
	return _spr;
}

function project_get_thumbnail_surface(_path) {
	var _spr = project_get_thumbnail(_path);
	if(!sprite_exists(_spr)) return undefined;
	
	var _sw = sprite_get_width(_spr);
	var _sh = sprite_get_height(_spr);
	var _surf = surface_create(_sw, _sh);
	surface_set_shader(_surf);
		draw_sprite(_spr, 0, _sw / 2, _sh / 2);
	surface_reset_shader();
	
	sprite_delete(_spr);
	return _surf;
}