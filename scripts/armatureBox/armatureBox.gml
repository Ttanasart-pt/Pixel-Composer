function armatureBox(_junction) : widget() constructor {
	self.junction = _junction;
	
    b_new = button(function() /*=>*/ { 
    	var b = nodeBuild("Node_Armature", junction.node.x - 160, junction.ry - 32);
    	junction.setFrom(b.outputs[0]);
	});
	
	b_new.text       = __txt("New armature");
	b_new.icon       = THEME.add_16;
	b_new.icon_size  = .75;
	b_new.icon_blend = COLORS._main_value_positive;
    
	static trigger = function() { }
	
	static fetchHeight = function(params) { return TEXTBOX_HEIGHT; }
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _armature, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = TEXTBOX_HEIGHT;
        
        if(_armature == noone) {
        	if(interactable) {
	            b_new.setFocusHover(active, hover);
	            var param = new widgetParam(x, y, w, h, noone, undefined, _m, rx, ry).setFont(font);
	            b_new.drawParam(param);
            
        	} else {
        		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h, COLORS._main_icon_light);
        		draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
        		draw_text_add(x+w/2, y+h/2, __txt("No data"));
        		
        	}
            
        } else {
			var ic = THEME.bone;
			var iw = ui(24);
        	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
        	var bi = 0;
        	
        	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, h);
        	
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x + iw + ui(4), y, w - iw - ui(4), h, COLORS._main_icon_light);
            draw_sprite_ext(ic, 1, x + iw / 2, y + h / 2, _s, _s);
            
            draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
	        draw_text_add(x + iw + ui(4 + 8), y + h / 2, "Armature");
        }
        
		return h;
	}
	
	static clone = function() { return new tilesetBox(); }
}
