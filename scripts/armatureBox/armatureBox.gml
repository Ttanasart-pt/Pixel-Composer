function armatureBox(_junction) : widget() constructor {
	self.junction = _junction;
	
    b_newTileset = button(function() /*=>*/ { 
    	var b = nodeBuild("Node_Armature", junction.node.x - 160, junction.ry - 32);
    	junction.setFrom(b.outputs[0]);
	});
	
	b_newTileset.text       = __txt("New armature");
	b_newTileset.icon       = THEME.add_16;
	b_newTileset.icon_size  = .75;
	b_newTileset.icon_blend = COLORS._main_value_positive;
    
	static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _armature, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = TEXTBOX_HEIGHT;
        
        if(_armature == noone) {
            b_newTileset.setFocusHover(active, hover);
            var param = new widgetParam(x, y, w, h, noone, {}, _m, rx, ry);
            b_newTileset.drawParam(param);
            
        } else {
			var ic = THEME.bone;
			var iw = ui(24);
        	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
        	var bi = 0;
        	
        	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, h);
        	
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x + iw + ui(4), y, w - iw - ui(4), h, COLORS._main_icon_light);
            draw_sprite_ext(ic, 1, x + iw / 2, y + h / 2, _s, _s);
            
            draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
	        draw_text_add(x + iw + ui(4 + 8), y + h / 2, "Armature");
        }
        
		return h;
	}
	
	static clone = function() { return new tilesetBox(); }
}
