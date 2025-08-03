function __Bone_Constrain_Limit_Position(_bone, _bid = "") : __Bone_Constrain(_bone) constructor {
    name      = "Limit Position";
    sindex    = 6;
    bone_id   = _bid;
    limit_range = 0;
    
    bone_object   = noone;
    
    tb_limit = textBox_Number(function(v) /*=>*/ { limit_range = v; node.triggerRender(); }).setBoxColor(COLORS._main_icon_light);
    
    ////- Actions
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static preConstrain = function(_b) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        bone_object = _bone;
        if(_bone == noone) return;
        
        var _pos = _bone.pose_posit;
        var _dir = point_direction(0, 0, _pos[0], _pos[1]);
        var _dis = point_distance(0, 0, _pos[0], _pos[1]);
        _dis = min(_dis, limit_range);
        
        _bone.pose_posit[0] = lengthdir_x(_dis, _dir);
        _bone.pose_posit[1] = lengthdir_y(_dis, _dir);
    }
    
    static constrain = function(_b) {
        
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
            if(mouse_press(mb_left, _focus))
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
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, limit_range, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_limit.drawParam(_dParam);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    static drawBone = function(_x, _y, _s) {
        if(bone_object == noone) return;
        
        var p0x = _x + bone_object.bone_head_init.x * _s;
		var p0y = _y + bone_object.bone_head_init.y * _s;
		var rad = limit_range * _s;
		
		draw_set_color_alpha(COLORS._main_icon, .5);
		draw_circle_prec(p0x, p0y, rad, 1);
		draw_set_alpha(1);
    }
    
    ////- Serialize
    
    static onSerialize = function(_map) { 
        _map.bone_id       = bone_id;
        _map.limit_range   = limit_range;
        
        return _map; 
    }
    
    static deserialize = function(_map) {
        bone_id        = _map[$ "bone_id"]       ?? bone_id;
        limit_range    = _map[$ "limit_range"]   ?? limit_range;
        
        return self;
    }
}