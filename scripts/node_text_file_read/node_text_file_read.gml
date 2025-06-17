function Node_create_Text_File_Read(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_compat("text file|*.txt", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Text_File_Read(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_create_Text_File_Read_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Text_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_Text_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Text File In";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	newInput(0, nodeValue_Path("Path"))
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "any file|*" })
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Content", VALUE_TYPE.text, ""));
	newOutput(1, nodeValue_Output("Path", VALUE_TYPE.path, ""))
		.setVisible(true, true);
	
	content      = "";
	path_current = "";
	edit_time    = 0;
	
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() /*=>*/ {return attributes.file_checker}, new checkBox(function() /*=>*/ {return toggleAttribute("file_checker")}) ]);
	
	first_update = false;
	
	on_drop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	setTrigger(1, __txt("Refresh"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { updatePaths(path_get(getInputData(0))); triggerRender(); });
	
	function updatePaths(path = path_current) {
		if(path == -1) return false;
		
		var ext   = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		outputs[1].setValue(path);
				
		content = file_read_all(path);
		
		if(path_current == "") 
			first_update = true;
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));
		logNode($"Loaded file: {path}", false);
		
		return true;
	}
	
	static step = function() {
		if(attributes.file_checker && file_exists_empty(path_current)) {
			var _modi = file_get_modify_s(path_current);
			
			if(_modi > edit_time) {
				edit_time = _modi;
				
				run_in(2, function() { updatePaths(); triggerRender(); });
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var path = path_get(getInputData(0));
		if(path_current != path) updatePaths(path);
		
		outputs[0].setValue(content);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(path_current);
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static dropPath = function(path) { 
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path); 
		check_directory_redirector(path);
	}
}