function GMRoom(_gm, _rpth, _rawData) : GMAsset(_gm, _rpth, _rawData) constructor {
	static serialize_bool_keys = {
		clearDisplayBuffer: 1,
		clearViewBackground: 1,
		effectEnabled: 1,
		enableViews: 1,
		frozen: 1,
		hasCreationCode: 1,
		hierarchyFrozen: 1,
		htiled: 1,
		ignore: 1,
		inherit: 1,
		inheritCode: 1,
		inheritCreationOrder: 1,
		inheritItemSettings: 1,
		inheritLayerDepth: 1,
		inheritLayers: 1,
		inheritLayerSettings: 1,
		inheritPhysicsSettings: 1,
		inheritRoomSettings: 1,
		inheritSubLayers: 1,
		inheritViewSettings: 1,
		inheritVisibility: 1,
		isDnd: 1,
		persistent: 1,
		PhysicsWorld: 1,
		stretch: 1,
		userdefinedAnimFPS: 1,
		userdefinedDepth: 1,
		visible: 1,
		vtiled: 1,
	};
	
	roomSettings = raw.roomSettings;
    layers = GMRoom_create_layers(self, gmBinder, raw.layers);
    
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
	    
	    for( var i = 0, n = array_length(_keys); i < n; i++ ) {
	    	var _k = _keys[i];
	    	var _v = raw[$ _k];
	    	
	    	_str += $"  \"{_k}\":{simple_serialize(_k, _v)}{_nl}"; 
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
    gmBinder   = _gm;
    roomObject = _room;
    raw        = _raw;
    name       = _raw.name;
    visible    = _raw.visible;
    depth      = _raw.depth;
    
    layers     = GMRoom_create_layers(roomObject, _gm, _raw.layers);
    index      = 6;
    preview    = noone;
    
    static link = function() { array_foreach(layers, function(l) /*=>*/ {return l.link()}); }
    
    static getLayerFromName = function(_name) {
    	if(name == _name) return self;
    	for( var i = 0, n = array_length(layers); i < n; i++ ) {
    		var _r = layers[i].getLayerFromName(_name);
    		if(_r != noone) return _r;
    	}
    	return noone;
    }

	static refreshPreview = function() {
		preview = surface_verify(preview, roomObject.roomSettings.Width, roomObject.roomSettings.Height);
		surface_set_target(preview);
			DRAW_CLEAR
			doRefreshPreview();
		surface_reset_target();
	}
	
	static doRefreshPreview = function() {}
}

function GMRoom_Background(_room, _gm, _raw) : GMRoom_Layer(_room, _gm, _raw) constructor {
    index  = 0;
    spr    = noone;
    
	static link = function() { 
		spr = gmBinder.getResourceFromPath(struct_try_get(raw.spriteId, "path"));
	}
	
    static doRefreshPreview = function() {
		if(spr != noone && spr.thumbnail != noone) {
			if(raw.htiled || raw.vtiled)
				draw_sprite_tiled(spr.thumbnail, 0, 0, 0);
			else 
				draw_sprite(spr.thumbnail, 0, 0, 0);
		}
	}
}

function GMRoom_Instance(_room, _gm, _raw) : GMRoom_Layer(_room, _gm, _raw) constructor { 
	index = 2; 
	instances = [];
	
	static link = function() { 
		instances = [];
		
		for( var i = 0, n = array_length(raw.instances); i < n; i++ ) {
			var _ins = raw.instances[i];
			var _obj = _ins.objectId;
			var _o   = gmBinder.getResourceFromPath(struct_try_get(_obj, "path"));
			
			instances[i] = {
				object: _o,
				data: _ins,
			};
		}
	}
	
	static doRefreshPreview = function() {
		for( var i = 0, n = array_length(instances); i < n; i++ ) {
			var _ins = instances[i];
			var _obj = _ins.object;
			var _dat = _ins.data;
			if(_obj == noone) continue;
			
			var _spr = _obj.spriteObject;
			if(_spr == noone) continue;
			
			var _thm    = _spr.thumbnail;
			var _thm_w  = _spr.raw.width;
			var _thm_h  = _spr.raw.height;
			var _thm_ox = _spr.raw.sequence.xorigin;
			var _thm_oy = _spr.raw.sequence.yorigin;
			
			var _pos_x = _dat.x;
			var _pos_y = _dat.y;
			var _sca_x = _dat.scaleX;
			var _sca_y = _dat.scaleY;
			var _rot   = _dat.rotation;
			var _col   = _dat.colour;
			
			var _rx = _pos_x - _thm_ox * _sca_x;
			var _ry = _pos_y - _thm_oy * _sca_y;
			
			draw_sprite_ext(_thm, 0, _rx, _ry, _sca_x, _sca_y, _rot, _col);
		}
	}
}

function GMRoom_Path(_room, _gm, _raw)     : GMRoom_Layer(_room, _gm, _raw) constructor { 
	index = 3; 
	
	static doRefreshPreview = function() {
		
	}
}

function GMRoom_Asset(_room, _gm, _raw)    : GMRoom_Layer(_room, _gm, _raw) constructor { 
	index = 4; 
	assets = [];
	
	static link = function() { 
		assets = [];
		
		for( var i = 0, n = array_length(raw.assets); i < n; i++ ) {
			var _ass = raw.assets[i];
			var _spr = _ass.spriteId;
			var _o   = gmBinder.getResourceFromPath(struct_try_get(_spr, "path"));
			
			assets[i] = {
				object: _o,
				data: _ass,
			};
		}
	}
	
	static doRefreshPreview = function() {
		for( var i = 0, n = array_length(assets); i < n; i++ ) {
			var _ass = assets[i];
			var _spr = _ass.object;
			var _dat = _ass.data;
			
			var _thm    = _spr.thumbnail;
			var _thm_w  = _spr.raw.width;
			var _thm_h  = _spr.raw.height;
			var _thm_ox = _spr.raw.sequence.xorigin;
			var _thm_oy = _spr.raw.sequence.yorigin;
			
			var _pos_x = _dat.x;
			var _pos_y = _dat.y;
			var _sca_x = _dat.scaleX;
			var _sca_y = _dat.scaleY;
			var _rot   = _dat.rotation;
			var _col   = _dat.colour;
			
			var _rx = _pos_x - _thm_ox * _sca_x;
			var _ry = _pos_y - _thm_oy * _sca_y;
			
			draw_sprite_ext(_thm, 0, _rx, _ry, _sca_x, _sca_y, _rot, _col);
		}
	}
}

function GMRoom_Effect(_room, _gm, _raw)   : GMRoom_Layer(_room, _gm, _raw) constructor { 
	index = 5; 
	
	static doRefreshPreview = function() {
		
	}
}

