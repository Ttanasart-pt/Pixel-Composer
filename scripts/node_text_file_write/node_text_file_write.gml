function Node_Text_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Text File Out";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	newInput(0, nodeValue_Path("Path", self, ""))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "text file|*.txt" })
		.rejectArray();
		
	newInput(1, nodeValue_Text("Content", self, ""))
		.setVisible(true, true);
	
	static writeFile = function() {
		var path = getInputData(0);
		if(path == "") return;
		if(filename_ext(path) == "")
			path += ".txt";
			
		var cont = getInputData(1);
		
		var f = file_text_open_write(path);
		file_text_write_string(f, string(cont));
		file_text_close(f);
	}
	
	setTrigger(1,,, function() /*=>*/ { getInputs(); writeFile(); });
	
	static update = function(frame = CURRENT_FRAME) { writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(getInputData(0));
		if(filename_ext(str) != ".txt")
			str += ".txt";
			
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}