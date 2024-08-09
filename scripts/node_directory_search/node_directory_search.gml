function Node_create_Directory_Search(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_directory("");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Directory_Search(_x, _y, _group).skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_Directory_path(_x, _y, path) {
	if(!directory_exists(path)) return noone;
	
	var node = new Node_Directory_Search(_x, _y, PANEL_GRAPH.getCurrentContext()).skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	return node;	
}

function Node_Directory_Search(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Directory Search";
	color = COLORS.node_blend_input;
	
	inputs[0]  = nodeValue_Path("Path", self, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "dir" });
		
	inputs[1]  = nodeValue_Text("Extensions", self, ".png");
	
	inputs[2]  = nodeValue_Enum_Scroll("Type", self,  0, [ "Surface", "Text" ]);
	
	inputs[3]  = nodeValue_Bool("Recursive", self, false)
		
	outputs[0] = nodeValue_Output("Outputs", self, VALUE_TYPE.surface, [])
		.setVisible(true, true);
		
	outputs[1] = nodeValue_Output("Paths", self, VALUE_TYPE.path, [""])
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	path_current = "";
	paths = {};
	
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	function deleteSprite(pathObj) {
		if(sprite_exists(pathObj.spr))
			sprite_delete(pathObj.spr);
	}
	
	function refreshSprite(pathObj) {
		var path  = pathObj.path;
		var ext   = string_lower(filename_ext(path));
		
		switch(ext) {
			case ".png":
			case ".jpg":
			case ".jpeg":
			case ".gif":
				if(sprite_exists(pathObj.spr))
					sprite_delete(pathObj.spr);
					
				pathObj.spr = sprite_add(path, 1, false, false, 0, 0);
				
				if(pathObj.spr == -1) {
					var _txt = $"Image node: File not a valid image.";
					logNode(_txt); noti_warning(_txt);
					break;
				}
				
				pathObj.edit_time = file_get_modify_s(path);
		}
		
		return pathObj;
	}
	
	function refreshText(pathObj) {
		var path  = pathObj.path;
		var ext   = string_lower(filename_ext(path));
		
		pathObj.content   = file_read_all(path);
		pathObj.edit_time = file_get_modify_s(path);
		
		return pathObj;
	}
	
	function updatePaths() {
		var path   = getInputData(0);
		var filter = getInputData(1);
		var type   = getInputData(2);
		var recurs = getInputData(3);
		
		var _paths = struct_get_names(paths);
		for (var i = 0, n = array_length(_paths); i < n; i++)
			deleteSprite(paths[$ _paths[i]]);
		paths = {};
		
		var _paths = path_dir_get_files(path, filter, recurs);
		
		if(array_empty(_paths)) {
			var _txt = "Directory Search: Empty search results.";
			logNode(_txt); noti_warning(_txt);
			return;
		} 
		
		for (var i = 0, n = array_length(_paths); i < n; i++) {
			var _path = _paths[i];
			paths[$ _path] = { path: _path, spr: -1, edit_time: 0 };
			
			     if(type == 0) refreshSprite(paths[$ _path]);
			else if(type == 1) refreshText(paths[$ _path]);
		}
		
		var _p = string_trim_end(path, ["/", "\\"]);
		setDisplayName(filename_name_only(_p));
	}
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		updatePaths();
		triggerRender();
	}
	
	static step = function() {
		if(attributes.file_checker) {
			var _update = false;
			var _paths  = struct_get_names(paths);
			
			for (var i = 0, n = array_length(_paths); i < n; i++) {
				var _pathObj = paths[$ _paths[i]];
				if(file_get_modify_s(_pathObj.path) > _pathObj.edit_time) {
					refreshSprite(_pathObj);
					_update = true;
				}
			}
			
			if(_update) triggerRender();
		}
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		updatePaths();
		var type   = getInputData(2);
	
		var _outsurf = outputs[0].getValue();
		if(!is_array(_outsurf)) _outsurf = [ _outsurf ];
		
		var _paths    = struct_get_names(paths);
		var _ind      = 0;
		var _imgPaths = [];
		
		for (var i = 0, n = array_length(_paths); i < n; i++) {
			var _pathObj = paths[$ _paths[i]];
			var _spr     = _pathObj.spr;
			
			if(!sprite_exists(_spr)) continue;
			
			var ww = sprite_get_width(_spr);
			var hh = sprite_get_height(_spr);
			
			var _surf = array_safe_get_fast(_outsurf, i);
			    _surf = surface_verify(_surf, ww, hh, attrDepth());
			
			surface_set_shader(_surf, noone);
				draw_sprite(_spr, 0, 0, 0);
			surface_reset_shader();
			
			_imgPaths[_ind]  = _pathObj.path;
			_outsurf[_ind++] = _surf;
		}
		
		array_resize(_imgPaths, _ind);
		array_resize(_outsurf,  _ind);
		
		outputs[0].setType(type == 0? VALUE_TYPE.surface : VALUE_TYPE.text);
		outputs[0].setValue(_outsurf);
		outputs[1].setValue(_imgPaths);
	}
	
	static dropPath = function(path) { 
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!directory_exists(path)) return;
		
		inputs[0].setValue(path); 
	}
}