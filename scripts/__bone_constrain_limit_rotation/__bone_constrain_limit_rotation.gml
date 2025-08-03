function __Bone_Constrain_Limit_Rotation(_bone, _bid = "") : __Bone_Constrain(_bone) constructor {
    name      = "Limit Rotation";
    sindex    = 7;
    bone_id   = _bid;
    limit_min = 0;
    limit_max = 0;
    
    global_context = false;
    lock_children  = true;
    bone_object    = noone;
    
    tb_limit = new vectorBox(2, function(v, i) /*=>*/ { 
             if(i == 0) limit_min = v; 
        else if(i == 1) limit_max = v; 
        node.triggerRender(); 
    });
        
    tb_limit.axis = ["from", "to"];
    tb_limit.boxColor = COLORS._main_icon_light;
    
    context_bt = new buttonGroup([ "Local", "Global" ], function(i) /*=>*/ { global_context = i; node.triggerRender(); });
    cb_lock    = new checkBox(function() /*=>*/ { lock_children = !lock_children; node.triggerRender(); });
    
    ////- Actions
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static preConstrain = function(_b) {
        if(!lock_children) return;
        
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        bone_object = _bone;
        if(_bone == noone) return;
        
        var a0 = global_context? limit_min - _bone.angle : limit_min;
        var a1 = global_context? limit_max - _bone.angle : limit_max;
        
        _bone.pose_rotate = clamp(_bone.pose_rotate, a0, a1);
    }
    
    static constrain = function(_b) {
        if(lock_children) return;
        
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        bone_object = _bone;
        if(_bone == noone) return;
        
        var a0 = global_context? limit_min - _bone.pose_local_rotate : _bone.angle + limit_min;
        var a1 = global_context? limit_max - _bone.pose_local_rotate : _bone.angle + limit_max;
        
        _bone.pose_angle = clamp(_bone.pose_angle, a0, a1);
    }
    
    ////- Draw
    
    static drawInspector = function(_x, _y, _w, _m, _hover, _focus, _drawParam) { 
        var wh = 0;
        
        // draw bones
        var _wdx = _x + ui(8);
        var _wdw = _w - ui(16);
        var _wdh = ui(20);
        draw_sprite_stretched_ext(THEME.textbox, 3, _wdx, _y, _wdw, _wdh, COLORS._main_icon_light, 1);
        
        if(bone_object != noone) {
            var _bname = bone_object.name;
            
            draw_sprite_ui(THEME.bone, 1, _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, 1);
            draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
            draw_text_add(_wdx + ui(32), _y + _wdh / 2, _bname);
            
        } else
            draw_sprite_ui(THEME.bone, 1, _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, .5);
        
        if(_hover && point_in_rectangle(_m[0], _m[1], _wdx, _y, _wdx + _wdw, _y + _wdh)) {
            draw_sprite_stretched_ext(THEME.textbox, 1, _wdx, _y, _wdw, _wdh, c_white, 1);
            if(mouse_press(mb_left, _focus))
                node.boneSelector(function(p) /*=>*/ { bone_id = p.bone.ID; init(); node.triggerRender(); })
        }
        
        // draw widget
        var _lbx = _x + ui(16);
        var _wdw = _w * 2/3;
        var _wdx = _x + _w - _wdw - ui(8);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Context"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, global_context, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        context_bt.drawParam(_dParam);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Range"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, [ limit_min, limit_max ], {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_limit.drawParam(_dParam);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Inherit"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, lock_children, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        _dParam.s = _wdh;
        _dParam.halign = fa_center;
        cb_lock.drawParam(_dParam);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    static drawBone = function(_b, _x, _y, _s) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var p0x = _x + _bone.bone_head_pose.x * _s;
		var p0y = _y + _bone.bone_head_pose.y * _s;
		
		var a0 = global_context? limit_min : _bone.angle + limit_min;
		var a1 = global_context? limit_max : _bone.angle + limit_max;
		
		draw_set_color(COLORS._main_icon);
		draw_arc(p0x, p0y, ui(32), a0, a1, 1, 32, true);
		draw_set_alpha(1); 
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