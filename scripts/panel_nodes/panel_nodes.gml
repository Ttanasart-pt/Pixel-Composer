#region function calls
	function panel_nodes_add_node()        { if(PANEL_NODES == noone) return; PANEL_NODES.add_node();        }
	function panel_nodes_delete_selected() { if(PANEL_NODES == noone) return; PANEL_NODES.delete_selected(); }
	function panel_nodes_delete_hovering() { if(PANEL_NODES == noone) return; PANEL_NODES.delete_hovering(); }
	
	function panel_nodes_toggle_sidebar()  { if(PANEL_NODES == noone) return; PANEL_NODES.toggle_sidebar();  }
	function panel_nodes_toggle_preview()  { if(PANEL_NODES == noone) return; PANEL_NODES.toggle_preview();  }
	function panel_nodes_edit_sidebar()    { if(PANEL_NODES == noone) return; PANEL_NODES.edit_sidebar();    }
	
	function __fnInit_Nodes() {
		registerFunction("Nodes", "Add Node",        "",        MOD_KEY.none, panel_nodes_add_node        ).setMenu("nodes_add", THEME.add_20);
		registerFunction("Nodes", "Delete Selected", vk_delete, MOD_KEY.none, panel_nodes_delete_selected ).setMenu("nodes_delete_select");
		registerFunction("Nodes", "Delete Hovering", "",        MOD_KEY.none, panel_nodes_delete_hovering ).setMenu("nodes_delete_hovering");
		
		registerFunction("Nodes", "Toggle Preview",  "", MOD_KEY.none, panel_nodes_toggle_preview  ).setMenu("nodes_toggle_preview");
		registerFunction("Nodes", "Toggle Sidebar",  "", MOD_KEY.none, panel_nodes_toggle_sidebar  ).setMenu("nodes_toggle_sidebar");
		registerFunction("Nodes", "Edit Sidebar",    "", MOD_KEY.none, panel_nodes_edit_sidebar    ).setMenu("nodes_edit_sidebar");
	}
#endregion

function Panel_Nodes() : PanelContent() constructor {
	context_str = "Nodes";
	auto_pin    = true;
	title       = __txt("Nodes");
	w           = ui(320);
	h           = ui(480);
	
	NodeTreeSort(PROJECT);
	
	search_string = "";
	tb_search     = textBox_Text(function(str) /*=>*/ { search_string = string(str); })
					.setFont(f_p3).setAlign(fa_left).setAutoupdate()
					.setBoxColor(COLORS._main_icon_light);
	
	 node_hovering  = noone;
	_node_hovering  = noone;
	 item_hovering  = noone;
	_item_hovering  = noone;
	
	side_show       = true;
	side_scroll     = 0;
	side_scroll_to  = 0;
	side_scroll_max = 0;
	show_preview    = false;
	
	node_selecting  = noone;
	item_height     = ui(20);
	
    global.menuItems_node_context_menu = [
    	"nodes_add", 
    	"nodes_delete_select", 
    	-1, 
    	"nodes_toggle_preview",
    	"nodes_toggle_sidebar", 
	];
	
    global.menuItems_node_select_menu = [
    	"nodes_add", 
    	"nodes_delete_hovering",
    	"nodes_delete_select", 
    	-1,
    	"nodes_toggle_preview",
    	"nodes_toggle_sidebar", 
	];
	
    global.menuItems_node_side_context_menu = [
    	"nodes_add", 
    	-1, 
    	"nodes_toggle_sidebar", 
    	"nodes_edit_sidebar", 
	];
	
	global.menuItems_node_side_menu = [	
		"nodes_add", 
		"graph_auto_organize_all",
		-1,
		"graph_add_Node_Shape",
    	"graph_add_Node_Text",
    	"graph_add_Node_Path",
    	"graph_add_Node_Line", 
	];
	
	////- View
	
    function onFocusBegin() { 
        PANEL_NODES = self; 
    } 
    
	////- Draw
	
	function drawNodeTree(_item, _x0, _x1, _y, _m, _bg = true) {
		var sw    = sc_nodes.surface_w;
		var sh    = sc_nodes.surface_h;
		
		var hover = sc_nodes.hover;
		var focus = sc_nodes.active;
		
		var hg    = item_height;
		var _h    = 0;
		var _w    = _x1 - _x0;
		
		var node  = _item.node;
		var name  = node.getDisplayName();
		var _len  = array_length(_item.children);
		
		var sel   = array_exists(PANEL_GRAPH.nodes_selecting, node);
		var hov   = hover && point_in_rectangle(_m[0], _m[1], _x0, _y, _x1, _y + hg);
		var hovEx = false;
		
		_item.selected = sel;
		_item.hovering = hov;
		
		var coll = _len > 1 && !_item.expanded;
		var heig = coll? 1 : _item.height;
		var bhg  = heig * hg + ui(2) * max(0, heig - 1);
			
		_item.x = _x0;
		_item.y = _y;
		
		if(_bg) draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y, _w, bhg, COLORS.panel_inspector_group_bg, 1);
		
		if(hov) {
			node_hovering = node;
			
			sc_nodes.hover_content = true;
			draw_sprite_stretched_add(THEME.box_r5_clr, 0, _x0, _y, _w, hg, COLORS.panel_inspector_group_hover, .4);
			hovEx = _m[0] < _x0 + hg + ui(4) + (_len > 1) * ui(16);
			
			if(focus) {
				if(hovEx) {
					if(mouse_lpress()) 
						_item.toggleExpand(!_item.expanded);
					
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
			
			if(key_mod_press(SHIFT)) {
				var _outp = node.getOutput();
				if(is(_outp, NodeValue)) TOOLTIP = [ _outp.getValue(), _outp.type ];
			}
			
		} else {
			if(_item.parent != noone && _item.parent.hovering) {
				draw_sprite_stretched_add(THEME.box_r5_clr, 0, _x0, _y, _w, hg, COLORS.panel_inspector_group_hover, .2);
				
			} else if(_node_hovering != noone && _node_hovering == node) {
				draw_sprite_stretched_add(THEME.box_r5_clr, 0, _x0, _y, _w, hg, COLORS.panel_inspector_group_hover, .4);
				
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
		
		var _draw = false;
		var dx = _x0 + ui(4) + hg / 2;
		var dy = _y + hg / 2;
		
		var tx = _x0 + hg + ui(8);
		
		if(show_preview) {
			var _prev = node.getGraphPreviewSurface();
			if(is_surface(_prev)) {
				var _sw = surface_get_width(_prev);
				var _sh = surface_get_height(_prev);
				var _ss = (hg - ui(8)) / max(_sw, _sh);
				
				draw_surface_ext(_prev, dx - _sw * _ss / 2, dy - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
				_draw = true;
			}
		}
		
		if(!_draw) {
			var _n  = ALL_NODES[$ instanceof(node)];
			var spr = _n.spr;
			var _ss = (hg - ui(8)) / sprite_get_height(spr);
			gpu_set_tex_filter(true);
			draw_sprite_ext(spr, 1, dx, dy, _ss, _ss, 0, c_white, 1);
			gpu_set_tex_filter(false);
		}
		
		if(_len > 1) {
			gpu_set_tex_filter(true);
			draw_sprite_ui(THEME.arrow, coll? 0 : 3, tx + ui(1), dy, .75, .75, 0, hovEx? COLORS._main_icon_light : COLORS._main_icon);
			gpu_set_tex_filter(false);
			tx += ui(10);
		}
		
		var tc  = sel? COLORS._main_text_accent : COLORS._main_text;
		draw_set_text(f_p4, fa_left, fa_center, tc);
		draw_text_add(tx, _y + hg / 2, name);
		
		var _y0  = _y;
		_y += hg + ui(2);
		_h += hg + ui(2);
		
		if(!coll) {
			var _stk = _len == 1;
			var _xx0 = _stk? _x0 : _x0 + ui(8);
			
			for( var i = 0; i < _len; i++ ) {
				var _hhg = drawNodeTree(_item.children[i], _xx0, _x1, _y, _m, !_stk);
				
				_y += _hhg;
				_h += _hhg;
			}
			
			if(_len > 1) {
				var cc = merge_color(COLORS._main_icon, COLORS._main_icon_dark, .25);
				
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
		
		if(_bg) draw_sprite_stretched_add(THEME.box_r5,     1, _x0, _y0, _w, bhg, c_white, .1);
		
		return _h;
	}
	
	sc_nodes = new scrollPane(w - padding * 2, h - padding * 2 + ui(40), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _tree = PROJECT.nodeTree;
		var _ctx  = PANEL_GRAPH.getCurrentContext();
		if(is(_ctx, Node_Collection)) _tree = _ctx.nodeTree;
		
		var _ch = _tree.children;
		var _h  = 0;
		
		_node_hovering = node_hovering;
		 node_hovering = noone;
		
		var hover = sc_nodes.hover;
		var focus = sc_nodes.active;
		
		for( var i = 0, n = array_length(_ch); i < n; i++ ) {
			var _hhg = drawNodeTree(_ch[i], 0, sc_nodes.surface_w, _y, _m);
			_h += _hhg;
			_y += _hhg;
		}
		
		if(hover) {
			if(mouse_lpress(focus) && node_hovering == noone)
			PANEL_GRAPH.nodes_selecting = [];
			
			if(key_mod_press(CTRL)) item_height = clamp(item_height + MOUSE_WHEEL * ui(4), ui(16), ui(128));
			if(key_mod_double(SHIFT)) show_preview = !show_preview;
		}
		
		return _h + ui(16);
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		if(side_show) {
			var _side_m = menuItems_gen("node_side_menu");
			var _mus = ui(24);
			var _mux = w - _mus - ui(8);
			var _muy = side_scroll + ui(8);
			var _hh  = ui(16);
			
			pw -= _mus + ui(10);
			
			for( var i = 0, n = array_length(_side_m); i < n; i++ ) {
				var _menu = _side_m[i];
				if(_menu == -1) {
					draw_set_color(CDEF.main_mdblack);
					draw_line_width(_mux, _muy + ui(3), _mux + _mus, _muy + ui(3), 2);
					
					_muy += ui(8);
					_hh  += ui(8);
					continue;
				} 
				
				var _name = _menu.name;
				var _spr  = _menu.getSpr();
				var _cc   = i == 0? COLORS._main_value_positive : COLORS._main_icon;
				var _sca  = _mus / sprite_get_height(_spr);
				
				if(buttonInstant(THEME.button_hide, _mux, _muy, _mus, _mus, [mx, my], pHOVER, pFOCUS, _name, _spr, 0, _cc, 1, _sca) == 2)
					_menu.toggleFunction();
				
				_muy += _mus + ui(2);
				_hh  += _mus + ui(2);
			}
			
			side_scroll_max = max(_hh - h, 0);
			side_scroll = lerp_float(side_scroll, side_scroll_to, 5);
			
			if(pHOVER && point_in_rectangle(mx, my, _mux, 0, w, h)) {
				side_scroll_to = side_scroll_to + MOUSE_WHEEL * (_mus + ui(2));
				side_scroll_to = clamp(side_scroll_to, -side_scroll_max, 0);
				
				if(mouse_press(mb_right, pFOCUS))
					menuCall("node_side_context_menu", menuItems_gen("node_side_context_menu"));
			}
		}
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_nodes.verify(pw, ph);
		sc_nodes.setFocusHover(pFOCUS, pHOVER);
		sc_nodes.drawOffset(px, py, mx, my);
		
		if(pHOVER && point_in_rectangle(mx, my, px - ui(8), py - ui(8), px + pw + ui(8), py + ph + ui(8))) {
			if(mouse_rclick(pFOCUS)) {
				node_selecting = node_hovering;
				if(node_hovering == noone) menuCall("node_context_menu", menuItems_gen("node_context_menu"));
				else                       menuCall("node_select_menu",  menuItems_gen("node_select_menu"));
			}
		}
	}
	
	////- Actions
	
	function add_node() {
		var _ctx = PANEL_GRAPH.getCurrentContext();
		var _dia = dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: _ctx });
        
        var _fFrom = noone;
        var _nx = 0;
        var _ny = 0;
        
        if(node_selecting != noone) {
        	_fFrom = node_selecting.getOutput();
        	_nx = node_selecting.x + node_selecting.w + ui(32);
			_ny = node_selecting.y;
        }
        
        with(_dia) {
        	node_target_x     = _nx;
            node_target_y     = _ny;
            node_target_x_raw = _nx;
            node_target_y_raw = _ny;
            junction_called   = _fFrom;
            
            resetPosition();
            alarm[0] = 1;
        }
        
        return _dia;
	}
	
	function delete_selected() { PANEL_GRAPH.doDelete(false); }
	function delete_hovering() {
		if(node_selecting == noone) return;
		node_selecting.destroy();
		node_selecting = noone;
	}
	
	function toggle_sidebar() { side_show    = !side_show; }
	function edit_sidebar()   { dialogPanelCall(new Panel_MenuItems_Editor("node_side_menu")); }
	
	function toggle_preview() { show_preview = !show_preview; }
}