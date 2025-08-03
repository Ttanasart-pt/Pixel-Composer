function __Bone_Constrain_Limit_Scale(_bone, _bid = "") : __Bone_Constrain(_bone) constructor {
    name      = "Limit Scale";
    sindex    = 8;
    bone_id   = _bid;
    limit_min = 0;
    limit_max = 0;
    
    lock_children = true;
    bone_object   = noone;
    
    tb_limit = new vectorBox(2, function(v, i) /*=>*/ { 
             if(i == 0) limit_min = v; 
        else if(i == 1) limit_max = v; 
        node.triggerRender(); 
    });
        
    tb_limit.axis = ["min", "max"];
    tb_limit.boxColor = COLORS._main_icon_light;
    
    cb_lock = new checkBox(function() /*=>*/ { lock_children = !lock_children; node.triggerRender(); });
    
    ////- Actions
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static preConstrain = function(_b) {
        if(!lock_children) return;
        
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        _bone.pose_scale = clamp(_bone.pose_scale, limit_min, limit_max);
    }
    
    static constrain = function(_b) {
        if(lock_children) return;
        
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        _bone.pose_length = _bone.length * clamp(_bone.pose_apply_scale, limit_min, limit_max);
    }
    
    ////- Draw
    
    static drawInspector = function(_x, _y, _w, _m, _hover, _focus, _drawParam) { 
        var wh = 0;
        
        // draw bones
        var _wdx = _x + ui(8);
        var _wdw = _w - ui(16);
        var _wdh = ui(24);
        draw_sprite_stretched_ext(THEME.textbox, 3, _wdx, _y, _wdw, _wdh, COLORS._main_icon_light, 1);
        
        if(bone_object != noone) {
            var _bname = bone_object.name;
            
            draw_sprite_ui(THEME.bone, 1, _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, 1);
            draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
            draw_text_add(_wdx + ui(32), _y + _wdh / 2, _bname);
            
        } else
            draw_sprite_ui(THEME.bone, 1, _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, .5);
        
        if(_hover && point_in_rectangle(_m[0], _m[1], _wdx, _y, _wdx + _wdw, _y + _wdh)) {
            draw_sprite_stretched_ext(THEME.textbox, 1, _wdx, _y, _wdw, _wdh, c_white, 1);
            if(mouse_click(mb_left, _focus))
                node.boneSelector(function(p) /*=>*/ { bone_id = p.bone.ID; init(); node.triggerRender(); })
        }
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        // draw widget
        var _lbx = _x + ui(16);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Range"));
        
        var _wdw = _w * 2/3;
        var _wdx = _x + _w - _wdw - ui(8);
        var _wdh = ui(24);
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, [ limit_min, limit_max ], {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_limit.drawParam(_dParam);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Inherit"));
        
        _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, lock_children, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        _dParam.s = _wdh;
        _dParam.halign = fa_center;
        cb_lock.drawParam(_dParam);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    ////- Serialize
    
    static onSerialize = function(_map) { 
        _map.bone_id       = bone_id;
        _map.limit_min     = limit_min;
        _map.limit_max     = limit_max;
        _map.lock_children = lock_children;
        
        return _map; 
    }
    
    static deserialize = function(_map) {
        bone_id        = _map[$ "bone_id"]       ?? bone_id;
        limit_min      = _map[$ "limit_min"]     ?? limit_min;
        limit_max      = _map[$ "limit_max"]     ?? limit_max;
        lock_children  = _map[$ "lock_children"] ?? lock_children;
        
        return self;
    }
}