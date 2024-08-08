function Node_Byte_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Byte File Out";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	inputs[0]  = nodeValue_Text("Path", self, "")
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "any file|*" })
		.rejectArray();
		
	inputs[1] = nodeValue_Buffer("Content", self, noone)
		.setVisible(true, true);
	
	static writeFile = function() {
		var path = getInputData(0);
		if(path == "") return;
		
		var cont = getInputData(1);
		if(cont == noone) return;
		
		buffer_save(cont, path);
	}
	
	static update = function(frame = CURRENT_FRAME) { writeFile(); }
	static onInspector1Update = function() { getInputs(); writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = filename_name(getInputData(0));
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}