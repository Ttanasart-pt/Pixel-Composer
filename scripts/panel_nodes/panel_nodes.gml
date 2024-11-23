function Panel_Nodes() : PanelContent() constructor {
	title   = __txt("Nodes");
	padding = ui(8);
	w       = ui(320);
	h       = ui(480);
	
	search_string = "";
	
	tb_search             = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); });
	tb_search.align		  = fa_left;
	tb_search.auto_update = true;
	tb_search.boxColor	  = COLORS._main_icon_light;
	
	node_collapse = ds_map_create();

	function onResize() { sc_nodes.resize(w - ui(padding + padding), h - ui(padding + padding + 40)); }
	
	function drawNodeList(_arr, _x0, _x1, _y, _m) {
		var _hh = sc_nodes.surface_h;
		var hg  = ui(28);
		
		var _h  = 0;
		
		for( var i = 0; i < array_length(_arr); i++ ) {
			var node = _arr[i];
			var name = node.renamed? node.display_name : node.name;
			
			if(string_lower(search_string) != "" && string_pos(string_lower(search_string), string_lower(name)) == 0)
				continue;
			
			var isGroup = struct_has(node, "nodes");
			if(isGroup && !ds_map_exists(node_collapse, node.node_id)) 
				node_collapse[? node.node_id] = false;
			
			var _cull = _y + hg < 0 || _y > _hh;
			if(_cull) {
				_y += hg + ui(2);
				_h += hg + ui(2);
				
				if(isGroup && !node_collapse[? node.node_id]) {
					var hh = drawNodeList(node.nodes, _x0 + ui(16), _x1, _y, _m);
					_y += hh + ui(2);
					_h += hh + ui(2);
				}
				
				continue;
			}
			
			if(pHOVER && point_in_rectangle(_m[0], _m[1], _x0, _y, _x1 - _x0 - ui(32), _y + hg)) {
				sc_nodes.hover_content = true;
				
				var cc = merge_color(COLORS._main_icon_light, COLORS._main_icon, 0.75);
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x0, _y, _x1 - _x0, hg, cc, 1);
				
				if(sc_nodes.active) {
					if(DOUBLE_CLICK)
						PANEL_PREVIEW.setNodePreview(node);
					else if(mouse_press(mb_left)) {
						if(isGroup)
							node_collapse[? node.node_id] = !node_collapse[? node.node_id];
						PANEL_INSPECTOR.setInspecting(node);
						PANEL_GRAPH.nodes_selecting = [ node ];
					} 
				}
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x0, _y, _x1 - _x0, hg, COLORS._main_icon, 1);
			draw_sprite_stretched_add(THEME.ui_panel, 1, _x0, _y, _x1 - _x0, hg, COLORS._main_icon, .2);
			
			var bw = ui(24);
			var bh = ui(24);
			var bx = _x1 - ui(4) - bw;
			var by = _y + (hg - bh) / 2;
			
			if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, sc_nodes.active, sc_nodes.hover, __txtx("panel_node_goto", "Go to node"), THEME.node_goto,, COLORS._main_icon, 0.75, 0.75) == 2)
				graphFocusNode(node);
			bx -= ui(32);
			
			var _n  = ALL_NODES[? instanceof(node)];
			var spr = _n.spr;
			draw_sprite_ui(spr, 1, _x0 + ui(4 + 16), _y + hg / 2, 0.25, 0.25, 0, c_white, 1);
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_x0 + hg + ui(8) + (isGroup * ui(20)), _y + hg / 2, name);
			if(isGroup) draw_sprite_ui(THEME.arrow, (!node_collapse[? node.node_id]) * 3, _x0 + hg + ui(16), _y + hg / 2,,,,, 0.75);
			
			_y += hg + ui(2);
			_h += hg + ui(2);
			
			if(isGroup && !node_collapse[? node.node_id]) {
				var hh = drawNodeList(node.nodes, _x0 + ui(16), _x1, _y, _m);
				_y += hh + ui(2);
				_h += hh + ui(2);
			}
		}
		
		return _h;
	}
	
	sc_nodes = new scrollPane(w - ui(padding + padding), h - ui(padding + padding + 40), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = drawNodeList(PROJECT.nodes, 0, sc_nodes.surface_w, _y, _m);
		return _h;
	});

	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(px, py, pw, ui(32), search_string, [mx, my]);
		
		sc_nodes.setFocusHover(pFOCUS, pHOVER);
		sc_nodes.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
	}
}