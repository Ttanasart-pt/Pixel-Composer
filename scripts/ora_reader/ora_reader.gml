function ORA_File() constructor {
	preview_sprite  = noone;
	rawdata     = noone;
	metadata    = noone;
	layerData   = [];
	
	static destroy = function() {
		sprite_delete_safe(preview_sprite);
		
		for( var i = 0, n = array_length(layerData); i < n; i++ ) {
			var _l = layerData[i];
			sprite_delete_safe(_l.spr);
		}
	}
}

function read_ora(_path) {
	var _content = new ORA_File();
	var _fname   = filename_name_only(_path);
	
	var _temp_dir = $"{TEMPDIR}{_fname}";
	directory_verify(_temp_dir);
	zip_unzip(_path, _temp_dir);
	
	var _path_prev = filename_combine(_temp_dir, "mergedimage.png");
	if(file_exists(_path_prev))
		_content.preview_sprite = sprite_add(_path_prev);
	
	var _path_maindoc = filename_combine(_temp_dir, "stack.xml");
	if(!file_exists(_path_maindoc)) return _content;
	
	var _xmlRaw = xml_read_file(_path_maindoc)[0];
	_content.rawdata = _xmlRaw;
	
	var _data = _xmlRaw.children[0];
	_content.metadata = _data.attributes;
	
	var _stac = _data.children[0];
	
	var _layerData = [];
	for( var i = 0, n = array_length(_stac.children); i < n; i++ ) {
		var _l = _stac.children[i];
		_layerData[i] = _l;
		
		var _type = _l.type;
		var _attr = _l.attributes;
		if(_type != "layer") continue;
		
		_l.name = _attr.name;
		_l.spr  = noone;
		_l.x    = _attr.x;
		_l.y    = _attr.y;
		
		var _src  = _attr.src;
		var _psrc = filename_combine(_temp_dir, _src);
		
		if(!file_exists_empty(_psrc)) continue;
		
		_l.spr = sprite_add(_psrc);
	}
	
	_content.layerData = _layerData;
	
	return _content;
}