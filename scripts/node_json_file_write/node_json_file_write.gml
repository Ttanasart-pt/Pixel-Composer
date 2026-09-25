function Node_Json_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "JSON File Out";
	color = COLORS.node_blend_input;
	
	////- =Path
	newInput( 0, nodeValue_FPath(  "Path"   )).setDisplay(VALUE_DISPLAY.path_save, { filter: "json file|*.json" }).rejectArray();
	newInput( 4, nodeValue_Text(   "Extension", "json" )).rejectArray();
	
	////- =Content
	newInput( 1, nodeValue_Struct( "Struct" )).shortenDisplay().setVisible(true, true);
	newInput( 2, nodeValue_Bool(   "Pretty Print", false ));
	newInput( 3, nodeValue_Bool(   "Serialize",    true  ));
	// 5
	
	input_display_list = [  
		[ "Path",    false ],  0,  4, 
		[ "Content", false ],  1,  2,  3 
	];
	
	////- Node
	
	static writeFile = function() {
		var path = getInputData( 0);
		var ext  = getInputData( 4);
		
		var cont = getInputData( 1);
		var pret = getInputData( 2);
		var seri = getInputData( 3);
		
		if(path == "") return;
		path = filename_ext_verify(path, "." + ext);
		
		if(seri && struct_has(cont, "serialize"))
			cont = cont.serialize();
		
		json_save_struct(path, cont, pret);
	}
	
	static update = function(frame = CURRENT_FRAME) { 
		writeFile(); 
	}
	
	insp1button = button(function() /*=>*/ {return writeFile()}).setTooltip(__txt("Export"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		var str = getInputData(0);
		var ext = getInputData(4);
		str = filename_name(filename_ext_verify(str, "." + ext));
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}