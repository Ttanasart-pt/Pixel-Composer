function Node_Text_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Text File Out";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	////- =Path
	newInput( 0, nodeValue_FPath( "Path"             )).setDisplay(VALUE_DISPLAY.path_save, { filter: "text file|*.txt" }).rejectArray();
	newInput( 2, nodeValue_Text(  "Extension", "txt" )).rejectArray();
	
	////- =Content
	newInput( 1, nodeValue_Text(  "Content" )).setVisible(true, true);
	// 3
	
	inputs_display_list = [ 
		[ "Path",    false ],  0,  2, 
		[ "Content", false ],  1, 
	]
	
	////- Node
	
	insp1button = button(function() /*=>*/ { getInputs(); writeFile(); }).setTooltip(__txt("Export"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static writeFile = function() {
		var path = getInputData( 0);
		var ext  = getInputData( 2);
		
		var cont = getInputData( 1);
		
		if(path == "") return;
		path = filename_ext_verify(path, "." + ext);
		
		var f = file_text_open_write(path);
		file_text_write_string(f, string(cont));
		file_text_close(f);
	}
	
	static update = function(frame = CURRENT_FRAME) { writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		var str = getInputData(0);
		var ext = getInputData(2);
		str = filename_name(filename_ext_verify(str, "." + ext));
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}