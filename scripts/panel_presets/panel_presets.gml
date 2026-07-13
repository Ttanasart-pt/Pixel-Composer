#region functions
	#macro CHECK_PANEL_PRESETS if(!is_instanceof(FOCUS_CONTENT, Panel_Presets)) return;
	
	function panel_preset_replace()     { CHECK_PANEL_PRESETS CALL("panel_preset_replace");     FOCUS_CONTENT.replacePreset(FOCUS_CONTENT.selecting_preset.path); }
	function panel_preset_replace_def() { CHECK_PANEL_PRESETS CALL("panel_preset_replace_def"); FOCUS_CONTENT.newPresetFromNode("_default"); }
	function panel_preset_replace_thumbnail() { 
		CHECK_PANEL_PRESETS CALL("panel_preset_replace_thumbnail"); 
		FOCUS_CONTENT.replacePresetThumbnail(FOCUS_CONTENT.selecting_preset.path); 
	}
	
	function panel_preset_reset()       { CHECK_PANEL_PRESETS CALL("panel_preset_reset");       FOCUS_CONTENT.newPresetFromNode("_default"); }
	function panel_preset_delete()      { CHECK_PANEL_PRESETS CALL("panel_preset_delete");      file_delete(FOCUS_CONTENT.selecting_preset.path); __initPresets(); }
	
	function __fnInit_Presets() {
		registerFunction("Presets", "Replace",          "", MOD_KEY.none, panel_preset_replace           ).setMenu( "preset_replace"           ).hidePalette();
		registerFunction("Presets", "Replace Default",  "", MOD_KEY.none, panel_preset_replace_def       ).setMenu( "preset_replace_def"       ).hidePalette();
		registerFunction("Presets", "Replace Thumbnail","", MOD_KEY.none, panel_preset_replace_thumbnail ).setMenu( "preset_replace_thumbnail" ).hidePalette();
		
		registerFunction("Presets", "Reset To Default", "", MOD_KEY.none, panel_preset_reset       ).setMenu( "preset_reset" )
		registerFunction("Presets", "Delete",           "", MOD_KEY.none, panel_preset_delete      ).setMenu( "preset_delete", THEME.cross).hidePalette();
	}
#endregion

function Panel_Presets(_node) : PanelContent() constructor {
	title    = __txt("Presets");
	w        = ui(240);
	h        = ui(400);
	anchor   = ANCHOR.left | ANCHOR.top;
	
	defPres  = noone;
	node     = _node;
	nodeType = instanceof(node);
	dirPath  = $"{DIRECTORY}Presets/{nodeType}/";
	
	adding   = false;
	add_txt  = "";
	tb_add   = textBox_Text(function(txt) /*=>*/ { 
		adding  = false; 
		add_txt = txt; 
		if(txt == "") return;
		newPresetFromNode(txt); 
	});
	
	selecting_preset = noone; 
	hk_selecting     = noone;
	hk_editing       = noone;
	thumbnail_mask   = noone;
	
	directory_verify(dirPath);
	__initPresets();
	
	#region ++++ menu ++++
		menu_removeHotkey = menuItem(__txt("Remove Hotkey"), function() /*=>*/ { 
			var _key    = $"{nodeType}>{selecting_preset.name}";
			struct_remove(GRAPH_ADD_NODE_MAPS, _key);
		}, THEME.cross);
	
		context_menu = [
			MENU_ITEMS.preset_replace,
			MENU_ITEMS.preset_replace_thumbnail,
			MENU_ITEMS.preset_delete,
			
			-1,
			menuItem(__txt("Edit Hotkey"),  function() /*=>*/ { 
				var _key    = $"{nodeType}>{selecting_preset.name}";
				var _hotkey = __fnGraph_BuildNode(_key);
				hk_editing  = _hotkey.modify();
			}),
			
			menu_removeHotkey,
		];
		
		context_def = [
			MENU_ITEMS.preset_replace_def,
			MENU_ITEMS.preset_reset,
		];
	#endregion
	
	#region default values
		valPath = $"{dirPath}_values.json";
		defVal  = undefined;
		defKeys = [];
		
		if(file_exists(valPath)) {
			defVal  = json_load_struct(valPath);
			defKeys = struct_get_names(defVal);
		}
	#endregion
	
	////- Draw
	
	function replacePreset(path)          { if(node != noone) node.savePreset(filename_name_only(path));          }
	function replacePresetThumbnail(path) { if(node != noone) node.savePresetThumbnail(filename_name_only(path)); }
	function newPresetFromNode(name)      { if(node != noone) node.savePreset(name); adding = false;              }
	
	sc_presets = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _ww = sc_presets.surface_w;
		var _h  = 0;
		if(node == noone) return _h;
		
		if(!has(PRESETS_MAP, nodeType)) return 0;
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		
		var pres = PRESETS_MAP[$ nodeType];
		var keys = struct_get_names(pres);
		var amo  = array_length(keys);
		var _hh  = line_get_height() + ui(10);
		    _h  += amo * (_hh + ui(4)) + ui(32);
		if(TESTING)
			_ww -= _hh + ui(4);
		
		var _yy = _y;
		
		var dh = ui(24);
		if(defPres != noone) {
			var preset = defPres;
			draw_sprite_stretched_ext(THEME.box_r2, 0, 0, _yy, _ww, dh, COLORS._main_icon_dark, 1);
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + dh)) {
				draw_sprite_stretched_ext(THEME.box_r2, 1, 0, _yy, _ww, dh, COLORS._main_icon, 1);
				sc_presets.hover_content = true;
				
				if(mouse_lpress(pFOCUS)) {
					LOADING_VERSION = SAVE_VERSION;
					
					node.setPreset(preset.name);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_rpress(pFOCUS)) {
					selecting_preset = preset;
					menu_removeHotkey.setActive(false);
					menuCall("preset_window_menu", context_menu);
				}
			}
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(_ww / 2, _yy + dh / 2, "default");
			
		} else {
			var aa = .5;
			draw_sprite_stretched_ext(THEME.box_r2, 0, 0, _yy, _ww, dh, COLORS._main_icon_dark, 1);
			
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + dh)) {
				draw_sprite_stretched_ext(THEME.box_r2, 1, 0, _yy, _ww, dh, COLORS._main_icon, .5);
				aa = .75;
				sc_presets.hover_content = true;
				
				if(mouse_lpress(pFOCUS)) {
					node.resetDefault();
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_rpress(pFOCUS))
					menuCall("preset_window_menu", context_def);
			}
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text, aa);
			draw_text_add(_ww / 2, _yy + dh / 2, "default");
			draw_set_alpha(1);
		}
		
		_yy += dh + ui(4);
		_h  += dh + ui(4);
		
		var _sz = _hh - ui(8);
		thumbnail_mask = surface_create(_sz, _sz);
		defPres = noone;
		
		for( var i = 0; i < amo; i++ ) {
			var preset = pres[$ keys[i]];
			var _name  = preset.name;
			var fName  = $"{nodeType}>{_name}";
			
			if(_name == "_values")  continue;
			if(_name == "_default") { defPres = preset; continue; }
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, _yy, _ww, _hh);
			if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + _hh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, 0, _yy, _ww, _hh, COLORS._main_accent, 1);
				sc_presets.hover_content = true;
				
				if(mouse_lpress(pFOCUS)) {
					LOADING_VERSION = SAVE_VERSION;
					
					node.setPreset(_name);
					if(in_dialog && panel.destroy_on_click_out) close();
				}
				
				if(mouse_rpress(pFOCUS)) {
					selecting_preset = preset;
					hk_selecting     = GRAPH_ADD_NODE_MAPS[$ fName];
					menu_removeHotkey.setActive(has(GRAPH_ADD_NODE_MAPS, fName));
					dia = menuCall("preset_window_menu", context_menu);
				}
			}
			
			if(TESTING) {
				var tx = _ww + ui(4);
				var ty = _yy;
				var tw = _hh;
				var th = _hh;
				
				var dir    = $"D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datasrc/Presets/{nodeType}/";
				var defPth = filename_combine(dir, _name);
				var isDef  = file_exists_empty(defPth);
				
				draw_sprite_stretched(THEME.ui_panel_bg, 3, tx, ty, tw, th);
				if(pHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + tw, ty + th)) {
					draw_sprite_stretched_ext(THEME.node_bg, 1, tx, ty, tw, th, COLORS._main_accent, 1);
					TOOLTIP = __txt("Include in Default");
					
					if(mouse_lpress(pFOCUS)) {
						if(isDef) {
							file_delete(defPth);
							
						} else {
							directory_verify(dir);
							file_copy(preset.path, defPth);
						}
					}
				}
				
				draw_sprite_ui(THEME.icon_default, 0, tx + tw / 2, ty + th / 2, 1, 1, 0, isDef? COLORS._main_accent : COLORS._main_icon);
			}
			
			if(preset.content == undefined) {
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
			
			var _ktxt = _hotkey != undefined? _hotkey.getKeyName() : "";
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
		
		sc_presets.verify(w - padding * 2, h - padding * 2 - ui(28));
		sc_presets.setFocusHover(pFOCUS, pHOVER);
		sc_presets.draw(px, py, mx - px, my - py);
		
		var ah = ui(24);
		var bx = sp;
		var by = h - ah - sp;
		var ww = w - sp * 2;
		
		if(adding) {
			tb_add.setFocusHover(pFOCUS, pHOVER);
			tb_add.setFont(f_p2);
			tb_add.draw(bx, by, ww, ah, add_txt);
			
		} else {
			var  bs = ui(32);
			var _bx = w - sp - bs;
			
			var hov = pHOVER && point_in_rectangle(mx, my, bx, by, bx + bs, by + ah);
			var cc  = hov? CDEF.cyan : COLORS._main_icon;
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bs, ah, cc, .40 + hov * .10);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bs, ah, cc, .75 + hov * .25);
			draw_sprite_ui(THEME.path_open, 0, bx + bs/2, by + ah/2, .75, .75, 0, cc);
			
			if(hov) {
				TOOLTIP = __txt("Open in file explorer");
				if(mouse_lpress(pFOCUS)) shellOpenExplorer(dirPath);
			}
			
			bx += bs + ui(4);
			ww -= bs + ui(4);
				
			if(file_exists_empty(valPath)) {
				var hov = pHOVER && point_in_rectangle(mx, my, _bx, by, _bx + bs, by + ah);
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, by, bs, ah, COLORS._main_value_negative, .40 + hov * .10);
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, by, bs, ah, COLORS._main_value_negative, .75 + hov * .25);
				draw_set_text(f_p2, fa_center, fa_center, hov? COLORS._main_value_positive : COLORS._main_icon);
				draw_sprite_ui(THEME.icon_delete, 0, _bx + bs/2, by + ah/2, 1, 1, 0, COLORS._main_value_negative);
				
				if(hov) {
					TOOLTIP = __txta("Clear {1} Default Value(s)", array_length(defKeys));
					if(mouse_lpress(pFOCUS)) {
						file_delete_safe(valPath);
						PRESETS_MAP[$ instanceof(nodeType)] = {}
					}
				}
				
			} else {
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, by, bs, ah, COLORS._main_icon, .40);
				draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon);
				draw_sprite_ui(THEME.icon_delete, 0, _bx + bs/2, by + ah/2, 1, 1, 0, COLORS._main_icon);
			}
			
			ww -= bs + ui(4);
			
			var hov = pHOVER && point_in_rectangle(mx, my, bx, by, bx + ww, by + ah);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, ww, ah, hov? COLORS._main_value_positive : COLORS._main_icon, .3 + hov * .10);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, ww, ah, hov? COLORS._main_value_positive : COLORS._main_icon, .6 + hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, hov? COLORS._main_value_positive : COLORS._main_icon_light);
			draw_text_add(bx + ww / 2, by + ah / 2, __txt("New preset"));
			
			if(mouse_lpress(pFOCUS && hov)) { if(!adding) tb_add.activate(); adding = true; }
			
		}
		
		if(hk_editing != noone) {
			if(KEYBOARD_ENTER)  hk_editing = noone;
			else hotkey_editing(hk_editing);
				
			if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
				
		}
	}
} 