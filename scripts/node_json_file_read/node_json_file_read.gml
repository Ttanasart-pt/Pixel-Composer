function Node_create_Json_File_Read(_x, _y, _group = noone) { #region
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename("JSON file|*.json", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Json_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
} #endregion

function Node_create_Json_File_Read_path(_x, _y, path) { #region
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Json_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
} #endregion

function Node_Json_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "JSON File In";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "JSON file|*.json" })
		.rejectArray();
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	outputs[| 1] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	setIsDynamicInput(1);
	output_fix_len = ds_list_size(outputs);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
			.setVisible(true, true);
		
		var index = ds_list_size(outputs);
		outputs[| index] = nodeValue("Values", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	content      = {};
	path_current = "";
	edit_time    = 0;
	
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
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		updatePaths(path_get(getInputData(0)));
		triggerRender();
	} #endregion
	
	static refreshDynamicInput = function() { #region
		var _in = ds_list_create();
		var _ot = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		for( var i = 0; i < output_fix_len; i++ )
			ds_list_add(_ot, outputs[| i]);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
			if(getInputData(i) != "") {
				ds_list_add(_in,  inputs[| i + 0]);
				ds_list_add(_ot, outputs[| i + 1]);
			} else {
				delete  inputs[| i + 0];
				delete outputs[| i + 1];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		for( var i = 0; i < ds_list_size(_ot); i++ )
			_ot[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		ds_list_destroy(outputs);
		outputs = _ot;
		
		createNewInput();
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	} #endregion
	
	function updatePaths(path) { #region
		if(path == -1) return false;
		
		var ext   = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".json") return false;
		
		outputs[| 0].setValue(path);
				
		content = json_load_struct(path);
				
		if(path_current == "") 
			first_update = true;
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));
				
		return true;
	} #endregion
	
	static step = function() { #region
		if(attributes.file_checker && path_current != "") {
			if(file_get_modify_s(path_current) > edit_time) {
				updatePaths();
				triggerRender();
			}
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = path_get(getInputData(0));
		if(path_current != path) updatePaths(path);
		
		outputs[| 1].setValue(content);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var key = getInputData(i);
			var out = outputs[| i + 1];
			
			out.name = key;
			var keys = string_splice(key, ".");
			var _str = content;
			
			for( var j = 0; j < array_length(keys); j++ ) {
				var k = keys[j];
				
				if(!variable_struct_exists(_str, k)) {
					out.setValue(0);
					out.setType(VALUE_TYPE.float);
					break;
				}
				
				var val = variable_struct_get(_str, k);
				if(j == array_length(keys) - 1) {
					if(is_struct(val))
						out.setType(VALUE_TYPE.struct);
					else if(is_array(val) && array_length(val))
						out.setType(is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float);
					else
						out.setType(is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float);
					
					out.setValue(val);
				}
				
				if(is_struct(val))	_str = val;
				else				break;
			}
		}
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = filename_name(path_current);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
	
	static doApplyDeserialize = function() { refreshDynamicInput(); }
}