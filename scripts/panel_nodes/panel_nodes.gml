function Panel_Nodes() : PanelContent() constructor {
	#region data
		title = __txt("Nodes");
		showHeader  = false;
		
		w = ui(320);
		h = ui(480);
		
		title_height = 64;
		padding = 24;
		
		search_string = "";
		
		tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
			search_string = string(str); 
		});
		tb_search.align			= fa_left;
		tb_search.auto_update	= true;
		tb_search.boxColor		= COLORS._main_icon_light;
		
		node_collapse = ds_map_create();
	#endregion

	function onResize() {
		sc_nodes.resize(w - ui(padding + padding), h - ui(padding + title_height + 40));
	}
	
	function drawNodeList(_list, _x0, _x1, _y, _m) {
		var ww  = sc_nodes.surface_w;
		var hg  = ui(28);
		
		var _h  = 0;
		
		for( var i = 0; i < ds_list_size(_list); i++ ) {
			var node = _list[| i];
			var name = node.display_name == ""? node.name : node.display_name;
			
			if(string_lower(search_string) != "" && string_lower(string_pos(search_string, name)) == 0)
				continue;
			
			var isGroup = struct_has(node, "nodes");
			if(isGroup && !ds_map_exists(node_collapse, node.node_id)) 
				node_collapse[? node.node_id] = false;
			
			if(pHOVER && point_in_rectangle(_m[0], _m[1], _x0, _y, _x1 - _x0 - ui(32), _y + hg)) {
				var cc = merge_color(COLORS._main_icon_light, COLORS._main_icon, 0.25);
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x0, _y, _x1 - _x0, hg, cc, 1);
				
				if(sc_nodes.active) {
					if(DOUBLE_CLICK)
						PANEL_PREVIEW.setNodePreview(node);
					else if(mouse_press(mb_left)) {
						if(isGroup)
							node_collapse[? node.node_id] = !node_collapse[? node.node_id];
						if(!PANEL_INSPECTOR.locked)
							PANEL_INSPECTOR.inspecting = node;
						ds_list_clear(PANEL_GRAPH.nodes_select_list);
						PANEL_GRAPH.node_focus = node;
					} 
				}
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _x0, _y, _x1 - _x0, hg, COLORS._main_icon_light, 1);
			
			var bw = ui(24);
			var bh = ui(24);
			var bx = _x1 - ui(4) - bw;
			var by = _y + (hg - bh) / 2;
			
			if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, sc_nodes.active, sc_nodes.hover, __txtx("panel_node_goto", "Go to node"), THEME.node_goto,, COLORS._main_icon, 0.75, 0.75) == 2)
				graphFocusNode(node);
			bx -= ui(32);
			
			var _n  = ALL_NODES[? instanceof(node)];
			var spr = _n.spr;
			draw_sprite_ui(spr, 1, _x0 + ui(4 + 16), _y + hg / 2, 0.5, 0.5, 0, c_white, 0.75);
			var cc  = COLORS._main_text;
			draw_set_text(f_p1, fa_left, fa_center, cc);
			draw_text(_x0 + hg + ui(8) + (isGroup * ui(20)), _y + hg / 2, name);
			if(isGroup)
				draw_sprite_ui(THEME.arrow, node_collapse[? node.node_id] * 3, _x0 + hg + ui(16), _y + hg / 2,,,,, 0.75);
			
			_y += hg + ui(4);
			_h += hg + ui(4);
			
			if(isGroup && !node_collapse[? node.node_id]) {
				var hh = drawNodeList(node.nodes, _x0 + ui(16), _x1, _y, _m);
				_y += hh + ui(4);
				_h += hh + ui(4);
			}
		}
		
		return _h;
	}
	
	#region content
		sc_nodes = new scrollPane(w - ui(padding + padding), h - ui(title_height + padding + 40), function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear, 0);
			var _h = drawNodeList(NODES, 0, sc_nodes.surface_w, _y, _m);
			return _h;
		})
	#endregion

	function drawContent(panel) {
		PANEL_PADDING
		PANEL_TITLE
		
		var px = ui(padding);
		var py = ui(title_height);
		var pw = w - ui(padding + padding);
		var ph = h - ui(title_height + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, !in_dialog, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		tb_search.setActiveFocus(pFOCUS, pHOVER);
		tb_search.draw(px, py, pw, ui(32), search_string, [mx, my]);
		
		sc_nodes.setActiveFocus(pFOCUS, pHOVER);
		sc_nodes.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
		
		//var bx = w - ui(32 + 16);
		//var by = title_height / 2 - ui(16 + !in_dialog * 2);
			
		//if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Create tunnel", THEME.tunnel, 1, c_white) == 2) {
		//	nodeBuild("Node_Tunnel_In", build_x, build_y);
		//	instance_destroy();
		//}
	}
}