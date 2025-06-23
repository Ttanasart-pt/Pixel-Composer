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
	function initPalette() { 
		paletePresets  = array_clone(PALETTES); 
		currentPresets = paletePresets;
		return self; 
	} initPalette();
	
	preset_selecting = -1;
	preset_expands   = {};
	
	pal_padding    = ui(9);
	sp_preset_w    = ui(240) - pal_padding * 2 - ui(8);
	sp_preset_size = ui(20);
	click_block    = false;
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var ww  = sp_presets.surface_w;
		var _gs = sp_preset_size;
		var hh  = ui(24);
		var nh  = ui(20);
		var pd  = ui(6);
		var _ww = ww - pd * 2;
		var _bh = nh + _gs + pd;
		
		var _hover = sHOVER && sp_presets.hover;
		var _height, pre_amo, _palRes;
		
		var yy  = _y;
		var col = max(1, floor(_ww / _gs)), row;
		
		for(var i = -1; i < array_length(paletePresets); i++) {
			var  pal = i == -1? {
				name    : "project",
				palette : PROJECT.attributes.palette,
				path    : ""
			} : paletePresets[i];
			
			var _exp = preset_expands[$ i];
			pre_amo  = array_length(pal.palette);
			row      = ceil(pre_amo / col);
			_height  = _exp? nh + row * _gs + pd : _bh;
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, _height);
			if(isHover) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, 0, yy, ww, _height, COLORS._main_accent, 1);
				sp_presets.hover_content = true;
			}
			
			var cc = i == preset_selecting? COLORS._main_accent : COLORS._main_text_sub;
			draw_set_text(f_p2, fa_left, fa_top, cc);
			draw_text_add(pd, yy + ui(2), pal.name);
			
			if(i == -1) { draw_set_color(cc); draw_circle_prec(ww - ui(10), yy + ui(10), ui(4), false); }
			
			var _hoverColor = noone;
			if(_exp || row == 1) {
				_palRes     = drawPaletteGrid(pal.palette, pd, yy + nh, _ww, _gs, { color : selector.current_color, mx : _m[0], my : _m[1] });
				_hoverColor = _palRes.hoverIndex > noone? _palRes.hoverColor : noone;
			} else drawPalette(pal.palette, pd, yy + nh, _ww, _gs);
			
			if(_hoverColor != noone) {
				var _box = _palRes.hoverBBOX;
				draw_sprite_stretched_ext(THEME.box_r2, 1, _box[0], _box[1], _box[2], _box[3], c_white);
			}
			
			if(!click_block && interactable && sFOCUS) {
				if(mouse_click(mb_left)) {
					if(_hoverColor != noone) {
						selector.setColor(_hoverColor);
						
					} else if(isHover) {
						preset_expands[$ i] = !_exp;
						preset_selecting = i;
						click_block = true;
					}
				}
				
				if(mouse_click(mb_right)) {
					if(_hoverColor != noone) {
						menuCall("palette_window_preset_menu", [
							menuItem(__txtx("palette_mix_color", "Mix Color"), function(c) /*=>*/ { selector.setMixColor(c); }).setParam(_hoverColor),
						]);
						
					} else if(isHover && i >= 0) {
						hovering = pal;
				
						menuCall("palette_window_preset_menu", [
							menuItem(__txtx("palette_editor_set_default", "Set as default"), function() /*=>*/ { PROJECT.setPalette(array_clone(hovering.palette)); }),
							menuItem(__txtx("palette_editor_delete",      "Delete palette"), function() /*=>*/ { file_delete(hovering.path); __initPalette(); }),
						]);
					}
				}
			}
			
			yy += _height + ui(4);
			hh += _height + ui(4);
		}
		
		if(mouse_release(mb_left))
			click_block = false;
		
		return hh;
	});
	
	//////////////////////// SEARCH ////////////////////////
	
	search_string = "";
	tb_search = new textBox(TEXTBOX_INPUT.text, function(t) /*=>*/ {return searchPalette(t)} )
	               .setFont(f_p2)
	               .setHide(1)
	               .setEmpty(false)
	               .setPadding(ui(24))
	               .setAutoUpdate();
	
	function searchPalette(t) {
		search_string = t;
		
		if(search_string == "") {
			paletePresets = currentPresets;
			return;
		}
		
		paletePresets = [];
		var _pr = ds_priority_create();
		
		for( var i = 0, n = array_length(currentPresets); i < n; i++ ) {
			var _prest = currentPresets[i];
			var _match = string_partial_match(_prest.name, search_string);
			if(_match <= -9999) continue;
			
			ds_priority_add(_pr, _prest, _match);
		}
		
		repeat(ds_priority_size(_pr))
			array_push(paletePresets, ds_priority_delete_max(_pr));
		
		ds_priority_destroy(_pr);
	}
	
#endregion

#region action
	function checkMouse() {}
#endregion