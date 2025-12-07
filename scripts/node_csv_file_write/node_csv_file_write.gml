function Node_create_CSV_File_Write(_x, _y, _group = noone) {
	var path = "";
	
	var node = new Node_CSV_File_Write(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_CSV_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "CSV File Out";
	color = COLORS.node_blend_input;
	
	w = 128;
	
	newInput(0, nodeValue_Path("Path"))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "csv file|*.csv" })
		.rejectArray();
	
	newInput(1, nodeValue("Content", self, CONNECT_TYPE.input, VALUE_TYPE.any, ""))
		.setVisible(true, true);
	
	insp1button = button(function() /*=>*/ {return writeFile()}).setTooltip(__txt("Export"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static writeFile = function() {
		var path = getInputData(0);
		if(path == "") return;
		if(filename_ext(path) != ".csv")
			path += ".csv";
		
		var _val = getInputData(1);
		var str = "";
		
		if(is_array(_val)) {
			for( var i = 0, n = array_length(_val); i < n; i++ ) {
				if(is_array(_val[i])) {
					for( var j = 0; j < array_length(_val[i]); j++ )
						str += (j? ", " : "") + string(_val[i][j])
					str += "\n";
				} else 
					str += (i? ", " : "") + string(_val[i])
			}
		} else 
			str = string(_val);
		
		var f = file_text_open_write(path);
		file_text_write_string(f, str);
		file_text_close(f);
	}
	
	static update = function(frame = CURRENT_FRAME) { writeFile(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		var str = filename_name(getInputData(0));
		if(filename_ext(str) != ".csv")
			str += ".csv";
			
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}