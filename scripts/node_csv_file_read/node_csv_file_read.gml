function Node_create_CSV_File_Read(_x, _y, _group = noone) { #region
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_pxc("comma separated value|*.csv", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_CSV_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
} #endregion

function Node_create_CSV_File_Read_path(_x, _y, path) { #region
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_CSV_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
} #endregion

function Node_CSV_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "CSV File In";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "CSV file|*.csv" })
		.rejectArray();
		
	inputs[| 1]  = nodeValue("Convert to number", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Content", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	outputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	content      = "";
	path_current = "";
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	first_update = false;
	
	on_drop_file = function(path) { #region
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	} #endregion
	
	function updatePaths(path = path_current) { #region
		path = path_get(path);
		if(path == -1) return false;
		
		var ext = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".csv") return false;
			
		outputs[| 1].setValue(path);
		
		content = file_text_read_all_lines(path);
		
		var convert = getInputData(1);
		outputs[| 0].setType(convert? VALUE_TYPE.float : VALUE_TYPE.text);
		if(convert) {
			for( var i = 0, n = array_length(content); i < n; i++ ) {
				var c = content[i];
				
				if(is_array(c)) {
					for( var j = 0; j < array_length(c); j++ )
						content[i][j] = toNumber(c[j]);
				} else 
					content[i] = toNumber(c);
			}
		}
		
		if(path_current == "") 
			first_update = true;
			
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));	
		
		return true;
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		updatePaths(path_get(getInputData(0)));
		triggerRender();
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
		if(path_current != path) updatePaths(path);
		
		outputs[| 0].setValue(content);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(path_current);
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
}