enum __GM_FILE_DATATYPE {
    float,
    integer,
    bool,
    string,
}

function Binder_Gamemaker(path) {
    if(!file_exists_empty(path))     return noone;
    if(filename_ext(path) != ".yyp") return noone;
    
    return new __Binder_Gamemaker(path);
}

function GMObject(_gm, _rpth, _rawData) constructor {
    static serialize_bool_keys = {};
    
    gmBinder  = _gm;
    path      = $"{_gm.dir}/{_rpth}";
    key       = _rpth;
    raw       = _rawData;
    name      = raw.name;
    type      = raw.resourceType;
    thumbnail = noone;
    
    static formatPrimitive = function(key, val) {
        if(is_undefined(val)) return "null";
        if(is_string(val))    return $"\"{val}\"";
        
        if(struct_has(serialize_bool_keys, key)) return bool(val)? "true" : "false";
        return string(val);
    }
    
    static simple_serialize = function(s, _pad, _depth = 0, _nline = false) {
        if(is_array(s)) {
            if(array_empty(s)) return "[]";
            var _d1 = _depth <= 1;
            var _str  = _d1? "[\n" : "[";
            var _nl   = _d1? ",\n" : ",";
            var _padd = _d1? _pad + "  " : "";
            
            for( var i = 0, n = array_length(s); i < n; i++ )
                _str += $"{_padd}{simple_serialize(s[i], _pad, _depth + 1)}{_nl}";
            
            _str += _d1? _pad + "]" : "]";
            return _str;
            
        } else if(is_struct(s)) {
            var _keys = struct_get_names(s);
    	    array_sort(_keys, function(a, b) /*=>*/ {return string_compare(a, b)});
    	    
    	    var _str  = _nline? "{\n" : "{";
    	    var _nl   = _nline? ",\n" : ",";
    	    var _padd = _nline? _pad + "  " : "";
    	    
    	    for( var i = 0, n = array_length(_keys); i < n; i++ ) {
    	    	var _k = _keys[i];
    	    	var _v = s[$ _k];
    	    	
    	    	_str += _padd;
    	    	_str += $"\"{_k}\":{is_array(_v) || is_struct(_v)? simple_serialize(_v, _padd, _depth + 1) : formatPrimitive(_k, _v)}";
    	    	_str += _nl;
    	    }
    	    
    	    _str += _pad + "}"
    	    return _str;
        }
        
        return formatPrimitive("", s);
    }
    
    static sync = function() { file_text_write_all(path, json_stringify(raw)); }
    
    static link = function() {}
}

function GMSprite(_gm, _rpth, _rawData) : GMObject(_gm, _rpth, _rawData) constructor {
    var _dirr   = filename_dir(path);
    var _frame  = raw.frames;
    var _layers = raw.layers;
    
    thumbnailPath = "";
    if(array_empty(_frame) || array_empty(_layers)) return;
    
    thumbnailPath = $"{_dirr}/layers/{_frame[0].name}/{_layers[0].name}.png";
    if(file_exists(thumbnailPath))
        thumbnail = sprite_add(thumbnailPath, 0, 0, 0, 0, 0);
}

function GMTileset(_gm, _rpth, _rawData) : GMObject(_gm, _rpth, _rawData) constructor {
    sprite    = raw.spriteId.path;
    
    static link = function() {
        spriteObject = gmBinder.getResourceFromPath(sprite);
    }
} 

function __Binder_Gamemaker(path) constructor {
    self.path   = path;
    name        = filename_name_only(path);
    dir         = filename_dir(path);
    projectName = "";
    
    resourcesRaw = [];
    resourcesMap = {};
    resourceList = [];
    resources    = [
        { name: "sprites", data : [], closed : false, },
        { name: "tileset", data : [], closed : false, },
        { name: "rooms",   data : [], closed : false, },
    ];
    
    nodeMap = {};
    
    static getResourceFromPath = function(path) { return struct_try_get(resourcesMap, path, noone); }
    
    static getNodeFromPath = function(path, _x, _y) {
        if(struct_has(nodeMap, path)) return nodeMap[$ path];
        
        var _n = nodeBuild("Node_Tile_Tileset", _x, _y).skipDefault();
	    nodeMap[$ path] = _n;
	    
	    return _n;
    }
    
    static readYY = function(path) {
        var _res = file_read_all(path);
        var _map = json_try_parse(_res, noone);
        return _map;
    }
    
    static refreshResources = function() {
        if(!file_exists(path)) return;
        
        var _resMap = readYY(path);
        if(_resMap == noone) return;
        
        projectName  = _resMap.name;
        resourcesRaw = _resMap.resources;
        resourcesMap = {};
        
        var sprites = [];
        var tileset = [];
        var rooms   = [];
        
        for( var i = 0, n = array_length(resourcesRaw); i < n; i++ ) {
            var _res  = resourcesRaw[i].id;
            var _name = _res.name;
            var _rpth = _res.path;
            
            var _rawData = readYY($"{dir}/{_rpth}");
            if(_rawData == noone) continue;
            
            var _asset = noone;
            
            switch(_rawData.resourceType) {
                case "GMSprite":  _asset = new GMSprite( self, _rpth, _rawData); array_push(sprites, _asset); break;
                case "GMTileSet": _asset = new GMTileset(self, _rpth, _rawData); array_push(tileset, _asset); break;
                case "GMRoom":    _asset = new GMRoom(   self, _rpth, _rawData); array_push(rooms,   _asset); break;
            }
            
            resourcesMap[$ _rpth] = _asset;
            array_push(resourceList, _asset);
        }
        
        for( var i = 0, n = array_length(resourceList); i < n; i++ ) {
            resourceList[i].link();
        }
        
        resources[0].data = sprites;
        resources[1].data = tileset;
        resources[2].data = rooms;
    }
    
    refreshResources();
}