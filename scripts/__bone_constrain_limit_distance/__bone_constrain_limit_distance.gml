function __Bone_Constrain_Limit_Distance(_bone, _bid = "") : __Bone_Constrain(_bone) constructor {
    name    = "Limit Distance";
    sindex  = 9;
    bone_id = _bid;
    bone_object   = noone;
    
    global_context = false;
    limit_center = [ 0, 0 ];
    limit_range  = 16;
    
    context_bt = new buttonGroup([ "Local", "Global" ], function(i) /*=>*/ { global_context = i; node.triggerRender(); });
    tb_limit_c = new vectorBox(2, function(v, i) /*=>*/ { limit_center[i] = v; node.triggerRender(); }).setBoxColor(COLORS._main_icon_light);
    tb_limit   = textBox_Number(function(v) /*=>*/ { limit_range = v; node.triggerRender(); }).setBoxColor(COLORS._main_icon_light);
    
    ////- Actions
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
    }
    
    static preConstrain = function(_b) {
    	if(global_context) return;
    	
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var _pos = _bone.pose_posit;
        var _dir = point_direction( 0, 0, _pos[0], _pos[1] );
        var _dis = point_distance(  0, 0, _pos[0], _pos[1] );
        _dis = min(_dis, limit_range);
        
        _bone.pose_posit[0] = lengthdir_x(_dis, _dir);
        _bone.pose_posit[1] = lengthdir_y(_dis, _dir);
    }
    
    static constrain = function(_b) {
        if(!global_context) return;
        
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var _pos = _bone.pose_posit;
    	var _dir = point_direction( limit_center[0], limit_center[1], _pos[0], _pos[1] );
        var _dis = point_distance(  limit_center[0], limit_center[1], _pos[0], _pos[1] );
    	_dis = min(_dis, limit_range);
    	
    	var _wpx = limit_center[0] + lengthdir_x(_dis, _dir);
    	var _wpy = limit_center[1] + lengthdir_y(_dis, _dir);
    	
        var _par = _bone.parent.getHead(true);
    	_bone.pose_direction = point_direction( _par.x, _par.y, _wpx, _wpy );
		_bone.pose_distance  = point_distance(  _par.x, _par.y, _wpx, _wpy );
    
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
        
        if(global_context) {
	        _y += _wdh + ui(4);
	        wh += _wdh + ui(4);
	        
	        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
	        draw_text_add(_lbx, _y + _wdh / 2, __txt("Center"));
	        
	        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, limit_center, {}, _m, _drawParam.rx, _drawParam.ry)
	            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
	        tb_limit_c.drawParam(_dParam);
        }
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
        draw_text_add(_lbx, _y + _wdh / 2, __txt("Range"));
        
        var _dParam = new widgetParam(_wdx, _y, _wdw, _wdh, limit_range, {}, _m, _drawParam.rx, _drawParam.ry)
            .setFont(f_p3).setScrollpane(_drawParam.panel).setFocusHover(_focus, _hover);
        tb_limit.drawParam(_dParam);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    static drawBone = function(_b, _x, _y, _s) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        if(_bone == noone) return;
        
        var p0x = _x + (global_context? limit_center[0] : _bone.bone_head_init.x) * _s;
		var p0y = _y + (global_context? limit_center[1] : _bone.bone_head_init.y) * _s;
		var rad = limit_range * _s;
		
		draw_set_color(COLORS._main_icon);
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