function Node_Byte_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Byte File In";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "any file|*" })
		.rejectArray();
	
	outputs[| 0] = nodeValue("Content", self, JUNCTION_CONNECT.output, VALUE_TYPE.buffer, noone);
	outputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	content = noone;
	
	on_drop_file = function(path) { #region
		path = path_get(path);
		inputs[| 0].setValue(path);
		
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	} #endregion
	
	path_current = "";
	edit_time    = 0;
	
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		updatePaths(path_get(getInputData(0)));
		triggerRender();
	} #endregion
	
	function updatePaths(path = path_current) { #region
		if(path == -1) return false;
		
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));
		
		outputs[| 1].setValue(path_current);
		content = buffer_load(path_current);
		
		return true;
	} #endregion
	
	static step = function() { #region
		if(attributes.file_checker && file_exists_empty(path_current)) {
			var _modi = file_get_modify_s(path_current);
			
			if(_modi > edit_time) {
				edit_time = _modi;
				
				run_in(2, function() { updatePaths(); triggerRender(); });
			}
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = path_get(getInputData(0));
		if(path_current != path)
			updatePaths(path);
			
		outputs[| 0].setValue(content);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = filename_name(getInputData(0));
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	} #endregion
}