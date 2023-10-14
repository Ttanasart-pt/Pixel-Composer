function timelineItem() constructor { 
	show = true;
	
	color  = CDEF.main_grey;
	parent = noone;
	
	static drawLabel = function(_x, _y, _w, _msx, _msy) {}
	
	static removeSelf = function() { #region
		if(parent == noone) return;
		array_remove(parent.contents, self);
		
		return self;
	} #endregion
	
	static serialize = function() {}
	
	static deserialize = function(_map) { #region
		switch(_map.type) {
			case "Node"   : return new timelineItemNode(noone).deserialize(_map);
			case "Folder" : return new timelineItemGroup(noone).deserialize(_map);
		}
		
		return self;
	} #endregion
}

function timelineItemNode(node) : timelineItem() constructor {
	self.node = node;
	
	static drawLabel = function(_x, _y, _w, _msx, _msy, hover, focus, itHover, fdHover, nameType, alpha) { #region
		_x += ui(2);
		_w -= ui(4);
		
		var lh  = ui(20);
		var res = 0;
		var cc  = colorMultiply(color, COLORS.panel_animation_dope_bg);
		
		if(hover && point_in_rectangle(_msx, _msy, _x + ui(20), _y, _x + _w, _y + lh)) {
			cc  = colorMultiply(color, COLORS.panel_animation_dope_bg_hover);
			res = 1;
		}
		
		draw_sprite_stretched_ext(THEME.timeline_node, 0, _x, _y, _w, lh, cc, alpha);
		draw_sprite_stretched_ext(THEME.timeline_node, 1, _x, _y, _w, lh, COLORS.panel_animation_node_outline, 1);
			
		var tx = _x + _w - ui(10);
		if(buttonInstant(THEME.button_hide, tx - ui(10), _y, ui(20), ui(20), [ _msx, _msy ], focus, hover, 
			__txtx("panel_animation_goto", "Go to node"), THEME.animate_node_go, 0, COLORS._main_icon) == 2)
				graphFocusNode(node);
			
		if(node == PANEL_INSPECTOR.getInspecting())
			draw_sprite_stretched_ext(THEME.timeline_node, 1, _x, _y, _w, lh, COLORS._main_accent, 1);
			
		if(hover && point_in_rectangle(_msx, _msy, _x, _y, _x + ui(20), _y + lh)) {
			draw_sprite_ui_uniform(THEME.arrow, show? 3 : 0, _x + ui(10), _y + lh / 2, 1, COLORS._main_icon_light, 1);
			if(mouse_press(mb_left, focus)) show = !show;
		} else
			draw_sprite_ui_uniform(THEME.arrow, show? 3 : 0, _x + ui(10), _y + lh / 2, 1, COLORS._main_icon, 0.75);
		
		draw_set_text(f_p3, fa_left, fa_center);
		var nodeName = $"[{node.name}] ";
		var tw = string_width(nodeName);
		
		draw_set_color(itHover == self? COLORS._main_text_accent : COLORS._main_text);
		var txx = _x + ui(20);
			
		if(nameType == 0 || nameType == 1 || node.display_name == "") {
			draw_set_alpha(0.4);
			draw_text_add(txx, _y + lh / 2 - ui(2), nodeName);
			txx += tw;
		}
			
		draw_set_font(f_p2);
		if(nameType == 0 || nameType == 2) {
			draw_set_alpha(0.9);
			draw_text_add(txx, _y + lh / 2 - ui(2), node.display_name);
		}
			
		draw_set_alpha(1);
		return res;
	} #endregion
	
	static serialize = function() { #region
		var _map = {};
		
		_map.type    = "Node";
		_map.show    = show;
		_map.color   = color;
		_map.node_id = node.node_id;
		
		return _map;
	} #endregion
	
	static deserialize = function(_map) { #region
		color = _map.color;
		show  = struct_try_get(_map, "show", true);
		
		var _node_id = _map.node_id;
		node = PROJECT.nodeMap[? _node_id];
		node.timeline_item = self;
		
		return self;
	} #endregion
}

function timelineItemGroup() : timelineItem() constructor {
	name = "";
	renaming = false;
	tb_name  = new textBox(TEXTBOX_INPUT.text, function(val) { name = val; renaming = false; });
	
	contents = [];
	
	static rename = function() {
		renaming = true;
		tb_name.setFocusHover(true, true);
		run_in(1, function() { tb_name.activate(); });
	}
	
	static drawLabel = function(_x, _y, _w, _msx, _msy, hover, focus, itHover, fdHover, nameType, alpha) { #region
		var lx  = _x + ui(2);
		var lh  = ui(20);
		var res = 0;
		var cc  = colorMultiply(color, COLORS.panel_animation_dope_bg);
		
		if(hover && point_in_rectangle(_msx, _msy, _x + ui(20), _y, _x + _w, _y + lh)) {
			cc  = colorMultiply(color, COLORS.panel_animation_dope_bg_hover);
			res = 1;
		}
		
		draw_sprite_stretched_ext(THEME.timeline_folder, 0, _x, _y, _w, lh, cc, alpha);
		draw_sprite_stretched_ext(THEME.timeline_folder, 1, _x, _y, _w, lh, fdHover == self? COLORS._main_accent : COLORS.panel_animation_node_outline, 1);
		
		if(hover && point_in_rectangle(_msx, _msy, lx, _y, lx + ui(20), _y + lh)) {
			draw_sprite_ui_uniform(THEME.arrow, show? 3 : 0, lx + ui(10), _y + lh / 2, 1, COLORS._main_icon_light, 1);
			if(mouse_press(mb_left, focus)) show = !show;
		} else
			draw_sprite_ui_uniform(THEME.arrow, show? 3 : 0, lx + ui(10), _y + lh / 2, 1, COLORS._main_icon, 0.75);
		
		draw_set_text(f_p3, fa_left, fa_center);
		
		if(renaming) {
			var _param = new widgetParam(lx + ui(20), _y + ui(2), _w - ui(24), lh - ui(4), name,, [ _msx, _msy ]);
			tb_name.setFont(f_p3);
			tb_name.setFocusHover(focus, hover);
			tb_name.drawParam(_param);
		} else {
			draw_set_color(itHover == self? COLORS._main_text_accent : COLORS._main_text);
			draw_text_add(lx + ui(20), _y + lh / 2 - ui(2), name);
		}
		
		return res;
	} #endregion
	
	static addItem = function(_item) { #region
		array_push(contents, _item);
		_item.parent = self;
		
		return self;
	} #endregion
	
	static serialize = function() { #region
		var _map = {};
		
		_map.type  = "Folder";
		_map.name  = name;
		_map.show  = show;
		_map.color = color;
		
		var _content = array_create(array_length(contents));
		for( var i = 0, n = array_length(contents); i < n; i++ )
			_content[i] = contents[i].serialize();
		_map.contents = _content;
		
		return _map;
	} #endregion
	
	static deserialize = function(_map) { #region
		color = _map.color;
		name  = struct_try_get(_map, "name", "");
		show  = struct_try_get(_map, "show", true);
		
		contents = array_create(array_length(_map.contents));
		for( var i = 0, n = array_length(_map.contents); i < n; i++ ) {
			contents[i] = new timelineItem().deserialize(_map.contents[i]);
			contents[i].parent = self;
		}
			
		return self;
	} #endregion
}