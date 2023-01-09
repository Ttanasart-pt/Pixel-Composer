function Node_create_Json_File_Read(_x, _y, _group = -1) {
	var path = "";
	if(!LOADING && !APPENDING) {
		path = get_open_filename(".json", "");
		if(path == "") return noone;
	}
	
	var node = new Node_Json_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_create_Json_File_Read_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Json_File_Read(_x, _y);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_Json_File_Read(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "JSON in";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	min_h = 0;
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.json", ""]);
	
	outputs[| 0] = nodeValue(0, "Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	data_length = 1;
	input_fix_len = ds_list_size(inputs);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "Key", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
			.setVisible(true, true);
		
		outputs[| index] = nodeValue( index, "Values", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
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
	
	static refreshDynamicInput = function() {
		var _in = ds_list_create();
		var _ot = ds_list_create();
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].getValue() != "") {
				ds_list_add(_in, inputs[| i]);
				ds_list_add(_ot, outputs[| i]);
			} else {
				delete inputs[| i];
				delete outputs[| i];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ ) {
			_in[| i].index = i;
			_ot[| i].index = i;
		}
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		ds_list_destroy(outputs);
		outputs = _ot;
		
		createNewInput();
	}
	
	static onValueUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	function updatePaths(path) {
		if(path_current == path) return false;
		
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = filename_ext(path);
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".json") return false;
		
		outputs[| 0].setValue(path);
				
		content = json_load_struct(path);
				
		if(path_current == "") 
			first_update = true;
		path_current = path;
				
		return true;
	}
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var key = inputs[| i].getValue();
			
			outputs[| i].name = key;
			if(variable_struct_exists(content, key)) {
				var val = variable_struct_get(content, key);
				outputs[| i].setValue(val);
				
				if(is_array(val) && array_length(val))
					outputs[| i].type = is_string(val[0])? VALUE_TYPE.text : VALUE_TYPE.float;
				else
					outputs[| i].type = is_string(val)? VALUE_TYPE.text : VALUE_TYPE.float;
			} else {
				outputs[| i].setValue(0);
				outputs[| i].type = VALUE_TYPE.float;
			}
		}
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = filename_name(path_current);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
	
	static doApplyDeserialize = function() {
		refreshDynamicInput();
	}
}