function Node_XML_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "XML File Out";
	color = COLORS.node_blend_input;
	w = 128;
	
	////- =Path
	newInput( 0, nodeValue_FPath(  "Path"   )).setDisplay(VALUE_DISPLAY.path_save, { filter: "xml file|*.xml" }).rejectArray();
	newInput( 2, nodeValue_Text(   "Extension", "xml" )).rejectArray();
	
	////- =Content
	newInput( 1, nodeValue_Struct( "Struct" )).setVisible(true, true);
	// 3
	
	inputs_display_list = [ 
		[ "Path",    false ],  0,  2, 
		[ "Content", false ],  1, 
	]
	
	////- Node
	
	static writeFile = function() {
		var path = getInputData( 0);
		var ext  = getInputData( 2);
		
		var cont = getInputData( 1);
		
		if(path == "") return;
		path = filename_ext_verify(path, "." + ext);
		
		var str  = SnapToXML(cont);
		
		file_text_write_all(path, str);
	}
	
	insp1button = button(function() /*=>*/ {return writeFile()}).setTooltip(__txt("Export"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
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