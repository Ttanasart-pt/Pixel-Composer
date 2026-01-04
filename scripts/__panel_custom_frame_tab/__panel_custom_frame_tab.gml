function Panel_Custom_Frame_Tab(_data) : Panel_Custom_Frame(_data) constructor {
	type = "frametab";
	name = "Tab Frame";
	icon = THEME.panel_icon_element_frame_tab;
	
	page = 0;
	page_default = 0;
	pageOutput   = new JuncLister(data, "Page", CONNECT_TYPE.output);
	
	array_append(editors, [
		[ "Page", false ], 
		pageOutput, 
		Simple_Editor("Default Page", textBox_Number( function(v) /*=>*/ { page_default = v; } ), function() /*=>*/ {return page_default}, function(v) /*=>*/ { page_default = v; }), 
	]);
	
	////- BBOX
	
	static checkMouse = function(panel, _m) {
		elementHover = panel._hovering_element == self;
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) {
			if(mouseEvent) panel.hovering_element = self;
			
			if(is_container || key_mod_press(CTRL)) 
				panel.hovering_frame = self;
		}
		
		var _content = array_safe_get_fast(contents, page);
		if(_content) _content.checkMouse(panel, _m);
	}
	
	////- Draw
	
	static setFocusHover = function(_focus, _hover) {
		focus = _focus;
		hover = _hover;
		
		page = page_default;
		var _junc = pageOutput.getJunction();
		if(_junc) page = _junc.showValue();
		
		array_foreach(contents, function(c) /*=>*/ { c.active = false; });
		
		var _content = array_safe_get_fast(contents, page);
		if(_content) {
			_content.active = true;
			_content.setFocusHover(_focus, _hover);
		}
		return self;
	}
	
	static doDraw = function(panel, _m) {
		draw(panel, _m);
		
		var _content = array_safe_get_fast(contents, page);
		if(_content) _content.doDraw(panel, _m);
	}
	
	static drawBox = function(panel) {
		var aa = .25 + .5 * (panel._hovering_element == self);
		draw_sprite_stretched_add(THEME.ui_panel, 1, x, y, w, h, COLORS._main_icon, aa);
		
		var _content = array_safe_get_fast(contents, page);
		if(_content) _content.drawBox(panel);
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {
		_m.page_default = page_default;
		_m.pageOutput   = pageOutput.serialize(_m);
	}
	
	static frameDeserialize = function(_m) {
		page_default = _m.page_default;
		
		if(has(_m, "pageOutput")) pageOutput.deserialize(_m.pageOutput);
		return self;
	}
}