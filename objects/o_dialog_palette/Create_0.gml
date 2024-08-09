/// @description init
event_inherited();

#region data
	dialog_w     = ui(812);
	dialog_h     = ui(440);
	title_height = 52;
	destroy_on_click_out = true;
	
	name    = __txtx("palette_editor_title", "Palette editor");
	palette = 0;
	
	index_sel_start = 0;
	index_selecting = [ 0, 0 ];
	index_dragging  = noone;
	interactable    = true;
	drop_target     = noone;
	
	mouse_interact  = false;
	
	colors_selecting = [];
	
	index_drag_x = 0; index_drag_x_to = 0;
	index_drag_y = 0; index_drag_y_to = 0;
	index_drag_w = 0; index_drag_w_to = 0;
	index_drag_h = 0; index_drag_h_to = 0;
	
	palette_positions = {}
	
	setColor = function(color) {
		if(index_selecting[1] != 1 || palette == 0) return;
		
		palette[index_selecting[0]] = color;
		
		if(onApply == noone) return;
		onApply(palette);
	}
	
	onApply  = noone;
	selector = new colorSelector(setColor);
	selector.dropper_close  = false;
	selector.discretize_pal = false;
	
	previous_palette = c_black;
	
	selection_surface = surface_create(1, 1);
	
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
		index_selecting = [ 0, 0 ];
		if(!array_empty(palette)) 
			selector.setColor(palette[0]);
		
		palette_positions = {};
	}
#endregion

#region presets
	hovering_name = "";
	
	pal_padding = ui(9);
	sp_preset_w = ui(240) - pal_padding * 2 - ui(8);
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var ww  = sp_presets.surface_w;
		var _gs = ui(20);
		var hh  = ui(24);
		var nh  = ui(20);
		var pd  = ui(6);
		var _ww = ww - pd * 2;
		var hg  = nh + _gs + pd;
		
		var yy = _y;
		
		for(var i = -1; i < array_length(PALETTES); i++) {
			var pal = i == -1? {
				name    : "project",
				palette : PROJECT.attributes.palette,
				path    : ""
			} : PALETTES[i];
			
			var isHover = sHOVER && sp_presets.hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg);
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, hg);
			
			if(isHover) {
				sp_presets.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_bg, 1, 0, yy, ww, hg, COLORS._main_accent, 1);
			}
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(pd, yy + ui(2), pal.name);
			drawPalette(pal.palette, pd, yy + nh, _ww, _gs);
			
			if(isHover) {
				if(mouse_press(mb_left, interactable && sFOCUS)) {
					palette = array_clone(pal.palette);
					onApply(palette);
					
					index_selecting = [ 0, 0 ];
					selector.setColor(palette[0], false);
				}
				
				if(i >= 0 && mouse_press(mb_right, interactable && sFOCUS)) {
					hovering = pal;
					
					menuCall("palette_window_preset_menu",,, [
						menuItemAction(__txtx("palette_editor_set_default", "Set as default"), function() { 
							PROJECT.setPalette(array_clone(hovering.palette));
						}),
						menuItemAction(__txtx("palette_editor_delete", "Delete palette"), function() { 
							file_delete(hovering.path); 
							__initPalette();
						}),
					]);
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
		if(index_selecting[1] < 2)
			array_sort(palette, sortFunc);
		else {
			var _arr = array_create(index_selecting[1]);
			for(var i = 0; i < index_selecting[1]; i++)
				_arr[i] = palette[index_selecting[0] + i];
			array_sort(_arr, sortFunc);
			
			for(var i = 0; i < index_selecting[1]; i++)
				palette[index_selecting[0] + i] = _arr[i];
		}
		onApply(palette);
	}
#endregion

#region action
	function onResize()   { sp_presets.resize(sp_preset_w, dialog_h - ui(62)); }
	function checkMouse() {}
#endregion