function Panel_Graph_Node_Position(_project) : PanelContent() constructor {
	title    = __txt("Nose Position");
	w        = ui(272);
	h        = ui(400);
	anchor   = ANCHOR.left | ANCHOR.top;
	
	project  = _project;
	
	adding   = false;
	add_txt  = "";
	tb_add   = textBox_Text(function(txt) /*=>*/ { 
		adding  = false; 
		add_txt = txt; 
		if(txt == "") return;
		
		project.storeNodePosition(txt); 
	});
	
	sc_position = new scrollPane(0, 0, function(_y, _m) {
		draw_clear(COLORS.panel_bg_clear, 1);
		
		var _h = 0;
		var ww = sc_position.surface_w;
		
		var _hover = sc_position.hover;
		var _focus = sc_position.active;
		
		var _posi = project.nodeStoredPosition;
		var _keys = struct_get_names(_posi);
		
		var hg    = ui(24);
		var toDel = undefined;
		
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _key = _keys[i];
			
			var _ww = ww;
			
			var  tw = hg;
			var  th = hg;
			var  tx = ww - tw;
			var  ty = _y;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, tx, ty, tw, th);
			if(_hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + tw, ty + th)) {
				draw_sprite_ui(THEME.icon_delete, 0, tx + tw / 2, ty + th / 2, 1, 1, 0, COLORS._main_value_negative);
				TOOLTIP = __txt("Delete");
				
				if(mouse_lclick(pFOCUS))
					draw_sprite_stretched_ext(THEME.ui_panel, 1, tx, ty, tw, th, COLORS._main_accent);
					
				if(mouse_lpress(pFOCUS)) 
					toDel = _key;
				
			} else 
				draw_sprite_ui(THEME.icon_delete, 0, tx + tw / 2, ty + th / 2, 1, 1, 0, COLORS._main_icon);
			
			 tx -= tw + ui(2);
			_ww -= tw + ui(2);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, tx, ty, tw, th);
			if(_hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + tw, ty + th)) {
				draw_sprite_ui(THEME.refresh_icon, 0, tx + tw / 2, ty + th / 2, .75, .75, 0, COLORS._main_icon_light);
				TOOLTIP = __txt("Update");
				
				if(mouse_lclick(pFOCUS))
					draw_sprite_stretched_ext(THEME.ui_panel, 1, tx, ty, tw, th, COLORS._main_accent);
					
				if(mouse_lpress(pFOCUS))
					project.storeNodePosition(_key); 
				
			} else 
				draw_sprite_ui(THEME.refresh_icon, 0, tx + tw / 2, ty + th / 2, .75, .75, 0, COLORS._main_icon);
			
			 tx -= tw + ui(2);
			_ww -= tw + ui(2);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, _y, _ww, hg);
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], 0, _y, _ww, _y + hg);
			if(_hov) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, 0, _y, _ww, hg, COLORS._main_accent, 1);
				
				if(mouse_lpress(_focus))
					project.setNodePosition(_key);
			}
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _y + hg / 2, _key);
			
			_y += hg + ui(2);
			_h += hg + ui(2);
		}
		
		if(toDel != undefined)
			struct_remove(_posi, toDel);
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2 - ui(28);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_position.verify(w - padding * 2, h - padding * 2 - ui(28));
		sc_position.setFocusHover(pFOCUS, pHOVER);
		sc_position.draw(px, py, mx - px, my - py);
		
		var ah = ui(24);
		var bx = sp;
		var by = h - ah - sp;
		var ww = w - sp * 2;
		
		if(adding) {
			tb_add.setFocusHover(pFOCUS, pHOVER);
			tb_add.setFont(f_p2);
			tb_add.draw(bx, by, ww, ah, add_txt);
			
		} else {
			var hov = pHOVER && point_in_rectangle(mx, my, bx, by, bx + ww, by + ah);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, ww, ah, hov? COLORS._main_value_positive : COLORS._main_icon, .3 + hov * .10);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, ww, ah, hov? COLORS._main_value_positive : COLORS._main_icon, .6 + hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, hov? COLORS._main_value_positive : COLORS._main_icon_light);
			draw_text_add(bx + ww / 2, by + ah / 2, __txt("Store Position"));
			
			if(hov && mouse_lpress(pFOCUS)) { if(!adding) tb_add.activate(); adding = true; }
			
		}
		
	}
}