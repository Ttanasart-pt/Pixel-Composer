/// @description init
event_inherited();

#region data
	dialog_w = ui(812);
	dialog_h = ui(396);
	title_height = 52;
	destroy_on_click_out = true;
	interactable = true;
	
	name = __txtx("color_selector_title", "Color selector");
	
	previous_color = c_black;
	selector       = new colorSelector();
	drop_target    = noone;
	
	function setApply(_onApply) {
		onApply = _onApply;
		selector.onApply = _onApply;
		return self;
	}
	
	function setDefault(color) {
		selector.setColor(color);
		previous_color = color;
		return self;
	}
	
	b_cancel = button(function() {
		onApply(previous_color);
		instance_destroy();
	}).setIcon(THEME.undo, 0, COLORS._main_icon)
	  .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	
	b_apply = button(function() {
		onApply(selector.current_color);
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
#endregion

#region presets
	preset_selecting = -1;
	
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
		
		for(var i = -1; i < array_length(PALETTES); i++) {
			var pal = i == -1? {
				name    : "project",
				palette : PROJECT.attributes.palette,
				path    : ""
			} : PALETTES[i];
			
			pre_amo = array_length(pal.palette);
			row     = ceil(pre_amo / col);
			_height = preset_selecting == i? nh + row * _gs + pd : _bh;
			
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
			
			if(preset_selecting == i) 
				_palRes = drawPaletteGrid(pal.palette, pd, yy + nh, _ww, _gs, { color : selector.current_color, mx : _m[0], my : _m[1] });
			else
				drawPalette(pal.palette, pd, yy + nh, _ww, _gs);
			
			if(!click_block && mouse_click(mb_left, interactable && sFOCUS)) {
				if(preset_selecting == i && _hover && _palRes.hoverIndex > noone) {
					selector.setColor(_palRes.hoverColor);
					selector.setHSV();
					
				} else if(isHover) {
					preset_selecting = i;
					click_block = true;
				}
			}
			
			if(isHover && i >= 0 && mouse_press(mb_right, interactable && sFOCUS)) {
				hovering = pal;
				
				menuCall("palette_window_preset_menu", [
					menuItem(__txtx("palette_editor_set_default", "Set as default"), function() { PROJECT.setPalette(array_clone(hovering.palette)); }),
					menuItem(__txtx("palette_editor_delete",      "Delete palette"), function() { file_delete(hovering.path); __initPalette(); }),
				]);
			}
			
			yy += _height + ui(4);
			hh += _height + ui(4);
		}
		
		if(mouse_release(mb_left))
			click_block = false;
		
		return hh;
	})
#endregion

#region action
	function checkMouse() {}
#endregion