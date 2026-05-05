function mkblastBox() : widget() constructor {
	expanded   = false;
	expanded_h = TEXTBOX_HEIGHT;
	
	static trigger = function() {}
	
	static fetchHeight = function(params) { return expanded? expanded_h : TEXTBOX_HEIGHT; }
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _blast, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = expanded? expanded_h : TEXTBOX_HEIGHT;
        
    	var ic = THEME.mkBlast;
    	var cc = COLORS.node_blend_mkblast; 
    	var iw = TEXTBOX_HEIGHT;
    	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
    	var bi = 0;
    	
    	if(ihover && point_in_rectangle(_m[0], _m[1], x, y, x + iw, y + iw)) {
    		bi = 1;
    		if(mouse_lclick(iactive)) bi = 2;
    		if(mouse_lpress(iactive)) expanded = !expanded;
    	}
    	
    	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, iw);
        draw_sprite_ext(ic, 0, x + iw / 2, y + iw / 2, _s, _s, 0, cc);
    	
        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x + iw + ui(4), y, w - iw - ui(4), h, COLORS._main_icon_light);
        
        var x0 = x + iw + ui(4 + 8);
        var y0 = y + ui(4);
		var ww = w - iw - ui(4);
		var _l = "Blast";
		expanded_h = TEXTBOX_HEIGHT;
		
        draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
        draw_text_add(x0, y + h / 2, _l);
        
		return h;
	}
	
	static clone = function() { return new mkblastBox(); }
}
