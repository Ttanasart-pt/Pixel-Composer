function Node_create_WAV_File_Read(_x, _y, _group = noone) {
	var path = "";
	if(!LOADING && !APPENDING && !CLONING) {
		path = get_open_filename(".wav", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_WAV_File_Read(_x, _y, _group);
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_create_WAV_File_Read_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_WAV_File_Read(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	
	return node;	
}

function Node_WAV_File_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "WAV File In";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, ["*.wav", ""])
		.rejectArray();
		
	outputs[| 0] = nodeValue("Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	outputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "");
	
	outputs[| 2] = nodeValue("Sample rate", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 44100)
		.setVisible(false);
	
	outputs[| 3] = nodeValue("Channels", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 2)
		.setVisible(false);
	
	outputs[| 4] = nodeValue("Duration (s)", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0)
		.setVisible(false);
	
	content = {};
	path_current = "";
	
	first_update = false;
	
	output_display_list = [ 0, 2, 3, 4, 1 ];
	
	on_dragdrop_file = function(path) {
		if(updatePaths(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	}
	
	function updatePaths(path) {
		path = try_get_path(path);
		if(path == -1) return false;
		
		var ext = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".wav") return false;
			
		outputs[| 1].setValue(path);
		
		content = file_read_wav(path);
		outputs[| 0].setValue(content.sound);
		outputs[| 2].setValue(content.sample);
		outputs[| 3].setValue(content.channels);
		outputs[| 4].setValue(content.duration);
		
		if(path_current == "") 
			first_update = true;
		path_current = path;
		return true;
	}
	
	insp1UpdateTooltip  = get_text("panel_inspector_refresh", "Refresh");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		updatePaths(path);
		update();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(path_current != path) updatePaths(path);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(path_current);
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}