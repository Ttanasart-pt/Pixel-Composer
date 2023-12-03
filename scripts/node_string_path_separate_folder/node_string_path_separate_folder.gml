function Node_Path_Separate_Folder(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Separate File Path";
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Keep extension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue("Directory", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "");
	
	outputs[| 1] = nodeValue("File Name", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "");
	
	static processData = function(_output, _data, _index = 0) { 
		if(_index == 0)
			return filename_dir(_data[0]);
		else if(_index == 1)
			return _data[1]? filename_name(_data[0]) : filename_name_only(_data[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str = outputs[| 1].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}