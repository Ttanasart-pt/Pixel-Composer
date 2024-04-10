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
	
	function setDefault(color) {
		selector.setColor(color);
		previous_color = color;
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
	
	sp_preset_w = ui(240 - 32 - 16);
	sp_preset_size = ui(24);
	click_block = false;
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_preset_w - ui(40);
		var hh  = ui(32);
		var _gs = sp_preset_size;
		var yy  = _y + ui(8);
		var _height, pre_amo;
		var _hover = sHOVER && sp_presets.hover;
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = -1; i < array_length(PALETTES); i++) {
			var pal = i == -1? {
				name: "project",
				palette: PROJECT.attributes.palette,
				path: ""
			} : PALETTES[i];
			pre_amo = array_length(pal.palette);
			var col = floor(ww / _gs);
			var row = ceil(pre_amo / col);
			
			if(preset_selecting == i)
				_height = ui(28) + row * _gs + ui(12);
			else
				_height = ui(56);
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, ui(4), yy, sp_preset_w - ui(16), _height);
			if(isHover) draw_sprite_stretched_ext(THEME.ui_panel_fg, 1, ui(4), yy, sp_preset_w - ui(16), _height, COLORS._main_accent, 1);
			
			var x0 = ui(16) + (i == -1) * ui(8 + 6);
			var cc = i == preset_selecting? COLORS._main_accent : COLORS._main_text_sub;
			draw_set_text(f_p2, fa_left, fa_top, cc);
			draw_text(x0, yy + ui(8), pal.name);
			if(i == -1) {
				draw_set_color(cc);
				draw_circle_prec(ui(16) + ui(4), yy + ui(16), ui(4), false);
			}
			
			if(preset_selecting == i)
				drawPaletteGrid(pal.palette, ui(16), yy + ui(28), ww, _gs, selector.current_color);
			else
				drawPalette(pal.palette, ui(16), yy + ui(28), ww, ui(20));
			
			if(!click_block && mouse_click(mb_left, interactable && sFOCUS)) {
				if(preset_selecting == i && _hover && point_in_rectangle(_m[0], _m[1], ui(16), yy + ui(28), ui(16) + ww, yy + ui(28) + _height)) {
					var m_ax = _m[0] - ui(16);
					var m_ay = _m[1] - (yy + ui(28));
					
					var m_gx = floor(m_ax / _gs);
					var m_gy = floor(m_ay / _gs);
						
					var _index = m_gy * col + m_gx;
					if(_index < pre_amo && _index >= 0) {
						selector.setColor(pal.palette[_index]);
						selector.setHSV();
					}
				} else if(isHover) {
					preset_selecting = i;
					click_block = true;
				}
			}
			
			if(isHover) {
				if(i >= 0 && mouse_press(mb_right, interactable && sFOCUS)) {
					hovering = pal;
					
					menuCall("palette_window_preset_menu",,, [
						menuItem(__txtx("palette_editor_set_default", "Set as default"), function() { 
							DEF_PALETTE = array_clone(hovering.palette);
						}),
						menuItem(__txtx("palette_editor_delete", "Delete palette"), function() { 
							file_delete(hovering.path); 
							__initPalette();
						}),
					]);
				}
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