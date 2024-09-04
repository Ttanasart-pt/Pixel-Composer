function Node_Path_Separate_Folder(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Separate File Path";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Path("Path", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Keep extension", self, true));
	
	newOutput(0, nodeValue_Output("Directory", self, VALUE_TYPE.path, ""));
	
	newOutput(1, nodeValue_Output("File Name", self, VALUE_TYPE.path, ""));
	
	static processData = function(_outData, _data, _index = 0) { 
		var _path = _data[0];
		var _ext  = _data[1];
		
		_outData[0] = filename_dir(_path);
		_outData[1] = _ext? filename_name(_path) : filename_name_only(_path);
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = outputs[1].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}