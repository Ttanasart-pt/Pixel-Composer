#region functions
	#macro CHECK_PANEL_PRESETS if(!is_instanceof(FOCUS_CONTENT, Panel_Presets)) return;
	
	function panel_preset_replace()     { CHECK_PANEL_PRESETS CALL("panel_preset_replace");     FOCUS_CONTENT.replacePreset(FOCUS_CONTENT.selecting_preset.path); }
	function panel_preset_replace_def() { CHECK_PANEL_PRESETS CALL("panel_preset_replace_def"); FOCUS_CONTENT.newPresetFromNode("_default"); }
	function panel_preset_delete()      { CHECK_PANEL_PRESETS CALL("panel_preset_delete");      file_delete(FOCUS_CONTENT.selecting_preset.path); __initPresets(); }
	function panel_preset_reset()       { CHECK_PANEL_PRESETS CALL("panel_preset_reset");       FOCUS_CONTENT.newPresetFromNode("_default"); }
	
	function __fnInit_Presets() {
		registerFunction("Presets", "Replace",			"", MOD_KEY.none, panel_preset_replace).setMenu("preset_replace").hidePalette();
		registerFunction("Presets", "Replace Default",	"", MOD_KEY.none, panel_preset_replace_def).setMenu("preset_replace_def").hidePalette();
		registerFunction("Presets", "Delete",			"", MOD_KEY.none, panel_preset_delete).setMenu("preset_delete", THEME.cross).hidePalette();
		registerFunction("Presets", "Reset To Default",	"", MOD_KEY.none, panel_preset_reset).setMenu("preset_reset")
	}
#endregion

function Panel_Presets(_node) : PanelContent() constructor {
	title  = __txt("Presets");
	w      = ui(240);
	h      = ui(400);
	anchor = ANCHOR.left | ANCHOR.top;
	
	defPres  = noone;
	node     = _node;
	nodeType = instanceof(node);
	dirPath  = $"{DIRECTORY}Presets/{nodeType}/";
	
	adding   = false;
	add_txt  = "";
	tb_add   = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { 
		adding  = false; 
		add_txt = txt; 
		if(txt == "") return;
		
		newPresetFromNode(txt); 
	});
	
	selecting_preset = noone; 
	hk_selecting     = noone;
	hk_editing       = noone;
	
	directory_verify(dirPath);
	__initPresets();
	
	context_menu = [
		MENU_ITEMS.preset_replace,
		MENU_ITEMS.preset_delete,
		
		-1,
		menuItem(__txt("Edit Hotkey"),  function() /*=>*/ { 
			var _hk    = __fnGraph_BuildNode($"{nodeType}>{selecting_preset.name}");
			hk_editing = _hk.modify();
		}),
		menuItem(__txt("Reset Hotkey"), function() /*=>*/ { if(is_struct(hk_selecting)) hk_selecting.reset(true) }, THEME.refresh_20)
			.setActive(is_struct(hk_selecting) && hk_selecting.isModified()),
	];
	
	context_def = [
		MENU_ITEMS.preset_replace_def,
		MENU_ITEMS.preset_reset,
	];
	
	thumbnail_mask = noone;
	
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
		
		var pth = $"{dirPath}{name}.json";
		var map = node.serialize(true, true);
		var thm = node.getPreviewValues();
		if(is_surface(thm)) map.thumbnail = surface_encode(thm, false);
		
		if(file_exists_empty(pth)) file_delete(pth);
		json_save_struct(pth, map);
		__initPresets();
		
		adding = false;
	}
	
	function onResize() { sc_presets.resize(w - padding * 2, h - padding * 2 - ui(28)); }
	
	sc_presets = new scrollPane(w - padding * 2, h - padding * 2 - ui(28), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _ww = sc_presets.surface_w;
		var _h  = 0;
		if(node == noone) return _h;
		
		if(!ds_map_exists(global.PRESETS_MAP, nodeType)) return 0;
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		
		var pres = global.PRESETS_MAP[? nodeType];
		var amo  = array_length(pres);
		var _hh  = line_get_height() + ui(10);
		    _h  += amo * (_hh + ui(4)) + ui(32);
		
		var _yy = _y;
		
		if(defPres != noone) {
			var preset = defPres;
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, 0, _yy, _ww, _hh, COLORS._main_icon, 1);
				sc_presets.hover_content = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					LOADING_VERSION = SAVE_VERSION;
					
					node.setPreset(preset.name);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					selecting_preset = preset;
					menuCall("preset_window_menu", context_menu);
				}
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _yy + _hh / 2, "_default");
			
		} else {
			var aa = .5;
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				aa = .75;
				sc_presets.hover_content = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					node.resetDefault();
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_press(mb_right, pFOCUS))
					menuCall("preset_window_menu", context_def);
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
			var _name  = preset.name;
			var fName  = $"{nodeType}>{_name}";
			
			if(_name == "_default") {
				defPres = preset;
				continue;
			}
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, _yy, _ww, _hh);
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, 0, _yy, _ww, _hh, COLORS._main_accent, 1);
				sc_presets.hover_content = true;
				
				if(mouse_press(mb_left, pFOCUS)) {
					LOADING_VERSION = SAVE_VERSION;
					
					node.setPreset(_name);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					selecting_preset = preset;
					hk_selecting     = GRAPH_ADD_NODE_MAPS[$ fName];
					dia = menuCall("preset_window_menu", context_menu);
				}
			}
			
			if(preset.content == -1) {
				preset.content        = json_load_struct(preset.path);
				preset.thumbnail_data = struct_try_get(preset.content, "thumbnail", -1);
			}
			
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
			draw_text_add(_xx, _yy + _hh / 2, _name);
			
			// Hotkeys
			draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text);
			var _hotkey = GRAPH_ADD_NODE_MAPS[$ fName];
			var _hkC    = COLORS._main_text_sub;
			
			var _ktxt = _hotkey != undefined? _hotkey.getName() : "";
			var _tx   = _ww - ui(16);
			var _ty   = _yy + _hh / 2;
			var _tw   = string_width(_ktxt);
			var _th   = line_get_height();
			
			var _bx = _tx - _tw - ui(4);
			var _by = _ty - _th / 2 - ui(3);
			var _bw = _tw + ui(8);
			var _bh = _th + ui(6);
			
			if(hk_editing == _hotkey) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
				_hkC = COLORS._main_accent;
			}
			
			if(_hotkey != undefined) {
				draw_set_color(_hkC);
				draw_text_add(_tx, _ty, _ktxt);
			}
			
			_yy += _hh + ui(4);
		}
		
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
		
		sc_presets.setFocusHover(pFOCUS, pHOVER);
		sc_presets.draw(px, py, mx - px, my - py);
		
		var _add_h = ui(24);
		var _bx    = sp;
		var _by    = h - _add_h - sp;
		var _ww    = w - sp * 2;
		
		if(adding) {
			tb_add.setFocusHover(sc_presets.active, sc_presets.hover);
			tb_add.font = f_p2;
			tb_add.draw(_bx, _by, _ww, _add_h, add_txt);
			
		} else {
			var _hov = pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + _ww, _by + _add_h);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .3 + _hov * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .6 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon);
			draw_text_add(_ww / 2, _by + _add_h / 2, __txt("New preset"));
			
			if(mouse_press(mb_left, pFOCUS && _hov)) {
				if(!adding) tb_add.activate(); 
				adding = true;
			}
			
		}
		
		if(hk_editing != noone) {
			if(KEYBOARD_ENTER)  hk_editing = noone;
			else hotkey_editing(hk_editing);
				
			if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
				
		}
	}
} 