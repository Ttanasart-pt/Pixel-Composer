function GMRoom_Tile(_room, _gm, _raw) : GMRoom_Layer(_room, _gm, _raw) constructor {
    index  = 1;
    
    tiles     = raw.tiles;
    tilesetId = raw.tilesetId;
    tileset   = noone;
    
	static link = function() { 
		tileset = gmBinder.getResourceFromPath(struct_try_get(tilesetId, "path", ""));
		array_foreach(layers, function(l) /*=>*/ {return l.link()});
	}
	
	static doRefreshPreview = function() {
		
	}
	
	static setArray = function(arr) {
	    var _ww = tiles.SerialiseWidth;
	    var _hh = tiles.SerialiseHeight;
	    arr = array_verify(arr, _ww * _hh);
	    
	    var _ctil = [];
		var _type = arr[0];
		var _runn = 1;
		
		for( var j = 1, m = array_length(arr); j < m; j++ ) {
			if(arr[j] == _type) _runn++
			else {
				array_push(_ctil, -_runn, _type);
				_type = arr[j];
				_runn = 1;
			}
		}
		
		array_push(_ctil, -_runn, _type);
		
		if(array_length(_ctil) < array_length(arr)) {
			tiles.TileCompressedData = _ctil;
			tiles.TileDataFormat     = 1;
			
		} else {
			tiles.TileSerialiseData = arr;
			struct_remove(tiles, "TileDataFormat");
		}
	}
	
	static resizeBBOX = function(bbox) {
	    var _form = struct_try_get(tiles, "TileDataFormat", 0);
	    
	    var _ow = tiles.SerialiseWidth;
	    var _oh = tiles.SerialiseHeight;
	    
		var _nw =  bbox[2] - bbox[0];
		var _nh =  bbox[3] - bbox[1];
		var _dx = -bbox[0];
		var _dy = -bbox[1];
		
		var _grdo = ds_grid_create(_ow, _oh);
		var _grdn = ds_grid_create(_nw, _nh);
		var _data;
		
		if(_form == 0) {
			_data = tiles.TileSerialiseData;
			
		} else if(_form == 1) {
			var _d = tiles.TileCompressedData;
			var _amo, _til, _i = 0;
			
			for( var i = 0, n = array_length(_d); i < n; i += 2 ) {
				_amo = -_d[i + 0];
				_til =  _d[i + 1];
				_til = max(0, _til + bool(_til));
				
				repeat(_amo) _data[_i++] = _til;
			}
		}
        
        var _i = 0;
        for( var i = 0; i < _oh; i++ )
        for( var j = 0; j < _ow;  j++ )
		    ds_grid_set(_grdo, j, i, _data[_i++]);
    
        ds_grid_set_grid_region(_grdn, _grdo, max(-_dx, 0), max(-_dy, 0), _ow - 1, _oh - 1, max(_dx, 0), max(_dy, 0));
        
        var _dn = array_create(_nw * _nh);
        var _i  = 0;
        
        for( var i = 0; i < _oh; i++ )
        for( var j = 0; j < _ow; j++ )
            _dn[i++] = ds_grid_get(_grdn, j, i);
            
		ds_grid_destroy(_grdo);
		ds_grid_destroy(_grdn);
		
		tiles.SerialiseWidth  = _nw;
        tiles.SerialiseHeight = _nh;
		setArray(_dn);
	}
}
