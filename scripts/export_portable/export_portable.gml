function __pack_file_strip(zip, path) {
	var _fname = filename_name(path);
	var _nname = "src/" + _fname;
	zip_add_file(zip, _nname, path);
					
	return _nname;
}

function exportPortable(project = PROJECT) {
	if(DEMO) return false;
	
	var path = get_save_filename("Pixel Composer portable project (.zip)|*.zip", ""); 
	key_release();
	if(path == "") return false;
	
	var raw_name = filename_name_only(path);
	var raw_path = filename_path(path) + raw_name;
	var _proj    = save_serialize(project, true);
	
	var zip = zip_create();
	
	for( var i = 0, n = array_length(_proj.nodes); i < n; i++ ) {
		var _node = _proj.nodes[i];
		
		for( var j = 0, m = array_length(_node.inputs); j < m; j++ ) {
			var _input = _node.inputs[j];
			
			for( var k = 0, o = array_length(_input.raw_value); k < o; k++ ) {
				var _val = _input.raw_value[k][1];
				
				if(is_string(_val) && file_exists(_val))
					_input.raw_value[k][1] = __pack_file_strip(zip, _val);
				else if(is_array(_val)) {
					for( var l = 0, p = array_length(_val); l < p; l++ ) {
						if(is_string(_val[l]) && file_exists(_val[l]))
							_input.raw_value[k][1][l] = __pack_file_strip(zip, _val[l]);	
					}
				}
			}
		}
	}
	
	var pro_path = DIRECTORY + "temp/" + raw_name + ".pxc";
	var file = file_text_open_write(pro_path);
	file_text_write_string(file, PREF_MAP[? "save_file_minify"]? json_stringify_minify(_proj) : json_stringify(_proj, true));
	file_text_close(file);
	zip_add_file(zip, raw_name + ".pxc", pro_path);
	zip_save(zip, raw_path + ".zip");
	
	log_message("EXPORT", $"Export package to {raw_path}.zip succeed.", THEME.noti_icon_file_save);
}