function Node_create_Json_File_Read(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename(".json", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Json_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_create_Json_File_Read_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Json_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_Json_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "JSON File In";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.json", ""])
		.rejectArray();
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	outputs[| 1] = nodeValue("Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	data_length = 1;
	input_fix_len  = ds_list_size(inputs);
	output_fix_len = ds_list_size(outputs);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
			.setVisible(true, true);
		
		var index = ds_list_size(outputs);
		outputs[| index] = nodeValue("Values", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	content = {};
	path_current = "";
	
	first_update = false;
	
	on_dragdrop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		update();
	}
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		var _ot = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		for( var i = 0; i < output_fix_len; i++ )
			ds_list_add(_ot, outputs[| i]);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i++ ) {
			if(inputs[| i].getValue() != "") {
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
	}
	
	static onValueUpdate = function(index = 0) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	function updatePaths(path) {
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".json") return false;
		
		outputs[| 0].setValue(path);
				
		content = json_load_struct(path);
				
		if(path_current == "") 
			first_update = true;
		path_current = path;
				
		return true;
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(path_current != path) updatePaths(path);
		
		outputs[| 1].setValue(content);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var key = inputs[| i].getValue();
			var out = outputs[| i + 1];
			
			out.name = key;
			var keys = string_splice(key, ".");
			var _str = content;
			
			for( var j = 0; j < array_length(keys); j++ ) {
				var k = keys[j];
				
				if(!variable_struct_exists(_str, k)) {
					out.setValue(0);
					out.type = VALUE_TYPE.float;
					break;
				}
				
				var val = variable_struct_get(_str, k);
				if(j == array_length(keys) - 1) {
					if(is_struct(val))
						out.type = VALUE_TYPE.struct;
					else if(is_array(val) && array_length(val))
						out.type = is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float;
					else
						out.type = is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float;
					
					out.setValue(val);
				}
				
				if(is_struct(val))	_str = val;
				else				break;
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = filename_name(path_current);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createNewInput();
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
	}
}