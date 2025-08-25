function krita_file() constructor {
	preview_sprite  = noone;
	data   = noone;
	layers = [];
	
	static destroy = function() {
		sprite_delete_safe(preview_sprite);
	}
}

function read_kra(_path) {
	var _content = new krita_file();
	var _fname   = filename_name_only(_path);
	
	var _temp_dir = $"{TEMPDIR}{_fname}";
	directory_verify(_temp_dir);
	zip_unzip(_path, _temp_dir);
	
	var _path_prev = filename_combine(_temp_dir, "preview.png");
	if(file_exists(_path_prev))
		_content.preview_sprite = sprite_add(_path_prev);
	
	var _path_maindoc = filename_combine(_temp_dir, "maindoc.xml");
	if(file_exists(_path_maindoc))
		_content.data = xml_read_file(_path_maindoc);
	
	print(_content.data);
	
	var _data_dir  = filename_combine(_temp_dir, _fname);
	var _layer_dir = filename_combine(_data_dir, "layers");
	
	if(directory_exists(_layer_dir)) {
		
	}
	
	return _content;
}