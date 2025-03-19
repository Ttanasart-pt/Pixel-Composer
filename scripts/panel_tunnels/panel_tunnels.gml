function Panel_Tunnels() : PanelContent() constructor {
	title    = __txt("Tunnels");
	auto_pin = true;
	
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
	tb_search  = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ { search_string = string(s); searchNodes(); })
					.setEmpty()
					.setAlign(fa_left)
					.setBoxColor(COLORS._main_icon_light)
					.setAutoUpdate();
	
	WIDGET_CURRENT = tb_search;
	
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
		var bs = ui(28);
		var _txt;
		
		var arr = search_string == ""? tunnel_ins : search_res;
		tunnel_hover  = noone;
		
		var _delc = [ COLORS._main_icon, COLORS._main_value_negative ];
		var _hov  = sc_tunnel.hover;
		var _foc  = sc_tunnel.active;
		var _delNode = noone;
		
		var _tout = ds_map_keys_to_array(PROJECT.tunnels_out);
		
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var node = arr[i];
			if(!node.active) continue;

			if(point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + hg)) {
				sc_tunnel.hover_content = true;
				var cc = merge_color(COLORS._main_icon_light, COLORS._main_icon, 0.25);
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, cc, 1);
				tunnel_hover  = node;
			
				if(mouse_press(mb_left, sc_tunnel.active) && _m[0] < ww - ui(32 * 3)) 
					node.open = !node.open;
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y, ww, hg, COLORS._main_icon_light, 1);
			draw_sprite_stretched_add(THEME.ui_panel, 1, 0, _y, ww, hg, c_white, .1);
			
			var key = node.inputs[0].getValue(0);
			var col = node.inputs[1].color_display;
			
			var bx = ww - ui(4) - bs;
			var by = _y + (hg - bs) / 2;
			
			_txt = __txtx("panel_node_delete", "Delete Node");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hov, _foc, _txt, THEME.cross, 0, _delc) == 2)
				_delNode = node;
			bx -= bs + ui(4);
			
			_txt = __txtx("panel_node_goto", "Go to Node");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hov, _foc, _txt, THEME.node_goto) == 2)
				graphFocusNode(node);
			bx -= bs + ui(4);
			
			_txt = __txtx("panel_tunnel_create_tunnel", "Create Receiver");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hov, _foc, _txt, THEME.tunnel_create, 0, [ c_white, COLORS._main_value_positive ]) == 2) {
				var _nx = node.x + 160;
				var _ny = PANEL_GRAPH.getFreeY(_nx, node.y);
				    
				var _recNode = nodeBuild("Node_Tunnel_Out", _nx, _ny);
				_recNode.inputs[0].setValue(key);
			}
			bx -= bs + ui(4);
			
			var _tx = ui(4 + 32 + 4);
			var _ty = _y + hg / 2;
			var _tt = key == ""? $"[{__txtx("panel_tunnel_no_key", "No key")}]" : key;
			
			draw_sprite_ui(THEME.tunnel, 0, ui(4 + 16), _y + hg / 2, 1, 1, 0, col, .5 + node.open * .5);
			draw_set_text(f_p2, fa_left, fa_center, key == ""? COLORS._main_text_sub : COLORS._main_text);
			draw_text_add(_tx, _ty, _tt);
			_tx += string_width(_tt) + ui(4);
			
			var _amo = array_length(node.receivers);
			draw_set_color(COLORS._main_text_sub);
			draw_text_add(_tx, _ty, $"[{_amo}]");
			
			_y += hg + ui(4);
			_h += hg + ui(4);
		
			if(!node.open) continue;
			
			for( var j = 0, m = array_length(_tout); j < m; j++ ) {
				var k   = _tout[j];
				var out = PROJECT.tunnels_out[? k];
				if(out != key || !ds_map_exists(PROJECT.nodeMap, k)) continue;
				
				var _recNode = PROJECT.nodeMap[? k];
				if(!_recNode.active) continue;
				
				var hv = _hov && point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + ui(20));
				if(hv) tunnel_hover = _recNode;
				
				draw_sprite_ui(THEME.tunnel, 1, ui(32), _y + ui(10), 0.75, 0.75, 0, col, .5 + .5 * hv);
				draw_set_text(f_p2, fa_left, fa_center, hv? COLORS._main_text : COLORS._main_text_sub);
				draw_text_add(ui(32 + 16), _y + ui(10), _recNode.renamed? _recNode.display_name : _recNode.name);
				
				var bbs = ui(16);
				var bx = ww - ui(8) - bbs;
				var by = _y + (ui(20) - bbs) / 2;
				
				_txt = __txtx("panel_node_delete", "Delete Node");
				if(buttonInstant(noone, bx, by, bbs, bbs, _m, _hov, _foc, _txt, THEME.cross_16, 0, _delc, .5) == 2)
					_recNode.destroy();
				bx -= bbs + ui(4);
				
				_txt = __txtx("panel_node_goto", "Go to Node");
				if(buttonInstant(noone, bx, by, bbs, bbs, _m, _hov, _foc, _txt, THEME.node_goto_16, 0, COLORS._main_icon, .5) == 2)
					graphFocusNode(_recNode);
				bx -= bbs + ui(4);
				
				_y += ui(20);
				_h += ui(20);
			}
			
			_y += ui(8);
			_h += ui(8);
		}
		
		if(_delNode != noone) {
			var key = _delNode.inputs[0].getValue(0);
			var _jf = _delNode.inputs[1].value_from;
			
			for( var i = 0, n = array_length(_tout); i < n; i++ ) {
				var k   = _tout[i];
				var out = PROJECT.tunnels_out[? k];
				if(out != key || !ds_map_exists(PROJECT.nodeMap, k)) continue;
				
				var _recNode = PROJECT.nodeMap[? k];
				if(!_recNode.active) continue;
				
				var _tos = _recNode.outputs[0].getJunctionTo();
				for( var j = 0, m = array_length(_tos); j < m; j++ )
					_tos[j].setFrom(_jf);
				
				_recNode.destroy();
			}
			
			_delNode.destroy();
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