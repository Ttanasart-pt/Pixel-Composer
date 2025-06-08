function Panel_Global_Layer() : PanelContent() constructor {
	title       = __txt("Global Layer");
	context_str = "GlobalLayer";
	auto_pin    = true;
	
	w = ui(280);
	h = ui(320);
	global_layer_drawer = new Panel_Global_Layer_Drawer();
	
	contentPane = new scrollPane(w - padding * 2, h - padding * 2 - ui(28), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _w = contentPane.surface_w;
		var _h = contentPane.surface_h;
		
		var _h = global_layer_drawer.draw(0, _y, _w, _h, _m, pHOVER, pFOCUS);
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding + ui(28);
		var pw = w - padding * 2;
		var ph = h - padding * 2 - ui(28);
		
		var _h = global_layer_drawer.drawHeader(px - ui(8), padding - ui(8), pw + ui(16), [mx, my], pHOVER, pFOCUS);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		contentPane.verify(pw, ph);
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.drawOffset(px, py, mx, my);
		
	}
}

function Panel_Global_Layer_Drawer() constructor {
	
	renaming    = noone;
	rename_text = "";
	tb_rename   = textBox_Text(function(_t) /*=>*/ { 
		rename_text = _t;
		if(renaming != noone) 
			renaming.setDisplayName(_t, false);
		renaming = noone;
		
	}).setHide(1).setFont(f_p3);
	
	dragging = noone;
	
	function drawHeader(_x, _y, _w, _m, _hover, _focus) {
		
		var bx = _x;
		var by = _y;
		var bs = ui(24);
		
		var _nodes = PROJECT.globalLayer_node_disp;
		
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "New Layer", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			var _lnode = nodeBuild("Node_Project_Layer", 0, 0).skipDefault();
			if(!array_empty(_nodes)) _lnode.inputs[1].setValue(_nodes[0].inputs[1].getValue() - 100);
		}
		
		bx += bs + ui(4);
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "New Canvas Layer", THEME.icon_canvas, 0, COLORS._main_value_positive) == 2) {
			var _lnode = nodeBuild("Node_Project_Layer", 0, 0).skipDefault();
			if(!array_empty(_nodes)) _lnode.inputs[1].setValue(_nodes[0].inputs[1].getValue() - 100);
			
			var _canvas = nodeBuild("Node_Canvas", 0, 0);
			_lnode.inputs[0].setFrom(_canvas.outputs[0]);
			
			panelFocusNode(_canvas);
		}
		
		var bx = _x + _w - bs;
		var cc = PROJECT.attributes.auto_organize? c_white : COLORS._main_icon;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "Auto Organize", THEME.obj_auto_organize, 0, cc, 1, .75) == 2) {
			PROJECT.attributes.auto_organize = !PROJECT.attributes.auto_organize;
			if(PROJECT.attributes.auto_organize) node_auto_organize(PROJECT.nodes);
		}
		
		bx -= bs + ui(4);
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "Export", THEME.icon_preview_export, 0, COLORS._main_value_negative, .75, .75) == 2) {
			var _export = noone;
			
			for( var i = 0, n = array_length(PROJECT.nodes); i < n; i++ ) {
				var _n = PROJECT.nodes[i];
				if(is(_n, Node_Export)) _export = _n;
			}
			
			if(_export == noone) nodeBuild("Node_Export", 0, 0).skipDefault();
			else panelFocusNode(_export);
		}
			
		bx -= bs + ui(4);
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "Add Output", THEME.add_16, 0, COLORS._main_value_negative, .75) == 2) {
			var _lnode = nodeBuild("Node_Layer_Output", 0, 0).skipDefault();
		}
		
		return ui(28)
	}
	
	function draw(_x, _y, _w, _h, _m, _hover, _focus) {
		
		var _nodes = PROJECT.globalLayer_node_disp;
		
		var _lh = ui(32);
		var _hh = _lh * array_length(_nodes) + ui(8);
		var _prev_s = _lh - ui(4);
		
		var _nodes    = PROJECT.globalLayer_node_disp;
		var _hovIndex = 0;
		
		if(_h == 0) draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _hh, COLORS.node_composite_bg_blend, 1);
		
		for( var i = 0, n = array_length(_nodes); i < n; i++ ) {
			var _n = _nodes[i];
			
			var _ntarg = _n;
			if(_n.inputs[0].value_from) _ntarg = _n.inputs[0].value_from.node;
				
			var xx = _x;
			var yy = _y + ui(4) + i * _lh;
			var cy = yy + _lh / 2;
			
			var _name = _n.getDisplayName();
			var _prev = _n.getGraphPreviewSurface();
			
			var _sx0 = xx + ui(6);
			var _sx1 = _x + _w - ui(8);
			
			var _sy0 = yy + ui(2);
			var _sy1 = yy + _lh - ui(2);
			
			var cc = COLORS._main_icon;
			var aa = .3;
			var hv = _hover && point_in_rectangle(_m[0], _m[1], _sx0, _sy0, _sx0 + _prev_s, _sy0 + _prev_s);
			
			if(hv) {
				_hovIndex = i;
				cc = COLORS._main_text;
				
				if(mouse_lpress(_focus))
					panelFocusNode(_n);
			}
			
			if(i == n - 1 && _m[1] > yy) _hovIndex = n - 1;
			
			if(is_surface(_prev)) {
				var _ssw = surface_get_width_safe(_prev);
				var _ssh = surface_get_height_safe(_prev);
				var _sss = min(_prev_s / _ssw, _prev_s / _ssh);
				draw_surface_ext_safe(_prev, _sx0, _sy0, _sss, _sss);
			}
			
			if(_ntarg == PANEL_INSPECTOR.inspecting) {
				cc = COLORS._main_accent;
				aa = 1;
			}
			
			draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, _prev_s, _prev_s, cc, aa);
			
			_sx0 += _prev_s + ui(8);
			
			var _bs = ui(24);
			var _bx = _sx1 - _bs;
			var _by = cy - _bs / 2;
			
			if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, _hover, _focus, "", THEME.node_goto_16) == 2)
				panelFocusNode(_ntarg == PANEL_INSPECTOR.inspecting? noone : _ntarg);
			_sx1 -= _bs;
			
			if(renaming == _n) {
				tb_rename.setFocusHover(_focus, _hover);
				tb_rename.draw(_sx0, yy, _sx1 - _sx0, _lh, rename_text, _m);
				continue;
			} 
			
			var cc = COLORS._main_text_sub;
			var hv = _hover && point_in_rectangle(_m[0], _m[1], _sx0, _sy0, _sx1, _sy1);
			
			if(hv) {
				_hovIndex = i;
				cc = COLORS._main_text;
				
				if(DOUBLE_CLICK) {
					renaming    = _n;
					rename_text = _n.getDisplayName();
					tb_rename.activate(_n.getDisplayName());
					
				} else if(mouse_lpress(_focus)) {
					dragging = i;
				}
			}
			
			if(_ntarg == PANEL_INSPECTOR.inspecting) cc = COLORS._main_accent;
			if(dragging != noone) cc = i == dragging? COLORS._main_accent : COLORS._main_text_sub;
			
			draw_set_text(f_p3, fa_left, fa_center, cc);
			draw_text_add(_sx0, cy, _name);
			
			if(hv && dragging != noone) {
				draw_set_color(COLORS._main_accent);
				
				if(_hovIndex < dragging) draw_line_round(_sx0, _sy0, _sx1, _sy0, 2);
				if(_hovIndex > dragging) draw_line_round(_sx0, _sy1, _sx1, _sy1, 2);
			}
		}
		
		if(dragging != noone) {
			
			if(mouse_release(mb_left)) {
				if(_hovIndex != dragging) {
					var _node = _nodes[dragging];
					array_delete(_nodes, dragging, 1);
					
					if(_hovIndex < dragging) array_insert(_nodes, _hovIndex, _node);
					if(_hovIndex > dragging) array_insert(_nodes, _hovIndex, _node);
					
					var _len = array_length(_nodes);
					for( var i = 0; i < _len; i++ ) 
						_nodes[i].inputs[1].setValue(-(_len - i - 1) * 100);
				}
				
				dragging = noone;
			}
		} 
		
		return _hh;
	}
}