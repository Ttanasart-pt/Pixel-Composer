function Node_Text_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Text File Out";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, ["*.txt", ""])
		.rejectArray();
		
	inputs[| 1] = nodeValue("Content", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	static writeFile = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(filename_ext(path) != ".txt")
			path += ".txt";
			
		var cont = inputs[| 1].getValue();
		
		var f = file_text_open_write(path);
		file_text_write_string(f, string(cont));
		file_text_close(f);
	}
	
	static update = function(frame = ANIMATOR.current_frame) { writeFile(); }
	static onInspector1Update = function() { writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(inputs[| 0].getValue());
		if(filename_ext(str) != ".txt")
			str += ".txt";
			
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}