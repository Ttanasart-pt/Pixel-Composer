function __Bone_Constrain_Move_To_Point(_bone, _bid = "", _tid = "") : __Bone_Constrain(_bone) constructor {
    name      = "Move To Point";
    sindex    = 4;
    bone_id   = _bid;
    bone_object   = noone;
    
    strength = 1;
    point    = [ 0, 0 ];
    
    tb_strength = slider(,,, function(v) /*=>*/ { strength = clamp(v, 0, 1); node.triggerRender(); }).setLabel("Strength").setBoxColor(COLORS._main_icon_light);
    tb_point    = new vectorBox(2, function(v, i) /*=>*/ { point[i] = v; node.triggerRender(); }).setBoxColor(COLORS._main_icon_light);
    
    ////- Actions
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static constrain = function(_b) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var _fr = _bone.getHead();
        var _dr = point_direction( _fr.x, _fr.y, point[0], point[1] );
        var _ds = point_distance(  _fr.x, _fr.y, point[0], point[1] );
        
        var _x = lerp(_fr.x, point[0], strength);
        var _y = lerp(_fr.y, point[1], strength);
        
        _bone.pose_direction = point_direction(0, 0, _x, _y);
        _bone.pose_distance  = point_distance(0, 0, _x, _y);
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
            
            draw_sprite_ui(THEME.bone, bone_object.getSpriteIndex(), _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, 1);
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
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Strength"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, strength, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_strength.drawParam(_dParam);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Point"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, point, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_point.drawParam(_dParam);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    static drawBone = function(_b, _x, _y, _s) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var p0x = _x + _bone.bone_head_pose.x * _s;
		var p0y = _y + _bone.bone_head_pose.y * _s;
		var p1x = _x + point[0] * _s;
		var p1y = _y + point[1] * _s;
		
		draw_set_color_alpha(COLORS._main_icon, .5);
		draw_line_dashed(p0x, p0y, p1x, p1y);
		draw_set_alpha(1);
    }
    
    ////- Serialize
    
    static onSerialize = function(_map) {
        _map.bone_id  = bone_id;
        _map.strength = strength;
        _map.point    = point;
        
        return _map; 
    }
    
    static deserialize = function(_map) {
        bone_id  = _map[$ "bone_id"]  ?? bone_id;
        strength = _map[$ "strength"] ?? strength;
        point    = _map[$ "point"]    ?? point;
        
        return self;
    }
}