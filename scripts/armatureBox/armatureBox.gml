function armatureBox(_junction) : widget() constructor {
	junction   = _junction;
	expanded   = false;
	expanded_h = TEXTBOX_HEIGHT;
	
    b_new = button(function() /*=>*/ { 
    	var b = nodeBuild("Node_Armature", junction.node.x - 160, junction.ry - 32);
    	junction.setFrom(b.outputs[0]);
	});
	
	b_new.text       = __txt("New armature");
	b_new.icon       = THEME.add_16;
	b_new.icon_size  = .75;
	b_new.icon_blend = COLORS._main_value_positive;
    
	static trigger = function() { }
	
	static fetchHeight = function(params) { return expanded? expanded_h : TEXTBOX_HEIGHT; }
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _armature, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = expanded? expanded_h : TEXTBOX_HEIGHT;
        
        if(_armature == noone) {
        	expanded = false;
        	if(interactable) {
	            b_new.setFocusHover(active, hover);
	            var param = new widgetParam(x, y, w, h, noone, undefined, _m, rx, ry).setFont(font);
	            b_new.drawParam(param);
            
        	} else {
        		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h, COLORS._main_icon_light);
        		draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
        		draw_text_add(x+w/2, y+h/2, __txt("No data"));
        		
        	}
            
            return h;
        } 
        
		var ic = THEME.bone;
		var iw = ui(24);
    	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
    	var bi = 0;
    	
    	var tw  = w - iw - ui(4);
		var tx  = x + iw + ui(4);
			
    	if(ihover && point_in_rectangle(_m[0], _m[1], x, y, x + iw, y + h)) {
    		bi = 1;
    		if(mouse_lclick(iactive)) bi = 2;
    		if(mouse_lpress(iactive)) expanded = !expanded;
    	}
    	
    	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, h);
    	
        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, tx, y, tw, h, COLORS._main_icon_light);
        draw_sprite_ext(ic, 1, x + iw / 2, y + h / 2, _s, _s);
        
        if(expanded) {
        	var bone_array = _armature.toArray();
        	var amo = array_length(bone_array);
			var _hh = ui(20);
			var ty  = y;
			
			expanded_h = ui(12) + amo * _hh;
				
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, tx, ty, tw, expanded_h, COLORS.node_composite_bg_blend, 1);
			ty += ui(6);
			
			var scs = gpu_get_scissor();
			
			for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
				var bone = bone_array[i];
				if(bone.is_main) continue;
				
				var bnx  = tx + (bone.arrayDepth - 1) * ui(8);
				var bnw  = tw - (bone.arrayDepth - 1) * ui(8);
				var bcol = COLORS._main_icon;
				
				////- =Data
				
				draw_sprite_ui(THEME.bone, bone.getSpriteIndex(), bnx + ui(12), ty + _hh / 2, .8, .8, 0, bcol);
				
				var tbx = bnx + ui(24);
				var tby = ty + _hh / 2;
				
				gpu_set_scissor(tbx, ty, tw - tbx - ui(4), ty + _hh);
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
				draw_text_add(tbx, tby, bone.name);
				gpu_set_scissor(scs);
				
				ty += _hh;
			}
			
        } else {
	        draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
	        draw_text_add(x + iw + ui(4 + 8), y + h / 2, "Armature");
        }
        
		return h;
	}
	
}
