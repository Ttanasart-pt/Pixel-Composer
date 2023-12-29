/// @description init
event_inherited();

#region data
	dialog_w     = ui(812);
	dialog_h     = ui(440);
	title_height = 52;
	destroy_on_click_out = true;
	
	name    = __txtx("palette_editor_title", "Palette editor");
	palette = 0;
	
	index_selecting = 0;
	index_dragging  = -1;
	interactable    = true;
	
	setColor = function(color) {
		if(index_selecting == -1 || palette == 0) return;
		palette[index_selecting] = color;
		
		if(onApply == noone) return;
		onApply(palette);
	}
	
	onApply  = noone;
	selector = new colorSelector(setColor);
	selector.dropper_close  = false;
	selector.discretize_pal = false;
	
	previous_palette = c_black;
	
	function setDefault(pal) {
		setPalette(pal);
		previous_palette = array_clone(pal);
	}
	
	b_cancel = button(function() {
		onApply(previous_palette);
		instance_destroy();
	}).setIcon(THEME.undo, 0, COLORS._main_icon)
	  .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	
	b_apply = button(function() {
		onApply(palette);
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
	
	function setPalette(pal) {
		palette = pal;	
		index_selecting = 0;
		if(array_length(palette) > 0)
			selector.setColor(palette[0]);
	}
#endregion

#region presets
	hovering_name = "";
	
	sp_preset_w = ui(240 - 32 - 16);
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(62), function(_y, _m) {
		var ww = sp_preset_w - ui(40);
		var hh = ui(32);
		var yy = _y + ui(8);
		var hg = ui(52);
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = -1; i < array_length(PALETTES); i++) {
			var pal = i == -1? {
				name: "project",
				palette: PROJECT.attributes.palette,
				path: ""
			} : PALETTES[i];
			var isHover = sHOVER && sp_presets.hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + hg);
			draw_sprite_stretched(THEME.ui_panel_bg, 3, ui(4), yy, sp_preset_w - ui(16), hg);
			if(isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_preset_w - ui(16), hg, COLORS._main_accent, 1);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(16), yy + ui(8), pal.name);
			drawPalette(pal.palette, ui(16), yy + ui(28), ww, ui(16));
			
			if(isHover) {
				if(mouse_press(mb_left, interactable && sFOCUS)) {
					palette = array_create(array_length(pal.palette));
					for( var j = 0; j < array_length(pal.palette); j++ )
						palette[j] = pal.palette[j];
				}
				
				if(mouse_press(mb_right, interactable && sFOCUS)) {
					hovering_name = pal.path;
					menuCall("palette_window_preset_menu",,, [
						menuItem(__txtx("palette_editor_delete", "Delete palette"), function() { 
							file_delete(hovering_name); 
							__initPalette();
						})
					])
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	});
	
	sp_presets.always_scroll = true;
#endregion

#region tools
	function sortPalette(sortFunc) {
		array_sort(palette, sortFunc);
		onApply(palette);
	}
#endregion

#region action
	onResize = function() {
		sp_presets.resize(sp_preset_w, dialog_h - ui(62));
	}
	
	function checkMouse() {}
#endregion