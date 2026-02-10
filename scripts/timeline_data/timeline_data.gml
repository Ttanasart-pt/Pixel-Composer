function timelineItem() constructor { 
	h = ui(20);
	
	show   = true;
	active = true;
	
	color     = -1;
	color_cur = CDEF.main_grey;
	color_dsp = -1;
	parent    = noone;
	
	static setColor  = function(c) /*=>*/ { color  = c; return self; }
	static setParent = function(p) /*=>*/ { parent = p; return self; }
	
	static getColor  = function() /*=>*/ {return color};
	
	static drawLabel         = function(_x, _y, _w, _msx, _msy) {}
	static drawDopesheet     = function(_x, _y, _s, _msx, _msy) {}
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {}
	
	static removeSelf = function() {
		if(parent == noone) return;
		array_remove(parent.contents, self);
		return self;
	}
	
	static onSerialize = function(_map) {}
	static serialize   = function() {}
	
	static onDeserialize = function(_map) {}
	static deserialize   = function(_map) {
		
		switch(_map.type) {
			case "Folder" : return new timelineItemGroup().deserialize(_map);
			case "Node"   : return new timelineItemNode(noone).deserialize(_map);
			
			case "timelineItemGroup_Canvas" :			return new timelineItemGroup_Canvas().deserialize(_map);
			
			case "timelineItemNode_Canvas" :			return new timelineItemNode_Canvas(noone).deserialize(_map);
			case "timelineItemNode_Image_Animated" :	return new timelineItemNode_Image_Animated(noone).deserialize(_map);
			case "timelineItemNode_Sequence_Anim" : 	return new timelineItemNode_Sequence_Anim(noone).deserialize(_map);
			case "timelineItemNode_Image_gif" : 		return new timelineItemNode_Image_gif(noone).deserialize(_map);
			case "timelineItemNode_MKDialog" : 		    return new timelineItemNode_MKDialog(noone).deserialize(_map);
		}
		
		return self;
	}
}

function timelineItemNode(_node) : timelineItem() constructor {
	node = _node;
	
	static drawLabel = function(_item, _x, _y, _w, _msx, _msy, hover, focus, itHover, fdHover, nameType, alpha = 1) {
		var _sel = node.is_selecting;
		var _m = [ _msx, _msy ];
		
		var lx = _x + _item.depth * ui(12) + ui(2);
		var lw = _w - _item.depth * ui(12) - ui(4);
		
		var lh  = ui(20);
		var res = 0;
		var col = getColor();
		var cxt = _item.contexts;
		if(col == -1)
		for( var i = array_length(cxt) - 1; i >= 0; i-- ) {
			var _context = cxt[i];
			var _c = _context.item.getColor();
			if(_c == -1) continue;
			
			col = _c;
			break;
		}
		
		if(col == -1) col = merge_color(CDEF.main_ltgrey, CDEF.main_white, 0.3);
		color_cur = col;
		
		var cc = colorMultiply(col, COLORS.panel_animation_dope_bg);
		color_dsp = cc;
		
		////- =Draw BG
		
		draw_sprite_stretched_ext(THEME.box_r2, 0, _x, _y, _w, lh, cc, alpha);
		if(_sel) draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_accent, 1);
		
		if(hover && point_in_rectangle(_msx, _msy, _x + ui(20), _y, _x + _w, _y + lh - 1)) {
			draw_sprite_stretched_add(THEME.box_r2, 1, _x, _y, _w, lh, col, 0.3);
			if(mouse_press(mb_left, focus)) {
				if(key_mod_press(SHIFT)) array_toggle(PANEL_GRAPH.nodes_selecting, node);
				else graphFocusNode(node, false);
			}
			
			res = 1;
		}
		
		////- =Left Buttons
		
		var bx = lx;
		var by = _y;
		var bs = ui(16);
		
		var aa = 0.75;
		if(hover && point_in_rectangle(_msx, _msy, bx, by, bx + bs, by + lh)) {
			aa = 1;
			if(DOUBLE_CLICK) {
				if(show) panel_animation_dopesheet_expand();
				else     panel_animation_dopesheet_collapse();
				
			} else if(mouse_press(mb_left, focus)) show = !show;
		}
		
		if(node.isActiveDynamic())
			draw_sprite_ui_uniform(THEME.arrow, show? 3 : 0, bx + bs / 2, by + lh / 2, 1, col == -1? CDEF.main_grey : col, aa);
		bx += bs + 1;
		
		var ii = node.attributes.timeline_hide;
		var tt = __txt("Hide");
		var cc = ii? COLORS._main_icon : COLORS._main_icon_light;
		
		if(buttonInstant(noone, bx, by, bs, lh, _m, hover, focus, tt, THEME.timeline_hide, ii, cc, .5, .75) == 2)
			node.attributes.timeline_hide = !node.attributes.timeline_hide;
		bx += bs + 1;
		
		////- =Name
		
		draw_set_text(f_p3, fa_left, fa_center);
		var nodeName = $"[{node.name}] ";
		var tw = string_width(nodeName);
		
		draw_set_color(itHover == self? COLORS._main_text_accent : COLORS._main_text);
		var txx = bx + ui(2);
			
		if(nameType == 0 || nameType == 1 || !node.renamed) {
			draw_set_alpha(0.6);
			draw_text_add(txx, _y + lh / 2 - ui(2), nodeName);
			txx += tw;
		}
		
		draw_set_font(f_p3);
		draw_set_alpha(1);
		if(nameType == 0 || nameType == 2) 
			draw_text_add(txx, _y + lh / 2 - ui(2), node.display_name);
		
		////- =Right Buttons
		
		var tx = lx + lw - ui(7);
		var tt = __txtx("panel_animation_goto", "Go to node");
		
		if(buttonInstant(noone, tx - ui(9), _y + ui(1), ui(18), ui(18), _m, hover, focus, tt, THEME.animate_node_go, 0, col == -1? COLORS._main_icon_light : col, 0.4) == 2)
			graphFocusNode(node);
			
		return res;
	}
	
	static drawDopesheetOutput = function(_x, _y, _s, _msx, _msy) { return;
		var _surf = node.outputs[0].getValue();
		if(!is_surface(_surf)) return;
		
		var _h  = h - 2;
		var _rx = _x + (GLOBAL_CURRENT_FRAME + 1) * _s;
		var _ry = h / 2 + _y;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		var _ss = _h / max(_sw, _sh);
		
		// draw_sprite_stretched_ext(THEME.box_r2, 0, _rx - h / 2, _ry - h / 2, h, h, CDEF.main_dkblack);
		draw_surface_ext(_surf, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
		
		// draw_sprite_stretched_ext(THEME.box_r2, 1, _rx - h / 2, _ry - h / 2, h, h, CDEF.main_dkgrey);
	}
	
	static setColor = function(color) { node.attributes.color = color; }
	static getColor = function()      { return node.attributes.color; }
	
	static serialize   = function() {
		var _map = {};
		
		_map.type    = "Node";
		_map.show    = show;
		_map.node_id = is_struct(node)? node.node_id : -4;
		onSerialize(_map);
		
		return _map;
	}
	
	static deserialize   = function(_map) {
		show  = struct_try_get(_map, "show", true);
		
		var _node_id = _map.node_id;
		
		if(_node_id == 0) {
			node = PROJECT.globalNode;
			node.timeline_item = self;
		} else if(ds_map_exists(PROJECT.nodeMap, _node_id)) {
			node = PROJECT.nodeMap[? _node_id];
			node.timeline_item = self;
		}
		
		onDeserialize(_map);
		
		return self;
	}
}

function timelineItemGroup() : timelineItem() constructor {
	name          = "";
	renaming      = false;
	timeline_hide = false;
	
	tb_name         = new textBox(TEXTBOX_INPUT.text, function(val) /*=>*/ { name = val; renaming = false; });
	tb_name.padding = ui(4);
	tb_name.hide    = 2;
	
	contents = [];
	
	static rename = function() {
		renaming = true;
		tb_name.setFocusHover(true, true);
		run_in(1, function() /*=>*/ { tb_name._current_text = name; tb_name.activate(); });
	}
	
	static drawLabel = function(_item, _x, _y, _w, _msx, _msy, hover, focus, itHover, fdHover, nameType, alpha = 1) {
		var lx = _x + _item.depth * ui(12) + ui(2);
		var lw = _w - _item.depth * ui(12) - ui(4);
		var _m = [ _msx, _msy ];
		
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
		
		////- =Draw BG
		
		var bnd = hig? merge_color(c_white, COLORS.panel_animation_dope_bg, .9) : COLORS.panel_animation_dope_bg_hover;
		var cc  = colorMultiply(col, bnd);
		color_dsp = cc;
		draw_sprite_stretched_ext(THEME.box_r2, 0, _x, _y, _w, lh, cc, alpha);
		
		if(hover && point_in_rectangle(_msx, _msy, _x + ui(20), _y, _x + _w, _y + lh - 1)) {
			draw_sprite_stretched_add(THEME.box_r2, 0, _x, _y, _w, lh, col, 0.05);
			res = 1;
		}
		
		draw_sprite_stretched_add(THEME.box_r2, 1, _x, _y, _w, lh, c_white, 0.15);
		if(fdHover == self)
			draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y + 1, _w, lh - 2, col == -1? COLORS._main_accent : col, 1);
		
		////- =Left Buttons
		
		var bx = lx;
		var by = _y;
		var bs = ui(16);
		
		var aa = 0.75;
		if(hover && point_in_rectangle(_msx, _msy, bx, by, bx + bs, by + lh)) {
			aa = 1;
			if(DOUBLE_CLICK) {
				if(show) panel_animation_dopesheet_expand();
				else     panel_animation_dopesheet_collapse();
				
			} else if(mouse_press(mb_left, focus)) show = !show;
		}
		draw_sprite_ui_uniform(THEME.folder_16, show, bx + bs / 2, by + lh / 2, 1, col == -1? CDEF.main_grey : col, aa);
		bx += bs + 1;
		
		var ii = timeline_hide;
		var tt = __txt("Hide");
		var cc = ii? COLORS._main_icon : COLORS._main_icon_light;
		
		if(buttonInstant(noone, bx, by, bs, lh, _m, hover, focus, tt, THEME.timeline_hide, ii, cc, .5, .75) == 2)
			timeline_hide = !timeline_hide;
		bx += bs + 1;
		
		////- =Name
		
		var txx = bx + ui(2);
		
		if(hover && point_in_rectangle(_msx, _msy, txx, _y, _x + _w, _y + lh - 1)) { // rename
			if(focus && DOUBLE_CLICK)
				rename();
		}
		
		draw_set_text(f_p3, fa_left, fa_center);
		if(renaming) {
			var _param = new widgetParam(txx - ui(4), _y + ui(2), _w - ui(24), lh - ui(4), name,, [ _msx, _msy ]);
			    _param.font = f_p3;
			
			tb_name.highlight_color = cc;
			tb_name.highlight_alpha = .5;
			
			tb_name.setFocusHover(focus, hover);
			tb_name.drawParam(_param);
		} else {
			draw_set_color(itHover == self? COLORS._main_text_accent : COLORS._main_text);
			draw_text_add(txx, _y + lh / 2, name);
		}
		
		return res;
	}
	
	static addItem = function(_item) {
		array_push(contents, _item);
		_item.parent = self;
		
		return self;
	}
	
	static destroy = function() {
		var ind = array_find(parent.contents, self);
		array_delete(parent.contents, ind, 1);
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			array_insert(parent.contents, ind++, contents[i]);
			contents[i].parent = parent;
		}
	}
	
	static serialize = function() {
		var _map = {};
		
		_map.type  = "Folder";
		_map.name  = name;
		_map.show  = show;
		_map.color = color;
		_map.timeline_hide = timeline_hide;
		
		var len      = array_length(contents);
		var _content = array_create(len);
		
		for( var i = 0; i < len; i++ )
			_content[i] = contents[i].serialize();
			
		_map.contents = _content;
		onSerialize(_map);
		
		return _map;
	}
	
	static deserialize = function(_map) {
		color         = _map.color;
		name          = _map[$ "name"] ?? "";
		show          = _map[$ "show"] ?? true;
		timeline_hide = _map[$ "timeline_hide"] ?? false;
		
		contents = [];
		
		for( var i = 0, n = array_length(_map.contents); i < n; i++ ) {
			var _con = _map.contents[i];
			if(!is_struct(_con)) continue;
			array_push(contents, new timelineItem().deserialize(_con).setParent(self));
		}
		
		onDeserialize(_map);
			
		return self;
	}
}