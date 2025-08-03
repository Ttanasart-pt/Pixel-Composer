function __Bone_Constrain_Limit_Rotation(_bone, _bid = "") : __Bone_Constrain(_bone) constructor {
    name      = "Limit Rotation";
    sindex    = 7;
    bone_id   = _bid;
    limit_min = 0;
    limit_max = 0;
    
    bone_object   = noone;
    
    tb_limit = new vectorBox(2, function(v, i) /*=>*/ { if(i == 0) limit_min = v; else if(i == 1) limit_max = v; node.triggerRender(); });
    tb_limit.axis = ["ccw", "cw"];
    tb_limit.tb[0].font = f_p2;
    tb_limit.tb[1].font = f_p2;
    tb_limit.boxColor = COLORS._main_icon_light;
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static constrain = function(_b) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        _bone.pose_angle = clamp(_bone.pose_angle, _bone.angle - limit_min, _bone.angle + limit_max);
    }
    
    static draw_inspector = function(_x, _y, _w, _m, _hover, _focus, _drawParam) { 
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
        var _wdx = _x + ui(8);
        var _wdw = _w - ui(16);
        var _wdh = ui(24);
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, [ limit_min, limit_max ], {}, _m, _drawParam.rx, _drawParam.ry);
        
        tb_limit.register(_drawParam.panel);
        tb_limit.setFocusHover(_focus, _hover);
        tb_limit.drawParam(_dParam);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    static onSerialize = function(_map) { 
        _map.bone_id   = bone_id;
        _map.limit_min = limit_min;
        _map.limit_max = limit_max;
        
        return _map; 
    }
    
    static deserialize = function(_map) {
        bone_id    = _map.bone_id;
        limit_min  = _map.limit_min;
        limit_max  = _map.limit_max;
        
        return self;
    }
}