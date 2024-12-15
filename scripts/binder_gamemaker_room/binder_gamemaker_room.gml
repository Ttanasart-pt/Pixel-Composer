function GMRoom(_gm, _rpth, _rawData) : GMObject(_gm, _rpth, _rawData) constructor {
	struct_append(serialize_keys, {
		effectEnabled:          __GM_FILE_DATATYPE.bool, 
		inheritSubLayers:       __GM_FILE_DATATYPE.bool, 
		inheritVisibility:      __GM_FILE_DATATYPE.bool, 
		visible:                __GM_FILE_DATATYPE.bool, 
		clearDisplayBuffer:     __GM_FILE_DATATYPE.bool, 
		inheritCode:            __GM_FILE_DATATYPE.bool, 
		inheritCreationOrder:   __GM_FILE_DATATYPE.bool, 
		inheritLayers:          __GM_FILE_DATATYPE.bool, 
		isDnd:                  __GM_FILE_DATATYPE.bool, 
		hierarchyFrozen:        __GM_FILE_DATATYPE.bool, 
		inheritLayerDepth:      __GM_FILE_DATATYPE.bool, 
		inheritLayerSettings:   __GM_FILE_DATATYPE.bool, 
		userdefinedDepth:       __GM_FILE_DATATYPE.bool, 
		htiled:                 __GM_FILE_DATATYPE.bool, 
		stretch:                __GM_FILE_DATATYPE.bool, 
		userdefinedAnimFPS:     __GM_FILE_DATATYPE.bool, 
		vtiled:                 __GM_FILE_DATATYPE.bool, 
		inheritPhysicsSettings: __GM_FILE_DATATYPE.bool, 
		PhysicsWorld:           __GM_FILE_DATATYPE.bool, 
		inheritRoomSettings:    __GM_FILE_DATATYPE.bool, 
		persistent:             __GM_FILE_DATATYPE.bool, 
		inherit:                __GM_FILE_DATATYPE.bool, 
		clearViewBackground:    __GM_FILE_DATATYPE.bool, 
		enableViews:            __GM_FILE_DATATYPE.bool, 
		inheritViewSettings:    __GM_FILE_DATATYPE.bool, 
	})
	
    layers = GMRoom_create_layers(self, gmBinder, raw.layers);
    roomSettings = raw.roomSettings;
    
    static link = function() { array_foreach(layers, function(l) /*=>*/ {return l.link()}); }
    
    static getLayerFromName = function(_name) {
    	for( var i = 0, n = array_length(layers); i < n; i++ ) {
    		var _r = layers[i].getLayerFromName(_name);
    		if(_r != noone) return _r;
    	}
    	return noone;
    }
    
    static sync = function() { 
	    var _keys = struct_get_names(raw);
	    array_sort(_keys, function(a, b) /*=>*/ {return string_compare(a, b)});
	    
	    var _str  = "{\n";
	    var _nl   = ",\n";
	    var _padd = "  ";
	    
	    for( var i = 0, n = array_length(_keys); i < n; i++ ) {
	    	var _k = _keys[i];
	    	var _v = raw[$ _k];
	    	
	    	var _snl = false;
	    	switch(_k) {
	    		case "parent" :
	    		case "physicsSettings" :
	    		case "roomSettings" :
	    		case "viewSettings" :
	    			_snl = true;
	    			break;
	    	}
	    	
	    	_str += _padd;
		    	if(is_array(_v) || is_struct(_v))  _str += $"\"{_k}\":{simple_serialize(_v, _padd, 0, _snl)}"; 
    			else _str += $"\"{_k}\":{formatPrimitive(_k, _v)}"; 
	    	_str += _nl;
	    }
	    
	    _str += "}"
	    
    	file_text_write_all(path, _str); 
    }
    
}

function GMRoom_create_layers(_room, _gm, layers) {
    var _l = [];
    
    for( var i = 0, n = array_length(layers); i < n; i++ ) {
        var _dat = layers[i];
        
        switch(_dat.resourceType) {
            case "GMRBackgroundLayer" : _l[i] = new GMRoom_Background( _room, _gm, _dat); break;
            case "GMRTileLayer"       : _l[i] = new GMRoom_Tile(       _room, _gm, _dat); break;
            case "GMRInstanceLayer"   : _l[i] = new GMRoom_Instance(   _room, _gm, _dat); break;
            case "GMRPathLayer"       : _l[i] = new GMRoom_Path(       _room, _gm, _dat); break;
            case "GMRAssetLayer"      : _l[i] = new GMRoom_Asset(      _room, _gm, _dat); break;
            case "GMREffectLayer"     : _l[i] = new GMRoom_Effect(     _room, _gm, _dat); break;
            default                   : _l[i] = new GMRoom_Layer(      _room, _gm, _dat); break;
        }
    }
    
    return _l;
}

function GMRoom_Layer(_room, _gm, _raw) constructor {
    gmBinder = _gm;
    room     = _room;
    raw      = _raw;
    name     = _raw.name;
    visible  = _raw.visible;
    depth    = _raw.depth;
    
    layers  = GMRoom_create_layers(_gm, _raw.layers);
    index   = 6;
    
    static link = function() { array_foreach(layers, function(l) /*=>*/ {return l.link()}); }
    
    static getLayerFromName = function(_name) {
    	if(name == _name) return self;
    	for( var i = 0, n = array_length(layers); i < n; i++ ) {
    		var _r = layers[i].getLayerFromName(_name);
    		if(_r != noone) return _r;
    	}
    	return noone;
    }
}

function GMRoom_Background(_room, _gm, _raw) : GMRoom_Layer(_room, _gm, _raw) constructor {
    index  = 0;
    
    x = raw.x;
    y = raw.y;
    
    colour = raw.colour;
}

function GMRoom_Tile(_room, _gm, _raw) : GMRoom_Layer(_room, _gm, _raw) constructor {
    index  = 1;
    
    x = raw.x;
    y = raw.y;
    
    tiles     = raw.tiles;
    tilesetId = raw.tilesetId;
    tileset   = noone;
    
    amount_w  = tiles.SerialiseWidth;
	amount_h  = tiles.SerialiseHeight;
	
	static link = function() { 
		tileset = gmBinder.getResourceFromPath(struct_try_get(tilesetId, "path", ""));
		array_foreach(layers, function(l) /*=>*/ {return l.link()});
	}
}

function GMRoom_Instance(_room, _gm, _raw) : GMRoom_Layer(_room, _gm, _raw) constructor { index = 2; }
function GMRoom_Path(_room, _gm, _raw)     : GMRoom_Layer(_room, _gm, _raw) constructor { index = 3; }
function GMRoom_Asset(_room, _gm, _raw)    : GMRoom_Layer(_room, _gm, _raw) constructor { index = 4; }
function GMRoom_Effect(_room, _gm, _raw)   : GMRoom_Layer(_room, _gm, _raw) constructor { index = 5; }
