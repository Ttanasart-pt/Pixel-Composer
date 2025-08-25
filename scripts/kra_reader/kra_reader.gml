function Krita_File() constructor {
	preview_sprite  = noone;
	rawdata     = noone;
	metadata    = noone;
	animdata    = noone;
	
	layerRaw = [];
	layerDat = [];
	
	static destroy = function() {
		sprite_delete_safe(preview_sprite);
		
		for( var i = 0, n = array_length(layerDat); i < n; i++ ) {
			var _l = layerDat[i];
			buffer_delete_safe(_l[2]);
		}
	}
}

function read_kra(_path) {
	var _content = new Krita_File();
	var _fname   = filename_name_only(_path);
	
	var _temp_dir = $"{TEMPDIR}{_fname}";
	directory_verify(_temp_dir);
	zip_unzip(_path, _temp_dir);
	
	var _path_prev = filename_combine(_temp_dir, "mergedimage.png");
	if(file_exists(_path_prev))
		_content.preview_sprite = sprite_add(_path_prev);
	
	var _path_maindoc = filename_combine(_temp_dir, "maindoc.xml");
	if(!file_exists(_path_maindoc)) return _content;
	
	var _xmlRaw = xml_read_file(_path_maindoc)[0];
	_content.rawdata  = _xmlRaw;
	
	var _xmlDat = _xmlRaw.children[0].children[0];
	_content.metadata = _xmlDat.attributes;
	
	for( var i = 0, n = array_length(_xmlDat.children); i < n; i++ ) {
		var _ch = _xmlDat.children[i];
		if(_ch.type == "layers")    _content.layerRaw = _ch.children;
		if(_ch.type == "animation") _content.animdata = _ch.children;
	}
	
	var _data_dir  = filename_combine(_temp_dir, _fname);
	var _layer_dir = filename_combine(_data_dir, "layers");
	
	if(!directory_exists(_layer_dir)) return _content;
		
	for( var i = 0, n = array_length(_content.layerRaw); i < n; i++ ) {
		var _ly = _content.layerRaw[i].attributes;
		var _fname = _ly.filename;
		var _lname = _ly.name;
		
		var _fpath = filename_combine(_layer_dir, _fname);
		if(!file_exists(_fpath)) continue;
		
		_content.layerDat[i] = {
			name : _lname, 
			data : read_kra_layer_pixel(_fpath), 
		}
	}
	
	return _content;
}

function buffer_read_line(buf) {
	var line = "";
	while (true) {
        var cr = chr(buffer_read(buf, buffer_u8));
        if(cr == "\n") return line;
        else line += cr;
	}
	
	return line;
}

function read_kra_layer_pixel(_fname) {
    var buf = buffer_load(_fname);
    buffer_seek(buf, buffer_seek_start, 0);

    // headers
    var header_lines = [];
    while (true) {
        var line = buffer_read_line(buf);
        array_push(header_lines, line);
    	if (string_pos("DATA", line)) break;
    }
    
    // metadata
    var tile_w  = real(string_delete(header_lines[1], 1, 10)); // "TILEWIDTH "
    var tile_h  = real(string_delete(header_lines[2], 1, 11)); // "TILEHEIGHT "
    var px_size = real(string_delete(header_lines[3], 1, 10)); // "PIXELSIZE "

    var tile_count = real(string_delete(header_lines[array_length(header_lines)-1], 1, 5)); // "DATA "

    // tiles
    var tiles = [];
    for (var i = 0; i < tile_count; i++) {
        var desc  = buffer_read_line(buf);
        var parts = string_split(desc, ",");
        var tx    = real(parts[0]);
        var ty    = real(parts[1]);
        var codec = parts[2]; // LZF
        var size  = real(parts[3]);

		var iscm = buffer_read(buf, buffer_u8); size--;
		
		if(iscm == 1) {
	        var comp = buffer_create(size, buffer_fixed, 1);
	        buffer_copy(buf, buffer_tell(buf), size, comp, 0);
	        buffer_seek(buf, buffer_seek_relative, size);
			
	        var rgba_buf = lzf_decompress_buffer(comp, tile_w * tile_h * px_size);
			
        	array_push(tiles, [tx, ty, rgba_buf]);
        	buffer_delete(comp);
		}
		
    }

    var tileData = array_create(array_length(tiles));
    
    for( var t = 0, n = array_length(tiles); t < n; t++ ) {
        var tx = tiles[t][0];
        var ty = tiles[t][1];
        var bf = tiles[t][2];
        var buffer = buffer_create(tile_w * tile_h * px_size, buffer_u8, 1);

        for (var py = 0; py < tile_h; py++)
        for (var px = 0; px < tile_w; px++) {
            var idx = py * tile_w + px;
            
            var b = buffer_peek( bf, tile_w * tile_h * 0 + idx, buffer_u8 );
            var g = buffer_peek( bf, tile_w * tile_h * 1 + idx, buffer_u8 );
            var r = buffer_peek( bf, tile_w * tile_h * 2 + idx, buffer_u8 );
            var a = buffer_peek( bf, tile_w * tile_h * 3 + idx, buffer_u8 );
			
			buffer_write_at(buffer, idx * 4 + 0, buffer_u8, r);
			buffer_write_at(buffer, idx * 4 + 1, buffer_u8, g);
			buffer_write_at(buffer, idx * 4 + 2, buffer_u8, b);
			buffer_write_at(buffer, idx * 4 + 3, buffer_u8, a);
        }
        
        tileData[t] = [ tx, ty, buffer ];
        
        buffer_delete(bf);
    }

    return [ tile_w, tile_h, tileData ];
}

function lzf_decompress_buffer(buf_in, maxout) {
    var oBuf = buffer_create(maxout, buffer_grow, 1);
    var size = buffer_get_size(buf_in);
    
    var rSize = lzff_decompress(buffer_get_address(buf_in), size, buffer_get_address(oBuf), maxout);
    buffer_resize(oBuf, rSize);
    
    return oBuf;
}