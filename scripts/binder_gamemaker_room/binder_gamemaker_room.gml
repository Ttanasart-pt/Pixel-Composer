function GMRoom(_gm, _path, _info) : GMObject(_gm, _path, _info) constructor {
    layers = GMRoom_create_layers(raw.layers);
    
    roomSettings = raw.roomSettings;
}

function GMRoom_create_layers(layers) {
    var _l = [];
    
    for( var i = 0, n = array_length(layers); i < n; i++ ) {
        var _dat = layers[i];
        
        switch(_dat.resourceType) {
            case "GMRBackgroundLayer" : _l[i] = new GMRoom_Background(_dat); break;
            case "GMRTileLayer"       : _l[i] = new GMRoom_Tile(_dat);       break;
            case "GMRInstanceLayer"   : _l[i] = new GMRoom_Instance(_dat);   break;
            case "GMRPathLayer"       : _l[i] = new GMRoom_Path(_dat);       break;
            case "GMRAssetLayer"      : _l[i] = new GMRoom_Asset(_dat);      break;
            case "GMREffectLayer"     : _l[i] = new GMRoom_Effect(_dat);     break;
            default                   : _l[i] = new GMRoom_Layer(_dat);      break;
        }
    }
    
    return _l;
}

function GMRoom_Layer(_raw) constructor {
    name    = _raw.name;
    visible = _raw.visible;
    depth   = _raw.depth;
    layers  = GMRoom_create_layers(_raw.layers);
    
    index   = 6;
}

function GMRoom_Background(_raw) : GMRoom_Layer(_raw) constructor {
    index  = 0;
    
    x = _raw.x;
    y = _raw.y;
    
    colour = _raw.colour;
}

function GMRoom_Tile(_raw) : GMRoom_Layer(_raw) constructor {
    index  = 1;
    
    x = _raw.x;
    y = _raw.y;
    
    tiles     = _raw.tiles;
    tilesetId = _raw.tilesetId;
}

function GMRoom_Instance(_raw) : GMRoom_Layer(_raw) constructor { index = 2; }
function GMRoom_Path(_raw)     : GMRoom_Layer(_raw) constructor { index = 3; }
function GMRoom_Asset(_raw)    : GMRoom_Layer(_raw) constructor { index = 4; }
function GMRoom_Effect(_raw)   : GMRoom_Layer(_raw) constructor { index = 5; }
