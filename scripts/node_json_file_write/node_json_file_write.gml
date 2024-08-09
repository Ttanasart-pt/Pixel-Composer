function Node_Json_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "JSON File Out";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	inputs[0]  = nodeValue_Path("Path", self, "")
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "json file|*.json" })
		.rejectArray();
		
	inputs[1]  = nodeValue_Struct("Struct", self, {})
		.setVisible(true, true);
	
	input_display_list = [ 0, 1 ]
	
	static writeFile = function() {
		var path = getInputData(0);
		if(path == "") return;
		if(filename_ext(path) != ".json")
			path += ".json";
		
		var cont = getInputData(1);
		json_save_struct(path, cont);
	}
	
	static update = function(frame = CURRENT_FRAME) { writeFile(); }
	static onInspector1Update = function() { writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var str = filename_name(getInputData(0));
		if(filename_ext(str) != ".json")
			str += ".json";
			
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}