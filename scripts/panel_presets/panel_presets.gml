function Panel_Presets(_node) : PanelContent() constructor {
	title   = __txt("Presets");
	padding = 8;
	
	w = ui(240);
	h = ui(400);
	anchor = ANCHOR.left | ANCHOR.top;
	
	defPres = noone;
	node    = _node;
	adding  = false;
	add_txt = "";
	tb_add  = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { 
			adding  = false; 
			add_txt = txt; 
			if(txt == "") return;
			
			newPresetFromNode(txt); 
		});
	
	selecting_preset = noone; 
	
	directory_verify($"{DIRECTORY}Presets/{instanceof(node)}/");
	__initPresets();
		
	context_menu = [
		menuItem(__txt("Replace preset"), function() { replacePreset(selecting_preset.path); }),
		menuItem(__txt("Delete"),         function() { file_delete(selecting_preset.path); __initPresets(); }, THEME.cross), 
	];
	
	context_def = [
		menuItem(__txt("Set to default"), function() { newPresetFromNode("_default");  }),
	];
	
	thumbnail_mask = surface_create(1, 1);
	
	function replacePreset(path) {
		if(node == noone) return;
		
		file_delete(path);
		var map = node.serialize(true, true);
		var thm = node.getPreviewValues();
		if(is_surface(thm)) map.thumbnail = surface_encode(thm, false);
		
		json_save_struct(path, map);
		__initPresets();
	}
	
	function newPresetFromNode(name) {
		if(node == noone) return;
		var dir = $"{DIRECTORY}Presets/{instanceof(node)}/";
		var pth = dir + name + ".json";
		
		var map = node.serialize(true, true);
		var thm = node.getPreviewValues();
		if(is_surface(thm)) map.thumbnail = surface_encode(thm, false);
		
		json_save_struct(pth, map);
		__initPresets();
		
		adding = false;
	}
	
	function onResize() { sc_presets.resize(w - ui(padding + padding), h - ui(padding + padding) - ui(28)); }
	
	sc_presets = new scrollPane(w - ui(padding + padding), h - ui(padding + padding) - ui(28), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var _ww = sc_presets.surface_w;
		var _h  = 0;
		if(node == noone) return _h;
		
		var folder = instanceof(node);
		if(!ds_map_exists(global.PRESETS_MAP, folder)) return 0;
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		
		var pres = global.PRESETS_MAP[? folder];
		var amo  = array_length(pres);
		var _hh  = line_get_height() + ui(10);
		    _h  += amo * (_hh + ui(4)) + ui(32);
		
		var _yy = _y;
		
		if(defPres != noone) {
			var preset = defPres;
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				draw_sprite_stretched_ext(THEME.node_active, 1, 0, _yy, _ww, _hh, COLORS._main_icon, 1);
				sc_presets.hover_content = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					LOADING_VERSION = SAVE_VERSION;
					
					node.deserialize(loadPreset(preset), true, true);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					selecting_preset = preset;
					menuCall("preset_window_menu",,, context_menu);
				}
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _yy + _hh / 2, "_default");
			
		} else {
			var aa = .5;
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				aa = .75;
				sc_presets.hover_content = true;
				
				if(mouse_press(mb_right, pFOCUS))
					menuCall("preset_window_menu",,, context_def);
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text, aa);
			draw_text_add(ui(8), _yy + _hh / 2, "_default");
			draw_set_alpha(1);
		}
		
		_yy += _hh + ui(4);
		_h  += _hh + ui(4);
		
		var _sz = _hh - ui(8);
		thumbnail_mask = surface_create(_sz, _sz);
		
		defPres = noone;
		for( var i = 0; i < amo; i++ ) {
			var preset = pres[i];
			if(preset.name == "_default") {
				defPres = preset;
				continue;
			}
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, _yy, _ww, _hh);
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				draw_sprite_stretched_ext(THEME.node_active, 1, 0, _yy, _ww, _hh, COLORS._main_accent, 1);
				sc_presets.hover_content = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					LOADING_VERSION = SAVE_VERSION;
					
					node.deserialize(loadPreset(preset), true, true);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					selecting_preset = preset;
					dia = menuCall("preset_window_menu",,, context_menu);
				}
			}
			
			loadPreset(preset);
			var _thm = preset.getThumbnail();
			var _xx  = ui(8);
			
			if(is_surface(_thm)) {
				_xx = 0;
				
				var _sw = surface_get_width(_thm);
				var _sh = surface_get_height(_thm);
				
				var _ss = _sz / max(_sw, _sh);
				var _sx = _sz / 2 - _sw * _ss / 2;
				var _sy = _sz / 2 - _sh * _ss / 2;
				
				surface_set_target(thumbnail_mask);
					DRAW_CLEAR
					
					draw_surface_ext(_thm, _sx, _sy, _ss, _ss, 0, c_white, 1);
					BLEND_MULTIPLY
					draw_sprite_stretched(THEME.palette_mask, 1, _sx, _sy, _sw * _ss, _sh * _ss);
					BLEND_NORMAL
				surface_reset_target();
				
				draw_surface(thumbnail_mask, _xx + ui(4), _yy + ui(4));
				_xx += _sz + ui(12);
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_xx, _yy + _hh / 2, preset.name);
			
			_yy += _hh + ui(4);
		}
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding) - ui(28);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_presets.setFocusHover(pFOCUS, pHOVER);
		sc_presets.draw(px, py, mx - px, my - py);
		
		var _add_h = ui(24);
		var _bx    = 0;
		var _by    = h - _add_h;
		var _ww    = w;
		
		if(adding) {
			tb_add.setFocusHover(sc_presets.active, sc_presets.hover);
			tb_add.font = f_p2;
			tb_add.draw(_bx, _by, _ww, _add_h, add_txt);
			
		} else {
			var _hov   = pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + _ww, _by + _add_h);
			
			draw_sprite_stretched_ext(THEME.timeline_node, 0, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .3 + _hov * .1);
			draw_sprite_stretched_ext(THEME.timeline_node, 1, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .6 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon);
			draw_text_add(_ww / 2, _by + _add_h / 2, __txt("New preset"));
			
			if(mouse_press(mb_left, pFOCUS && _hov)) {
				if(!adding) tb_add.activate(); 
				adding = true;
			}
			
		}
	}
}