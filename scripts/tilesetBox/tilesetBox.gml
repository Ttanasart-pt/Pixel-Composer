function tilesetBox(_junction) : widget() constructor {
	junction = _junction;
	tileset  = undefined;
	
	fullHeight = ui(64);
	
    b_newTileset = button(function() /*=>*/ { 
    	var b = nodeBuild("Node_Tile_Tileset", junction.node.x - 160, junction.ry - 32);
    	junction.setFrom(b.outputs[0]);
	});
	
	b_newTileset.text       = __txt("New tileset");
	b_newTileset.icon       = THEME.add_16;
	b_newTileset.icon_size  = .75;
	b_newTileset.icon_blend = COLORS._main_value_positive;
    
	static trigger = function() { }
	
	////- =Draw
	
	static fetchHeight = function(params) { return is(_tileset, Node_Tile_Tileset)? fullHeight : TEXTBOX_HEIGHT; }
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _tileset, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		tileset = _tileset;
        
        if(!is(_tileset, Node_Tile_Tileset)) {
        	h = TEXTBOX_HEIGHT;
        	
        	if(interactable) {
	            b_newTileset.setFocusHover(active, hover);
	            var param = new widgetParam(x, y, w, h, noone, undefined, _m, rx, ry).setFont(font);
	            b_newTileset.drawParam(param);
	            
        	} else {
        		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h, COLORS._main_icon_light);
        		draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
        		draw_text_add(x+w/2, y+h/2, __txt("No data"));
        		
        	}
            
        } else {
        	h = fullHeight;
			var ic = s_node_tile_tileset;
			
			var tileSize = _tileset.tileSize;
			var tileText = _tileset.texture;
        	
        	var iw = ui(24);
        	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
        	var bi = 0;
        	
        	if(ihover && point_in_rectangle(_m[0], _m[1], x, y, x + iw, y + h)) {
        		setTOOLTIP(__txt("View node"));
        		bi = 1;
        		
        		if(mouse_lclick(iactive))
        			bi = 2;
        			
        		if(mouse_lpress(iactive) && is(_tileset, Node))
        			New_Inspect_Node_Panel(_tileset);
        	}
        	
        	var bx = x + iw + ui(4);
        	var by = y;
        	var bw = w - iw - ui(4);
        	var bh = h;
        	
        	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, h);
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, bx, by, bw, bh, COLORS._main_icon_light);
            draw_sprite_ext(ic, 0, x + iw / 2, y + h / 2, _s, _s);
            
            var _txt = _tileset.getDisplayName();
            if(tileSize != undefined) _txt += $" {tileSize}";
            
            if(is_surface(tileText)) {
            	var _bw = bw - ui(8);
            	var _bh = bh - ui(8);
            	
            	var _sw = surface_get_width(tileText);
            	var _sh = surface_get_height(tileText);
            	var _ss = min(_bw / _sw, _bh / _sh);
            	
            	var _sx = bx + bw / 2 - _sw * _ss / 2;
            	var _sy = by + bh / 2 - _sh * _ss / 2;
            	
            	draw_surface_ext(tileText, _sx, _sy, _ss, _ss, 0, c_white, 1);
            }
            
            draw_set_text(f_p4, fa_right, fa_bottom, COLORS._main_text_sub);
            var tx = x + w - ui(4);
            var ty = y + h - ui(3);
            var tw = string_width(_txt);
            var th = string_height(_txt);
            
            draw_sprite_stretched_ext(THEME.box_r2, 0, tx-tw-ui(3), ty-th-ui(2), tw+ui(6), th+ui(4), COLORS.panel_bg_clear_inner, 0.85);
	        draw_text_add(tx, ty, _txt);
        }
        
		return h;
	}
	
	static clone = function() { return new tilesetBox(); }
}
