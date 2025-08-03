function __Bone_Constrain_Limit_Position(_bone, _bid = "") : __Bone_Constrain(_bone) constructor {
    name    = "Limit Position";
    sindex  = 6;
    bone_id = _bid;
    bone_object = noone;
    
    global_context = false;
    limit_x = [ 0, 8 ];
    limit_y = [ 0, 8 ];
    
    context_bt = new buttonGroup([ "Local", "Global" ], function(i) /*=>*/ { global_context = i; node.triggerRender(); });
    tb_limit_x = new rangeBox(function(v, i) /*=>*/ { limit_x[i] = v; node.triggerRender(); }).setBoxColor(COLORS._main_icon_light);
    tb_limit_y = new rangeBox(function(v, i) /*=>*/ { limit_y[i] = v; node.triggerRender(); }).setBoxColor(COLORS._main_icon_light);
    
    ////- Actions
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static preConstrain = function(_b) {
    	if(global_context) return;
    	
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        _bone.pose_posit[0] = clamp(_bone.pose_posit[0], limit_x[0], limit_x[1]);
        _bone.pose_posit[1] = clamp(_bone.pose_posit[1], limit_y[0], limit_y[1]);
    }
    
    static constrain = function(_b) {
        if(!global_context) return;
    	
    	var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var _worldpos = _bone.bone_head_pose;
        var _wpx = clamp(_worldpos.x, limit_x[0], limit_x[1]);
        var _wpy = clamp(_worldpos.y, limit_y[0], limit_y[1]);
        
        var _par = _bone.parent.getHead(true);
        _bone.pose_direction = point_direction(_par.x, _par.y, _wpx, _wpy);
		_bone.pose_distance  = point_distance(_par.x, _par.y, _wpx, _wpy);
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
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Context"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, global_context, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        context_bt.drawParam(_dParam);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Range X"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, limit_x, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_limit_x.drawParam(_dParam);
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Range Y"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, limit_y, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_limit_y.drawParam(_dParam);
        
        _y += _wdh + ui(4 + 4);
        wh += _wdh + ui(4 + 4);
        
        return wh;
    }
    
    static drawBone = function(_b, _x, _y, _s) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var p0x = global_context? _x : _x + _bone.bone_head_init.x * _s;
		var p0y = global_context? _y : _y + _bone.bone_head_init.y * _s;
			
        draw_set_color(COLORS._main_icon);
		draw_rectangle(p0x + limit_x[0] * _s, p0y + limit_y[0] * _s, 
		               p0x + limit_x[1] * _s, p0y + limit_y[1] * _s, 1);
		draw_set_alpha(1);
    }
    
    ////- Serialize
    
    static onSerialize = function(_map) { 
        _map.bone_id = bone_id;
        _map.limit_x = limit_x;
        _map.limit_y = limit_y;
        
        return _map; 
    }
    
    static deserialize = function(_map) {
        bone_id = _map[$ "bone_id"] ?? bone_id;
        limit_x = _map[$ "limit_x"] ?? limit_x;
        limit_y = _map[$ "limit_y"] ?? limit_y;
        
        return self;
    }
}