function timelineItem() constructor { 
	show   = true;
	active = true;
	
	color     = -1;
	color_cur = CDEF.main_grey;
	color_dsp = -1;
	parent    = noone;
	
	static setColor = function(color) { self.color = color; }
	static getColor = function()      { return color; }
	
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
	
	static drawLabel = function(_item, _x, _y, _w, _msx, _msy, hover, focus, itHover, fdHover, nameType, alpha = 1) { #region
		var _sel = node == PANEL_INSPECTOR.getInspecting();
		
		var lx = _x + _item.depth * ui(12) + ui(2);
		var lw = _w - _item.depth * ui(12) - ui(4);
		
		var lh  = ui(20);
		var res = 0;
		var col = getColor();
		var cxt = _item.contexts;
		if(col == -1)
		for( var i = array_length(cxt) - 1; i >= 0; i-- ) {
			var _context = cxt[i];
			if(_context.item.getColor() == -1) continue;
			col = _context.item.getColor();
			break;
		}
		if(col == -1) col = CDEF.main_grey;
		color_cur = col;
		
		var cc  = colorMultiply(col, COLORS.panel_animation_dope_bg);
		
		if(hover && point_in_rectangle(_msx, _msy, _x + ui(20), _y, _x + _w, _y + lh - 1)) {
			cc  = colorMultiply(col, COLORS.panel_animation_dope_bg_hover);
			res = 1;
		}
		
		color_dsp = cc;
		draw_sprite_stretched_ext(THEME.timeline_folder, 0, _x, _y, _w, lh, cc, alpha);
		//draw_sprite_stretched_ext(THEME.timeline_node, 1, _x, _y, _w, lh, COLORS.panel_animation_node_outline, 1);
			
		var tx = lx + lw - ui(7);
		if(buttonInstant(THEME.button_hide, tx - ui(9), _y + ui(1), ui(18), ui(18), [ _msx, _msy ], focus, hover, 
			__txtx("panel_animation_goto", "Go to node"), THEME.animate_node_go, 0, col == -1? CDEF.main_grey : col) == 2)
				graphFocusNode(node);
			
		if(_sel)
			draw_sprite_stretched_ext(THEME.timeline_node, 1, _x, _y + 1, _w, lh - 2, COLORS._main_accent, 1);
		
		var aa = 0.75;
		if(hover && point_in_rectangle(_msx, _msy, lx, _y, lx + ui(20), _y + lh)) {
			aa = 1;
			if(mouse_press(mb_left, focus)) show = !show;
		}
		draw_sprite_ui_uniform(THEME.arrow, show? 3 : 0, lx + ui(10), _y + lh / 2, 1, col == -1? CDEF.main_grey : col, aa);
		
		draw_set_text(f_p3, fa_left, fa_center);
		var nodeName = $"[{node.name}] ";
		var tw = string_width(nodeName);
		
		draw_set_color(itHover == self? COLORS._main_text_accent : COLORS._main_text);
		var txx = lx + ui(24);
			
		if(nameType == 0 || nameType == 1 || !node.renamed) {
			draw_set_alpha(0.6);
			draw_text_add(txx, _y + lh / 2 - ui(2), nodeName);
			txx += tw;
		}
		
		draw_set_font(f_p2);
		draw_set_alpha(1);
		if(nameType == 0 || nameType == 2) 
			draw_text_add(txx, _y + lh / 2 - ui(2), node.display_name);
		
		return res;
	} #endregion
	
	static setColor = function(color) { node.attributes.color = color; }
	static getColor = function()      { return node.attributes.color; }
	
	static serialize = function() { #region
		var _map = {};
		
		_map.type    = "Node";
		_map.show    = show;
		_map.node_id = is_struct(node)? node.node_id : -4;
		
		return _map;
	} #endregion
	
	static deserialize = function(_map) { #region
		show  = struct_try_get(_map, "show", true);
		
		var _node_id = _map.node_id;
		if(_node_id == 0) {
			node = PROJECT.globalNode;
			node.timeline_item = self;
		} else if(ds_map_exists(PROJECT.nodeMap, _node_id)) {
			node = PROJECT.nodeMap[? _node_id];
			node.timeline_item = self;
		}
		
		return self;
	} #endregion
}

function timelineItemGroup() : timelineItem() constructor {
	name = "";
	renaming = false;
	tb_name  = new textBox(TEXTBOX_INPUT.text, function(val) { name = val; renaming = false; });
	contents = [];
	
	static rename = function() { #region
		renaming = true;
		tb_name.setFocusHover(true, true);
		run_in(1, function() { 
			tb_name._current_text = name;
			tb_name.activate(); 
		});
	} #endregion
	
	static drawLabel = function(_item, _x, _y, _w, _msx, _msy, hover, focus, itHover, fdHover, nameType, alpha = 1) { #region
		var lx = _x + _item.depth * ui(12) + ui(2);
		var lw = _w - _item.depth * ui(12) - ui(4);
		
		var lh  = ui(20);
		var res = 0;
		var hig = true;
		var col = getColor();
		var cxt = _item.contexts;
		if(col == -1)
		for( var i = array_length(cxt) - 1; i >= 0; i-- ) {
			var _context = cxt[i];
			if(_context.item.getColor() == -1) continue;
			col = _context.item.getColor();
			hig = false;
			break;
		}
		if(col == -1) col = CDEF.main_grey;
		color_cur = col;
		
		var bnd = hig? merge_color(c_white, COLORS.panel_animation_dope_bg, 0.8) : COLORS.panel_animation_dope_bg;
		var cc  = colorMultiply(col, bnd);
		
		if(hover && point_in_rectangle(_msx, _msy, _x + ui(20), _y, _x + _w, _y + lh - 1)) {
			bnd = hig? merge_color(c_white, COLORS.panel_animation_dope_bg_hover, 0.8) : COLORS.panel_animation_dope_bg_hover;
			cc  = colorMultiply(col, bnd);
			res = 1;
		}
		
		color_dsp = cc;
		draw_sprite_stretched_ext(THEME.timeline_folder, 0, _x, _y, _w, lh, cc, alpha);
		
		if(fdHover == self)
			draw_sprite_stretched_ext(THEME.timeline_folder, 1, _x, _y, _w, lh, col == -1? COLORS._main_accent : col, 1);
		
		var aa = 0.75;
		if(hover && point_in_rectangle(_msx, _msy, lx, _y, lx + ui(20), _y + lh)) {
			aa = 1;
			if(mouse_press(mb_left, focus)) show = !show;
		}
		draw_sprite_ui_uniform(THEME.folder_16, show, lx + ui(10), _y + lh / 2, 1, col == -1? CDEF.main_grey : col, aa);
		
		draw_set_text(f_p2, fa_left, fa_center);
		if(renaming) {
			var _param = new widgetParam(lx + ui(20), _y + ui(2), _w - ui(24), lh - ui(4), name,, [ _msx, _msy ]);
			tb_name.setFont(f_p2);
			tb_name.setFocusHover(focus, hover);
			tb_name.drawParam(_param);
		} else {
			draw_set_color(itHover == self? COLORS._main_text_accent : COLORS._main_text);
			draw_text_add(lx + ui(24), _y + lh / 2 - ui(2), name);
		}
		
		return res;
	} #endregion
	
	static addItem = function(_item) { #region
		array_push(contents, _item);
		_item.parent = self;
		
		return self;
	} #endregion
	
	static destroy = function() { #region
		var ind = array_find(parent.contents, self);
		array_delete(parent.contents, ind, 1);
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			array_insert(parent.contents, ind++, contents[i]);
			contents[i].parent = parent;
		}
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