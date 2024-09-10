function __Node_3D_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "3D Export";
	
	newInput(0, nodeValue("Vertex data", self, CONNECT_TYPE.input, VALUE_TYPE.d3vertex, [] ))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Path("Path", self, "", "Export location without '.obj' extension." ))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "3d object|*.obj" });
	
	newInput(2, nodeValue_Bool("Export texture", self, true ));
	
	input_display_list = [ 0,
		["Export",	false], 1, 2, 
	];
	
	insp1UpdateTooltip   = "Export";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { export(); }
	
	static export = function() { 
		var vert = getInputData(0);
		var path = getInputData(1);
		var text = getInputData(2);
		
		if(array_length(vert) == 0) return;
		
		var oPath = path + ".obj";
		var mPath = path + ".mtl";
		
		var fObj = file_text_open_write(oPath);
		var fMtl = file_text_open_write(mPath);
		
		var _p = 1;
		var _t = 1;
		var _n = 1;
		
		file_text_write_string(fObj, "mtllib " + filename_name(mPath) + "\n");
		
		for( var i = 0, n = array_length(vert); i < n; i++ ) {
			file_text_write_string(fObj, "\n");
			
			var v = vert[i];
			
			for( var j = 0; j < array_length(v.positions); j++ )
				file_text_write_string(fObj, "v " + string_format(v.positions[j][0], 0, 5) + " " + string_format(-v.positions[j][1], 0, 5) + " " + string_format(v.positions[j][2], 0, 5) + "\n");
			
			for( var j = 0; j < array_length(v.textures); j++ ) 
				file_text_write_string(fObj, "vt " + string_format(v.textures[j][0], 0, 5) + " " + string_format(1 - v.textures[j][1], 0, 5) + "\n");
			
			for( var j = 0; j < array_length(v.normals); j++ ) 
				file_text_write_string(fObj, "vn " + string(v.normals[j][0]) + " " + string(v.normals[j][1]) + " " + string(v.normals[j][2]) + "\n");
			
			var mtlName = "material_" + string(i);
			var mtlPath = filename_dir(mPath) + "/" + filename_name_only(oPath) + "_material_" + string(i) + ".png";
			
			file_text_write_string(fObj, "\nusemtl " + mtlName + "\n");
			file_text_write_string(fMtl, "newmtl " + mtlName + "\n");
			
			if(text) {
				file_text_write_string(fMtl, "map_Kd " + filename_name(mtlPath) + "\n");
				surface_save_safe(v.renderSurface, mtlPath);
			}
			
			for( var j = 0; j < array_length(v.faces); j += 3 ) {
				var f0 = v.faces[j + 0];
				var f1 = v.faces[j + 1];
				var f2 = v.faces[j + 2];
				
				file_text_write_string( fObj, "f " + string(_p + f0[0]) + "/" + string(_t + f0[2]) + "/" + string(_n + f0[1]) + " " + 
													 string(_p + f1[0]) + "/" + string(_t + f1[2]) + "/" + string(_n + f1[1]) + " " + 
													 string(_p + f2[0]) + "/" + string(_t + f2[2]) + "/" + string(_n + f2[1]) + " " + "\n"
									  );
			}
			
			_p += array_length(v.positions);
			_t += array_length(v.textures);
			_n += array_length(v.normals);
		}
		
		file_text_write_string(fObj, "\n");
		
		file_text_close(fObj);
		file_text_close(fMtl);

		if(!IS_CMD) {
			var noti = log_message("EXPORT", "Export obj as " + oPath, THEME.noti_icon_tick, COLORS._main_value_positive, false);
			noti.path = filename_dir(oPath);
			noti.setOnClick(function() { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
		}
	}
	
	static update = function() {
		export();
	}
}