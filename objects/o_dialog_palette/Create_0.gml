/// @description init
event_inherited();

#region data
	dialog_w = ui(812);
	dialog_h = ui(440);
	destroy_on_click_out = true;
	
	name = "Palette editor";
	palette = 0;
	
	index_selecting = 0;
	index_dragging = -1;
	
	setColor = function(color) {
		if(index_selecting == -1 || palette == 0) return;
		palette[index_selecting] = color;
		onApply(palette);
	}
	
	selector = new colorSelector(setColor);
	
	function setPalette(pal) {
		palette = pal;	
		index_selecting = 0;
		if(array_length(palette) > 0)
			selector.setColor(palette[0]);
	}
#endregion

#region presets
	presets		= ds_list_create();
	preset_name = ds_list_create();
	
	function presetCollect() {
		ds_list_clear(presets);
		ds_list_clear(preset_name);
		
		var path = DIRECTORY + "Palettes/"
		var file = file_find_first(path + "*", 0);
		while(file != "") {
			ds_list_add(presets,		loadPalette(path + file));
			ds_list_add(preset_name,	filename_name(file));
			file = file_find_next();
		}
		file_find_close();
	}
	presetCollect();
	
	sp_preset_w = ui(240 - 32 - 16);
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_preset_w - ui(40);
		var hh = ui(32);
		var yy = _y + ui(8);
		var hg = ui(52);
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = 0; i < ds_list_size(presets); i++) {
			var isHover = sHOVER && sp_presets.hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + hg);
			draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(4), yy, sp_preset_w - ui(16), hg);
			if(isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_preset_w - ui(16), hg, COLORS._main_accent, 1);
				
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(16), yy + ui(8), preset_name[| i]);
			drawPalette(presets[| i], ui(16), yy + ui(28), ww, ui(16));
			
			if(isHover && mouse_press(mb_left, sFOCUS)) {
				palette = array_create(array_length(presets[| i]));
				for( var j = 0; j < array_length(presets[| i]); j++ ) {
					palette[j] = presets[| i][j];
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	})
#endregion

#region tools
	function __sortBright(c1, c2) {
		var r1 = color_get_red(c1);
		var g1 = color_get_green(c1);
		var b1 = color_get_blue(c1);
		var l1 = 0.299 * r1 + 0.587 * g1 + 0.114 * b1;
			
		var r2 = color_get_red(c2);
		var g2 = color_get_green(c2);
		var b2 = color_get_blue(c2);
		var l2 = 0.299 * r2 + 0.587 * g2 + 0.224 * b2;
			
		return l2 - l1;
	}
	
	function __sortDark(c1, c2) {
		return -__sortBright(c1, c2);
	}
	
	function __sortHue(c1, c2) {
		var h1 = color_get_hue(c1);
		var s1 = color_get_saturation(c1);
		var v1 = color_get_value(c1);
		var l1 = 0.8 * h1 + 0.1 * s1 + 0.1 * v1;
			
		var h2 = color_get_hue(c2);
		var s2 = color_get_saturation(c2);
		var v2 = color_get_value(c2);
		var l2 = 0.8 * h2 + 0.1 * s2 + 0.1 * v2;
			
		return l2 - l1;
	}
		
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