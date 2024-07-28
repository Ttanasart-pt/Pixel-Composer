function Panel_Presets(_node) : PanelContent() constructor {
	title   = __txt("Presets");
	padding = 8;
	
	w = ui(240);
	h = ui(400);
	anchor = ANCHOR.left | ANCHOR.top;
	
	node    = _node;
	adding  = false;
	add_txt = "";
	tb_add  = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { add_txt = txt; newPresetFromNode(txt); adding = false; });
	
	selecting_preset = noone; 
	
	context_menu_item_add = menuItem(__txt("New preset"), function() { if(!adding) tb_add.activate(); adding = true; });
	context_menu_empty    = [ context_menu_item_add ];
	
	context_menu = [
		context_menu_item_add,
		menuItem(__txt("Delete"), function() { file_delete(selecting_preset.path); __initPresets(); }, THEME.cross), 
	];
	
	function newPresetFromNode(name) {
		if(node == noone) return;
		var dir = $"{DIRECTORY}Presets/{instanceof(node)}/";
		directory_verify(dir);
		
		var pth = dir + name + ".json";
		var map = node.serialize(true, true);
		json_save_struct(pth, map);
		__initPresets();
		
		adding = false;
	}
	
	function onResize() {
		sc_presets.resize(w - ui(padding + padding), h - ui(padding + padding));
	}
	
	sc_presets = new scrollPane(w - ui(padding + padding), h - ui(padding + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var _ww = sc_presets.surface_w;
		var _h  = 0;
		if(node == noone) return _h;
		
		if(adding) {
			tb_add.setFocusHover(sc_presets.active, sc_presets.hover);
			var _wh = tb_add.draw(0, _y, _ww, TEXTBOX_HEIGHT, add_txt);
			
			_h += _wh + ui(4);
			_y += _wh + ui(4);
			
		} else {
			var _add_h = ui(24);
			var _hov   = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _y, _ww, _y + _add_h);
			
			draw_sprite_stretched_ext(THEME.timeline_node, 0, 0, _y, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .3 + _hov * .1);
			draw_sprite_stretched_ext(THEME.timeline_node, 1, 0, _y, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .6 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon);
			draw_text_add(_ww / 2, _y + _add_h / 2, __txt("New preset"));
			
			if(_hov) {
				sc_presets.hover_content = true;
				if(mouse_press(mb_left, pFOCUS)) {
					if(!adding) tb_add.activate(); 
					adding = true;
				}
			}
			
			_h += _add_h + ui(4);
			_y += _add_h + ui(4);
			
		}
		
		var folder = instanceof(node);
		if(!ds_map_exists(global.PRESETS_MAP, folder)) return 0;
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		
		var _hov = false;
		var pres = global.PRESETS_MAP[? folder];
		var amo  = array_length(pres);
		var _hh  = line_get_height() + ui(10);
		    _h  += amo * (_hh + ui(4)) + ui(32);
		
		for( var i = 0; i < amo; i++ ) {
			var preset = pres[i];
			var _yy = _y + (_hh + ui(3)) * i;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, _yy, _ww, _hh);
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				draw_sprite_stretched_ext(THEME.node_active, 1, 0, _yy, _ww, _hh, COLORS._main_accent, 1);
				_hov = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					node.deserialize(preset.content, true, true);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					selecting_preset = preset;
					dia = menuCall("preset_window_menu",,, context_menu);
				}
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _yy + _hh / 2, preset.name);
		}
		
		if(pHOVER && !_hov && mouse_press(mb_right)) dia = menuCall("preset_window_menu",,, context_menu_empty);
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_presets.setFocusHover(pFOCUS, pHOVER);
		sc_presets.draw(px, py, mx - px, my - py);
		
	}
}