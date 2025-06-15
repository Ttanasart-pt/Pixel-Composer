function Panel_Nodes() : PanelContent() constructor {
	context_str = "Nodes";
	auto_pin = true;
	title    = __txt("Nodes");
	w        = ui(320);
	h        = ui(480);
	
	search_string = "";
	
	tb_search = textBox_Text(function(str) /*=>*/ { search_string = string(str); })
					.setFont(f_p3)
					.setAlign(fa_left)
					.setAutoupdate()
					.setBoxColor(COLORS._main_icon_light);
	
	node_hovering = noone;
	
    global.menuItems_node_context_menu = [
    	"graph_add_node", 
	];
    
	
	////- Draw
	
	function drawNodeTree(_item, _x0, _x1, _y, _m, _bg = true) {
		var sw    = sc_nodes.surface_w;
		var sh    = sc_nodes.surface_h;
		
		var hover = sc_nodes.hover;
		var focus = sc_nodes.active;
		
		var hg = ui(20);
		var _h = 0;
		var _w = _x1 - _x0;
		
		var node = _item.node;
		var name = node.getDisplayName();
		
		var heig = _item.expanded? _item.height : 1;
		var bhg  = heig * hg + ui(2) * max(0, heig - 1);
			
		_item.x = _x0;
		_item.y = _y;
			
		if(_bg) draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y, _w, bhg, COLORS.panel_inspector_group_bg, 1);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x0, _y, _x1, _y + hg)) {
			node_hovering = node;
			sc_nodes.hover_content = true;
			draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y, _w, hg, COLORS.panel_inspector_group_hover, 1);
			
			if(focus) {
				if(_m[0] < _x0 + hg + ui(4)) {
					if(mouse_lpress()) _item.expanded = !_item.expanded;
					
				} else if(_m[0] < _x1 - ui(32)) {
					if(DOUBLE_CLICK)
						PANEL_PREVIEW.setNodePreview(node);
						
					else if(mouse_lpress()) {
						PANEL_INSPECTOR.setInspecting(node);
						
						if(key_mod_press(SHIFT))
							array_toggle(PANEL_GRAPH.nodes_selecting, node);
						else
							PANEL_GRAPH.nodes_selecting = [ node ];
					} 
				}
			}
		}
		
		var bw = ui(24);
		var bh = hg;
		var bx = _x1 - bw;
		var by = _y;
		var bt = __txtx("panel_node_goto", "Go to node");
		
		if(buttonInstant(noone, bx, by, bw, bh, _m, hover, focus, bt, THEME.animate_prop_go, 0, COLORS._main_icon, 0.75) == 2)
			graphFocusNode(node);
		bx -= ui(32);
		
		var _n  = ALL_NODES[$ instanceof(node)];
		var spr = _n.spr;
		var _ss = (hg - ui(8)) / sprite_get_height(spr);
		gpu_set_tex_filter(true);
		draw_sprite_ext(spr, 1, _x0 + ui(4) + hg / 2, _y + hg / 2, _ss, _ss, 0, c_white, _item.expanded? 1 : .5);
		gpu_set_tex_filter(false);
		
		var sel = array_exists(PANEL_GRAPH.nodes_selecting, node);
		var tc  = sel? COLORS._main_text_accent : COLORS._main_text;
		draw_set_text(f_p4, fa_left, fa_center, tc);
		draw_text_add(_x0 + hg + ui(8), _y + hg / 2, name);
		
		var _y0  = _y;
		_y += hg + ui(2);
		_h += hg + ui(2);
		
		if(_item.expanded) {
			var _len = array_length(_item.children);
			var _stk = _len == 1;
			var _xx0 = _stk? _x0 : _x0 + ui(8);
			
			for( var i = 0; i < _len; i++ ) {
				var _hhg = drawNodeTree(_item.children[i], _xx0, _x1, _y, _m, !_stk);
				
				_y += _hhg;
				_h += _hhg;
			}
			
			if(_len > 1) {
				var cc = merge_color(COLORS._main_icon, COLORS._main_icon_dark, .5);
				
				for( var i = 0; i < _len; i++ ) {
					var _chd = _item.children[i];
					var _cx0 = _x0 + ui(4);
					var _cy0 = _y0 + bhg;
					var _cx1 = _chd.x;
					var _cy1 = _chd.y + hg / 2;
					
					draw_sprite_stretched_ext(THEME.corner_r4, 0, _cx0, _cy0, _cx1 - _cx0, _cy1 - _cy0, cc);
				}
				
			}
		}
		
		return _h;
	}
	
	sc_nodes = new scrollPane(w - padding * 2, h - padding * 2 + ui(40), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _ch = PROJECT.nodeTree.children;
		var _h  = 0;
		
		node_hovering = noone;
		
		for( var i = 0, n = array_length(_ch); i < n; i++ ) {
			var _hhg = drawNodeTree(_ch[i], 0, sc_nodes.surface_w, _y, _m);
			
			_h += _hhg;
			_y += _hhg;
		}
		
		return _h + ui(16);
	});

	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		var th = ui(-8)//ui(24);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		// tb_search.setFocusHover(pFOCUS, pHOVER);
		// tb_search.draw(px, py, pw, th, search_string, [mx, my]);
		
		sc_nodes.verify(pw, ph - (th + ui(8)));
		sc_nodes.setFocusHover(pFOCUS, pHOVER);
		sc_nodes.drawOffset(px, py + (th + ui(8)), mx, my);
		
		if(mouse_rclick(pFOCUS)) menuCall("node_context_menu", menuItems_gen("node_context_menu"));
	}
}