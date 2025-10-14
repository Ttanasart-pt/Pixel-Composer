function __pack_file_strip(zip, path) {
	var _fname = filename_name(path);
	var _nname = "src/" + _fname;
	zip_add_file(zip, _nname, path);
					
	return _nname;
}

function exportPortable(project = PROJECT) {
	if(DEMO) return false;
	
	var path = get_save_filename_compat("Pixel Composer portable project (.zip)|*.zip", ""); 
	key_release();
	if(path == "") return false;
	
	var raw_name = filename_name_only(path);
	var raw_path = filename_path(path) + raw_name;
	
	var proj = project.serialize();
	var zip  = zip_create();
	
	for( var i = 0, n = array_length(proj.nodes); i < n; i++ )
	for( var j = 0, m = array_length(proj.nodes[i].inputs); j < m; j++ ) {
		var _input = proj.nodes[i].inputs[j];
		if(!has(_input, "r")) continue;
		
		var r = _input.r;
		for( var k = 0, o = array_length(r); k < o; k++ ) {
			var v = r[k][1];
			
			if(file_exists_empty(v))
				r[k][1] = __pack_file_strip(zip, v);
			
			if(is_array(v))
			for( var l = 0, p = array_length(v); l < p; l++ ) {
				if(file_exists_empty(v[l])) 
					r[k][1][l] = __pack_file_strip(zip, v[l]);
			}
		}
	}
	
	var ppath = $"{TEMPDIR}{raw_name}.pxc";
	var file  = file_text_open_write(ppath);
	
	file_text_write_string(file, PREFERENCES.save_file_minify? json_stringify_minify(proj) : json_stringify(proj, true));
	file_text_close(file);
	zip_add_file(zip, $"{raw_name}.pxc", ppath);
	zip_save(zip, $"{raw_path}.zip");
	
	log_message("EXPORT", $"Export package to {raw_path}.zip succeed.", THEME.noti_icon_file_save).setRef(filename_dir(raw_path));
}