function pathnodeBox(_junction) : widget() constructor {
	junction = _junction;
	
    b_newPath = button(function() /*=>*/ { 
    	var b = nodeBuild(junction.extract_node, junction.node.x - 128, junction.ry - 32);
    	junction.setFrom(b.outputs[1]);
	}).setText(__txt("New path")).setIcon(THEME.add_16, 0, COLORS._main_value_positive, .75);
	
    b_newPathMenu = button(function() /*=>*/ { 
    	var exts = junction.extract_node;
    	var menu = [];
    	
    	for( var i = 0, n = array_length(exts); i < n; i++ ) {
    		var _ext = exts[i];
    		if(!has(ALL_NODES, _ext)) continue;
    		
    		var node = ALL_NODES[$ _ext];
    		array_append(menu, new MenuItem(node.getName(), function(e) /*=>*/ {
    			var b = nodeBuild(e, junction.node.x - 128, junction.ry - 32);
    			var o = b.getOutput(0, junction);
    			if(is(o, NodeValue)) junction.setFrom(o);
    		}, node.spr).setParam(_ext));
    	}
    	
    	menuCall("", menu);
	}).setIcon(THEME.add_node, 0, c_white).iconPad(ui(6));
	
	static fetchHeight = function(p) /*=>*/ {return TEXTBOX_HEIGHT};
	static drawParam   = function(p) /*=>*/ { setParam(p); return draw(p.x, p.y, p.w, p.data, p.m); }
	static draw = function(_x, _y, _w, _path, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = TEXTBOX_HEIGHT;
		
        if(_path == noone) {
        	var exts = junction.extract_node;
        	var ext  = is_array(exts)? exts[0] : exts;
			var bPar = new widgetParam(x, y, w, h, noone, undefined, _m, rx, ry).setFont(font);
			
			if(is_array(exts)) {
				var bs = h;
				b_newPathMenu.setFocusHover(active, hover);
	            b_newPathMenu.drawParam(new widgetParam(x + w - bs, y, bs, bs, noone, undefined, _m, rx, ry));
				bPar.w -= bs + ui(4);
			}
			
			if(is_string(ext)) {
				var nod = ALL_NODES[$ ext];
				b_newPath.text = $"New {nod.name}";
	            b_newPath.setFocusHover(active, hover);
	            b_newPath.drawParam(bPar);
			}
            return h;
        } 
        
    	var ic = s_node_path;
    	var _node = is(_path, Path)? _path.node : _path;
    	
    	if(is(_node, Node)) {
    		var _key = instanceof(_node);
    		if(has(ALL_NODES, _key))
    			ic = ALL_NODES[$ _key].spr;
    	}
    	
    	var iw = ui(24);
    	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
    	var bi = 0;
    	
    	if(ihover && point_in_rectangle(_m[0], _m[1], x, y, x + iw, y + h)) {
    		TOOLTIP = __txt("View node");
    		bi = 1;
    		
    		if(mouse_lclick(iactive))
    			bi = 2;
    			
    		if(mouse_lpress(iactive) && is(_node, Node)) New_Inspect_Node_Panel(_node);
    	}
    	
    	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, h);
    	
        draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x + iw + ui(4), y, w - iw - ui(4), h, COLORS._main_icon_light);
        draw_sprite_ext(ic, 0, x + iw / 2, y + h / 2, _s, _s);
        
        draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
        draw_text_add(x + iw + ui(4 + 8), y + h / 2, is(_node, Node)? _node.getDisplayName() : "Path");
        
		return h;
	}
	
	static clone = function() /*=>*/ {return new pathnodeBox(junction)};
}
