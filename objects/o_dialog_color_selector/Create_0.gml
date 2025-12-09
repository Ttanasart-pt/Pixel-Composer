/// @description init
event_inherited();

#region data
	dialog_w = ui(812);
	dialog_h = ui(396);
	title_height = 52;
	interactable = true;
	destroy_on_click_out = true;
	
	name = __txtx("color_selector_title", "Color selector");
	
	previous_color = c_black;
	selector       = new colorSelector();
	drop_target    = noone;
	
	function setApply(_onApply) { onApply = _onApply; selector.onApply = _onApply; return self; }
	function setDefault(color) { selector.setColor(color); previous_color = color; return self; }
	
	b_cancel = button(function() /*=>*/ { onApply(previous_color); instance_destroy(); }).setIcon(THEME.undo, 0, COLORS._main_icon)
	                                                                         .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	b_apply  = button(function() /*=>*/ { onApply(selector.current_color); instance_destroy(); }).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
#endregion

#region presets
	preset_selecting = undefined;
	preset_expands   = {};
	
	pal_padding    = ui(9);
	sp_preset_w    = ui(240) - pal_padding * 2 - ui(8);
	sp_preset_size = ui(20);
	click_block    = false;
	
	function drawPaletteDirectory(_dir, _x, _y, _m) {
		var _hov = sp_presets.hover;
		var _foc = sp_presets.active && interactable;
		
		var ww  = sp_presets.surface_w - _x;
		var _gs = sp_preset_size;
		var hh  = 0;
		var nh  = ui(20);
		var pd  = ui(2);
		var _ww = ww - pd * 2;
		var _bh = nh + _gs + pd;
		var col = max(1, floor(_ww / _gs)), row, _exp;
		var _height, pre_amo, _palRes;
		
		var lbh = ui(20);
		var sch = search_string != "";
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = sch || (_sub[$ "expanded"] ?? true);
			if(_sub.name == "Mixer") continue;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(!sch && _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(mouse_lpress(_foc)) {
					_open = !_open;
					_sub[$ "expanded"] = _open;
				}
			}
			
			draw_sprite_ui_uniform(THEME.arrow, _open * 3, _x + ui(12), _y + lbh/2, .8, COLORS._main_icon);
			draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_x + ui(24), _y + lbh/2, _sub.name);
			
			hh += lbh + ui(4);
			_y += lbh + ui(4);
			
			if(!_open) continue;
			var _sh  = drawPaletteDirectory(_sub, _x + ui(8), _y, _m);
			
			_y += _sh;
			hh += _sh;
		}
		
		for( var i = 0, n = array_length(_dir.content); i < n; i++ ) {
			var p = _dir.content[i];
			if(p.content == undefined)
				p.content = loadPalette(p.path);
			
			var _name = p.name;
			var _path = p.path;
			var _palt = p.content;
			
			if(sch && string_pos(palette_search_string, string_lower(_name)) == 0) continue;
			if(!is_array(_palt)) continue;
			
			pre_amo  = array_length(_palt);
			row      = ceil(pre_amo / col);
			_exp     = preset_expands[$ _path] || row <= 1;
			_height  = _exp? nh + row * _gs + pd : _bh;
			
			var isHover = _hov && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, _height);
			if(isHover) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, ww, _height, COLORS._main_accent, 1);
				sp_presets.hover_content = true;
			}
			
			var cc = _palt == preset_selecting? COLORS._main_accent : COLORS._main_text_sub;
			draw_sprite_ui(THEME.arrow, _exp * 3, _x + ui(8), _y + nh / 2, .75, .75, 0, COLORS._main_text_sub);
			draw_set_text(f_p3, fa_left, fa_top, cc);
			draw_text_add(_x + ui(16), _y + ui(2), _name);
			
			if(i == -1) { draw_set_color(cc); draw_circle_prec(_x + ww - ui(10), _y + ui(10), ui(4), false); }
			
			var _hoverColor = noone;
			if(_exp) {
				_palRes     = drawPaletteGrid(_palt, _x + pd, _y + nh, _ww, _gs, { color : selector.current_color, mx : _m[0], my : _m[1] });
				_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
				
			} else drawPalette(_palt, _x + pd, _y + nh, _ww, _gs);
			
			if(_hoverColor != noone) {
				var _box = _palRes.hoverBBOX;
				draw_sprite_stretched_ext(THEME.box_r2, 1, _box[0], _box[1], _box[2], _box[3], c_white);
			}
			
			if(!click_block && _foc) {
				if(mouse_click(mb_left)) {
					if(_hoverColor != noone) {
						selector.setColor(_hoverColor);
						
					} else if(isHover) {
						preset_expands[$ _path] = !_exp;
						preset_selecting = _palt;
						click_block = true;
					}
				}
				
				if(mouse_click(mb_right)) {
					if(_hoverColor != noone) {
						menuCall("palette_window_preset_menu", [
							menuItem(__txtx("palette_mix_color", "Mix Color"), function(c) /*=>*/ { selector.setMixColor(c); }).setParam(_hoverColor),
						]);
						
					} else if(isHover) {
						menuCall("palette_window_preset_menu", [
							menuItem(__txtx("palette_editor_set_default", "Set as default"), function(p) /*=>*/ { PROJECT.setPalette(array_clone(p)); }).setParam(_palt),
							menuItem(__txtx("palette_editor_delete",      "Delete palette"), function(p) /*=>*/ { file_delete(p); __initPalette(); }).setParam(_path),
						]);
					}
				}
			}
			
			_y += _height + ui(4);
			hh += _height + ui(4);
		}
		
		return hh;
	}
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = drawPaletteDirectory(PALETTES_FOLDER, 0, _y, _m);
		if(mouse_release(mb_left)) click_block = false;
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	search_string = "";
	tb_search = new textBox(TEXTBOX_INPUT.text, function(t) /*=>*/ { search_string = string_lower(t) } )
	               .setFont(f_p2).setHide(1).setEmpty(false).setPadding(ui(24)).setAutoUpdate();
	
#endregion

#region action
	function checkMouse() {}
#endregion