function mktreeBox() : widget() constructor {
	expanded   = false;
	expanded_h = TEXTBOX_HEIGHT;
	
	static trigger = function() {}
	
	static fetchHeight = function(params) { return expanded? expanded_h : TEXTBOX_HEIGHT; }
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static drawTree = function(_tree, _x, _y, _w, _suff = "") {
		var hh = ui(18);
		var _h = hh;
		
		var isRoot = _tree.root == _tree;
		var _name  = isRoot? "Root" : "Branch";
		
		draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
        draw_text_add(_x, _y + hh / 2, _suff == ""? _name : $"{_name} [{_suff}]");
        _y += hh;
        
        if(array_empty(_tree.children)) return _h;
        
    	var _hh  = drawTree(_tree.children[0], _x + ui(16), _y, _w - ui(16), array_length(_tree.children));
    	_h += _hh;
    	_y += _hh;
    	
        // for( var i = 0, n = array_length(_tree.children); i < n; i++ ) {
        // 	var _brn = _tree.children[i];
        // 	var _hh  = drawTree(_brn, _x + ui(16), _y, _w - ui(16));
        // 	_h += _hh;
        // 	_y += _hh;
        // }
		
		return _h;
	}
	
	static draw = function(_x, _y, _w, _tree, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = expanded? expanded_h : TEXTBOX_HEIGHT;
        
        var _isLeaf = is_array(_tree) && array_length(_tree) && is(_tree[0], __MK_Tree_Leaf);
        
    	var ic = _isLeaf? THEME.mkTree_leaf : THEME.mkTree;
    	var cc = expanded? COLORS._main_icon_light : COLORS.node_blend_mktree; 
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
        		
        if(expanded) {
        	expanded_h = TEXTBOX_HEIGHT;
    		var _h = 0;
    		var _l = "";
    		
    		if(_isLeaf) _l = $"Leaves [{array_length(_tree)}]"
        	else if(is_array(_tree) && array_length(_tree)) {
        		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
        			if(!is(_tree[i], __MK_Tree)) continue;
    				var hh = drawTree(_tree[i], x0, y0, ww);
    				_h += hh;
    				y0 += hh;
        		}
        		
        	} else if(is(_tree, __MK_Tree))
        		_h += drawTree(_tree, x0, y0, ww);
        	
	        draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
	        draw_text_add(x0, y + TEXTBOX_HEIGHT / 2, _l);
	        
    		expanded_h = max(expanded_h, ui(8) + _h);
        	
        } else {
	        draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
	        draw_text_add(x0, y + h / 2, "Tree");
	        
        }
        
		return h;
	}
	
	static clone = function() { return new pathnodeBox(); }
}
