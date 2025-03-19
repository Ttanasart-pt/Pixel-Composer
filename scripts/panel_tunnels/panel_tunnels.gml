function Panel_Tunnels() : PanelContent() constructor {
	title   = __txt("Tunnels");
	
	w = ui(320);
	h = ui(480);
	
	build_x = 0;
	build_y = 0;
	
	tunnel_ins    = [];
	tunnel_select = noone;
	tunnel_hover  = noone;
	
	function scanNodes() {
		tunnel_ins = [];
		
		for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
			var node = PROJECT.allNodes[i];
			
			if(is(node, Node_Tunnel_In)) 
				array_push(tunnel_ins, node);
		}
	}
	scanNodes();
	
	search_string     = "";
	keyboard_lastchar = "";
	keyboard_lastkey  = -1;
	KEYBOARD_STRING   = "";
	
	search_res = [];
	tb_search = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ { search_string = string(s); searchNodes(); });
	
	tb_search.align			= fa_left;
	tb_search.auto_update	= true;
	tb_search.boxColor		= COLORS._main_icon_light;
	WIDGET_CURRENT			= tb_search;
	
	function searchNodes() {
		search_res = [];
		for( var i = 0, n = array_length(tunnel_ins); i < n; i++ ) {
			var node = tunnel_ins[i];
			var key  = node.inputs[0].getValue(0);
		
			if(string_pos(search_string, key) == 0) continue;
			array_push(search_res, node);
		}
	}
	
	function onResize() { sc_tunnel.resize(w - padding * 2, h - padding * 2 - ui(28 + 40)); }
	
	sc_tunnel = new scrollPane(w - padding * 2, h - padding * 2 - ui(28 + 40), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = 0;
		var ww = sc_tunnel.surface_w;
		var hg = ui(36);
		var i  = 0;
		
		var arr = search_string == ""? tunnel_ins : search_res;
		tunnel_hover  = noone;
	
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var node = arr[i];

			if(point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + hg)) {
				sc_tunnel.hover_content = true;
				var cc = merge_color(COLORS._main_icon_light, COLORS._main_icon, 0.25);
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, cc, 1);
				tunnel_hover  = node;
			
				if(mouse_press(mb_left, sc_tunnel.active) && _m[0] < ww - ui(32 + 32 * 2)) 
					tunnel_select = tunnel_select == node? noone : node;
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, COLORS._main_icon_light, 1);
			draw_sprite_stretched_add(THEME.ui_panel, 1, 0, _y, ww, hg, c_white, .1);
			
			var key = node.inputs[0].getValue(0);
			var bw = ui(28);
			var bh = ui(28);
			var bx = ww - ui(4) - bw;
			var by = _y + (hg - bh) / 2;
			var _txt = __txtx("panel_node_goto", "Go to node");
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bw, bh, _m, sc_tunnel.hover, sc_tunnel.active, _txt, THEME.node_goto) == 2)
				graphFocusNode(node);
			bx -= ui(32);
			
			_txt = __txtx("panel_tunnel_create_tunnel", "Create Receiver");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bw, bh, _m, sc_tunnel.hover, sc_tunnel.active, _txt, THEME.tunnel, 1) == 2) {
				var _node = nodeBuild("Node_Tunnel_Out", build_x, build_y - 8);
				_node.inputs[0].setValue(key);
			}
			bx -= ui(32);
		
			draw_sprite_ui(THEME.tunnel, 0, ui(4 + 16), _y + hg / 2);
			draw_set_text(f_p2, fa_left, fa_center, key == ""? COLORS._main_text_sub : COLORS._main_text);
			draw_text_add(ui(4 + 32 + 4), _y + hg / 2, key == ""? $"[{__txtx("panel_tunnel_no_key", "No key")}]" : key);
		
			_y += hg + ui(4);
			_h += hg + ui(4);
		
			if(tunnel_select == node) {
				var amo = ds_map_size(PROJECT.tunnels_out);
				var k   = ds_map_find_first(PROJECT.tunnels_out);
				
				repeat(amo) { 
					var _k  = k;
					k = ds_map_find_next(PROJECT.tunnels_out, k);
				
					var out = PROJECT.tunnels_out[? _k];
					if(out != key || !ds_map_exists(PROJECT.nodeMap, _k)) 
						continue;
					
					var _node = PROJECT.nodeMap[? _k];
					
					draw_sprite_ui(THEME.tunnel, 0, ui(32), _y + ui(10), 0.75, 0.75, 0, COLORS._main_icon);
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(ui(32 + 16), _y + ui(10), _node.renamed? _node.display_name : _node.name);
					
					if(point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + ui(20))) 
						tunnel_hover  = _node;
				
					_y += ui(20);
					_h += ui(20);
				}
			
				_y += ui(8);
				_h += ui(8);
			}
		}
	
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		scanNodes();
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2 - ui(28);
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(px, py, pw, ui(32), search_string, [mx, my]);
		if(search_string == "") tb_search.sprite_index = 1;
	
		sc_tunnel.setFocusHover(pFOCUS, pHOVER);
		sc_tunnel.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
		
		var _add_h = ui(24);
		var _bx    = sp;
		var _by    = h - _add_h - sp;
		var _ww    = w - sp * 2;
		var _hov   = pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + _ww, _by + _add_h);
		
		draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .3 + _hov * .1);
		draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .6 + _hov * .25);
		draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon);
		draw_text_add(_ww / 2, _by + _add_h / 2, __txtx("panel_tunnel_create_tunnel", "Create tunnel"));
		
		if(mouse_press(mb_left, pFOCUS && _hov))
			nodeBuild("Node_Tunnel_In", build_x, build_y - 8);
	}
}