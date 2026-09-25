function Node_Byte_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Byte File Out";
	color = COLORS.node_blend_input;
	always_pad = true;
	w = 128;
	
	////- =Path
	newInput( 0, nodeValue_FPath("Path")).setDisplay(VALUE_DISPLAY.path_save, { filter: "any file|*" }).rejectArray();
	newInput( 2, nodeValue_Text( "Extension", "txt" )).rejectArray();
	
	////- =Content
	newInput( 1, nodeValue_Buffer()).setVisible(true, true);
	// 3
	
	inputs_display_list = [ 
		[ "Path",    false ],  0,  2, 
		[ "Content", false ],  1, 
	]
	
	////- Node
	
	static writeFile = function() {
		var path = getInputData(0);
		var ext  = getInputData(2);
		
		var cont = getInputData(1);
		
		if(path == "" || cont == noone) return;
		path = filename_ext_verify(path, "." + ext);
		
		buffer_save(cont, path);
	}
	
	insp1button = button(function() /*=>*/ { getInputs(); writeFile(); }).setTooltip(__txt("Export"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static update = function(frame = CURRENT_FRAME) { writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var str  = filename_name(getInputData(0));
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}