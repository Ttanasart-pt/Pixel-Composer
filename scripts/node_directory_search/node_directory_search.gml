function Node_create_Directory_Search(_x, _y, _group = noone) { #region
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_directory("");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Directory_Search(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
} #endregion

function Node_Directory_Search(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Directory Search";
	color = COLORS.node_blend_input;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "dir" });
		
	inputs[| 1]  = nodeValue("Extensions", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, ".png");
	
	inputs[| 2]  = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Surface", "Text" ]);
		
	outputs[| 0] = nodeValue("Outputs", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setVisible(true, true);
		
	outputs[| 1] = nodeValue("Paths", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, [""])
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	path_current = "";
	paths = {};
	
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	function deleteSprite(pathObj) { #region
		if(sprite_exists(pathObj.spr))
			sprite_delete(pathObj.spr);
	} #endregion
	
	function refreshSprite(pathObj) { #region
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
					noti_warning($"Image node: File not a valid image.");
					break;
				}
				
				pathObj.edit_time = file_get_modify_s(path);
		}
		
		return pathObj;
	} #endregion
	
	function refreshText(pathObj) { #region
		var path  = pathObj.path;
		var ext   = string_lower(filename_ext(path));
		
		pathObj.content   = file_read_all(path);
		pathObj.edit_time = file_get_modify_s(path);
		
		return pathObj;
	} #endregion
	
	function updatePaths() { #region
		var path   = getInputData(0);
		var filter = getInputData(1);
		var type   = getInputData(2);
		
		var _paths = struct_get_names(paths);
		for (var i = 0, n = array_length(_paths); i < n; i++)
			deleteSprite(paths[$ _paths[i]]);
		paths = {};
		
		var _paths = paths_to_array_ext(path, filter);
		print(array_length(_paths));
		
		for (var i = 0, n = array_length(_paths); i < n; i++) {
			var _path = _paths[i];
			paths[$ _path] = { path: _path, spr: -1, edit_time: 0 };
			
			     if(type == 0) refreshSprite(paths[$ _path]);
			else if(type == 1) refreshText(paths[$ _path]);
		}
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		updatePaths();
		triggerRender();
	} #endregion
	
	static step = function() { #region
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
		
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		updatePaths();
		var type   = getInputData(2);
	
		var _outsurf = outputs[| 0].getValue();
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
		
		outputs[| 0].setType(type == 0? VALUE_TYPE.surface : VALUE_TYPE.text);
		outputs[| 0].setValue(_outsurf);
		outputs[| 1].setValue(_imgPaths);
	} #endregion
}