function __Bone_Constrain(_bone) constructor {
    name = "Constrain";
    bone = _bone;
    draw_height = 0;
    node = noone;
    
    static init      = function() {}
    static constrain = function() {}
    
    static draw_inspector = function(_x, _y, _w, _m, _hover, _focus, _drawParam) { return 0; }
    
    static build = function(type, _bid = "") { 
    	
    	var _const = asset_get_index(type);
    	if(is_callable(_const)) return new _const(bone, _bid);
    	
        switch(type) {
            case "Copy Position"  : return new __Bone_Constrain_Copy_Position(bone, _bid);
			case "Copy Rotation"  : return new __Bone_Constrain_Copy_Rotation(bone, _bid);
			case "Copy Scale"     : return new __Bone_Constrain_Copy_Scale(bone, _bid);
			
            case "Look At" :        return new __Bone_Constrain_Look_At(bone, _bid);
            case "Move To" :        return new __Bone_Constrain_Move_To(bone, _bid);
			case "Stretch To"     : return noone;//new __Bone_Constrain_Stretch_To(bone, _bid);
			
			case "Limit Rotation" : return new __Bone_Constrain_Limit_Rotation(bone, _bid);
        }
        return noone;
    }
    
    static onSerialize   = function(_map) /*=>*/ {}
    static serialize   = function() { 
    	var _map = {};
    	_map.type = instanceof(self);
    	onSerialize(_map);
    	
    	return _map; 
    }
    
    static deserialize = function(_map) { 
    	var c = build(_map.type); 
    	return c == noone? c : c.deserialize(_map); 
    }
}