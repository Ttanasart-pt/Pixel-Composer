function Node_Text_File_Write(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Text out";
	color = COLORS.node_blend_input;
	previewable = false;
	
	w = 128;
	
	
	inputs[| 0]  = nodeValue(0, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_save, ["*.txt", ""]);
		
	inputs[| 1] = nodeValue(1, "Content", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	static update = function() {
		var path = inputs[| 0].getValue();
		if(path == "") return;
		if(filename_ext(path) != ".txt")
			path += ".txt";
			
		var cont = inputs[| 1].getValue();
		
		var f = file_text_open_write(path);
		file_text_write_string(f, cont);
		file_text_close(f);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(inputs[| 0].getValue());
		if(filename_ext(str) != ".txt")
			str += ".txt";
			
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}