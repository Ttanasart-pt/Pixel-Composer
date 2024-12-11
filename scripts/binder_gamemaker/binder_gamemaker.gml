function Binder_Gamemaker(path) {
    if(!file_exists_empty(path))     return noone;
    if(filename_ext(path) != ".yyp") return noone;
    
    return new __Binder_Gamemaker(path);
}

function GMObject(_gm, _path, _info) constructor {
    gmBinder  = _gm;
    path      = $"{_gm.dir}/{_path}";
    key       = _path;
    raw       = _info;
    type      = _info.resourceType;
    thumbnail = noone;
}

function GMSprite(_gm, _path, _info) : GMObject(_gm, _path, _info) constructor {
    var _dirr   = filename_dir(path);
    var _frame  = raw.frames;
    var _layers = raw.layers;
    
    thumbnailPath = "";
    if(array_empty(_frame) || array_empty(_layers)) return;
    
    thumbnailPath = $"{_dirr}/layers/{_frame[0].name}/{_layers[0].name}.png";
    if(file_exists(thumbnailPath))
        thumbnail = sprite_add(thumbnailPath, 0, 0, 0, 0, 0);
}

function GMTileset(_gm, _path, _info) : GMObject(_gm, _path, _info) constructor {
    sprite    = raw.spriteId.path;
} 

function __Binder_Gamemaker(path) constructor {
    self.path   = path;
    name        = filename_name_only(path);
    dir         = filename_dir(path);
    projectName = "";
    
    resourcesRaw = [];
    resourcesMap = {};
    resources    = [
        { name: "sprites", data : [], closed : false, },
        { name: "tileset", data : [], closed : false, },
        { name: "rooms",   data : [], closed : false, },
    ];
    
    static readYY = function(path) {
        var _res = file_read_all(path);
        var _resMap = json_try_parse(_res, -1);
        
        if(_resMap == -1) return noone;
        return _resMap;
    }
    
    static refreshResources = function() {
        if(!file_exists(path)) return;
        
        var _res    = file_read_all(path);
        var _resMap = json_try_parse(_res, -1);
        
        if(_resMap == -1) return;
        
        projectName  = _resMap.name;
        resourcesRaw = _resMap.resources;
        resourcesMap = {};
        
        var sprites = [];
        var tileset = [];
        var rooms   = [];
        
        for( var i = 0, n = array_length(resourcesRaw); i < n; i++ ) {
            var _res  = resourcesRaw[i].id;
            var _name = _res.name;
            var _path = _res.path;
            
            var _info = readYY($"{dir}/{_path}");
            if(_info == noone) continue;
            
            var _asset = noone;
            
            switch(_info.resourceType) {
                case "GMSprite":  _asset = new GMSprite(self, _path, _info);  array_push(sprites, _asset); break;
                case "GMTileSet": _asset = new GMTileset(self, _path, _info); array_push(tileset, _asset); break;
                case "GMRoom":    _asset = new GMRoom(self, _path, _info);    array_push(rooms,   _asset); break;
            }
            
            resourcesMap[$ _path] = _asset;
        }
        
        resources[0].data = sprites;
        resources[1].data = tileset;
        resources[2].data = rooms;
    } 
    
    refreshResources();
}