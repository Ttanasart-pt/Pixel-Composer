/// @description init
event_inherited();

function __PaletteColor(_color = c_black) constructor {
	color = _color;
	x = 0;
	y = 0;
}

#region data
	dialog_w     = ui(812);
	dialog_h     = ui(440);
	title_height = 52;
	destroy_on_click_out = true;
	
	name          = __txtx("palette_editor_title", "Palette editor");
	palette       = 0;
	paletteObject = [];
	
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
	
	setColor = function(c) /*=>*/ {
		if(index_selecting[1] != 1 || palette == 0) return;
		
		var _ind = index_selecting[0];
		palette[_ind] = c;
		paletteObject[_ind].color = c;
		
		if(onApply != noone) onApply(palette);
	};
	
	onApply  = noone;
	selector = new colorSelector(setColor);
	selector.dropper_close  = false;
	selector.discretize_pal = false;
	
	previous_palette  = c_black;
	selection_surface = surface_create(1, 1);
	
	b_cancel = button(function() /*=>*/ { onApply(previous_palette); instance_destroy(); }).setIcon(THEME.undo, 0, COLORS._main_icon)
	                                                                           .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	b_apply  = button(function() /*=>*/ { onApply(palette);          instance_destroy(); }).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
	
	menu_add = [
		menuItem(__txt("Current Palette"), function() /*=>*/ {
			var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
			dia.onModify = function(txt) /*=>*/ {
				var file = file_text_open_write(txt + ".hex");
				for(var i = 0; i < array_length(palette); i++) {
					var cc = palette[i];
					var r  = number_to_hex(color_get_red(cc));
					var g  = number_to_hex(color_get_green(cc));
					var b  = number_to_hex(color_get_blue(cc));
					var a  = number_to_hex(color_get_alpha(cc));
					
					file_text_write_string(file, $"{r}{g}{b}{a}\n");
				}
				file_text_close(file);
				__initPalette();
			};
			dia.path = DIRECTORY + "Palettes/"
		}),
		
		menuItem(__txt("Lospec"), function() /*=>*/ {
			fileNameCall("", function(txt) /*=>*/ {
				if(txt == "") return;
				
				txt = string_lower(txt);
				txt = string_replace_all(txt, " ", "-");
				var _url = $"https://Lospec.com/palette-list{txt}.json";
				PALETTE_LOSPEC = http_get(_url);
			}).setName("Palette")
		}),
	];
#endregion

#region presets
	paletePresets = PALETTES;
	
	function initPalette() {
		paletePresets = array_clone(PALETTES);
		return self;
	}
	
	hovering_name = "";
	
	pal_padding = ui(9);
	sp_preset_w = ui(240) - pal_padding * 2 - ui(8);
	sp_presets  = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var _hov = sp_presets.hover && sHOVER;
		var _foc = interactable && sFOCUS;
		var ww   = sp_presets.surface_w;
		var _gs  = ui(20);
		var hh   = ui(24);
		var nh   = ui(20);
		var pd   = ui(6);
		var _ww  = ww - pd * 2;
		var hg   = nh + _gs + pd;
		var yy   = _y;
		
		for(var i = 0; i < array_length(paletePresets); i++) {
			var pal = paletePresets[i];
			
			var isHover = _hov && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg);
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, hg);
			
			if(isHover) {
				sp_presets.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_bg, 1, 0, yy, ww, hg, COLORS._main_accent, 1);
			}
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(pd, yy + ui(2), pal.name);
			drawPalette(pal.palette, pd, yy + nh, _ww, _gs);
			
			if(isHover) {
				if(mouse_press(mb_left, _foc)) {
					setPalette(array_clone(pal.palette));
					onApply(palette);
				}
				
				if(mouse_press(mb_right, _foc)) {
					hovering = pal;
					
					menuCall("palette_window_preset_menu", [
						menuItem(__txtx("palette_editor_set_default", "Set as default"), function() /*=>*/ { PROJECT.setPalette(array_clone(hovering.palette)); }),
						menuItem(__txtx("palette_editor_delete", "Delete palette"),      function() /*=>*/ { file_delete(hovering.path); __initPalette();       }),
					]);
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	});
	
	function sortPreset_name_a() { array_sort(paletePresets, function(p0, p1) /*=>*/ { return string_compare(p0.name, p1.name); }) }
	function sortPreset_name_d() { array_sort(paletePresets, function(p0, p1) /*=>*/ { return string_compare(p1.name, p0.name); }) }
	function sortPreset_size_a() { array_sort(paletePresets, function(p0, p1) /*=>*/ { return array_length(p0.palette) - array_length(p1.palette); }) }
	function sortPreset_size_d() { array_sort(paletePresets, function(p0, p1) /*=>*/ { return array_length(p1.palette) - array_length(p0.palette); }) }
	
	sort_name_type = true;
	sort_size_type = true;
	
	menu_preset_sort = [
		menuItem(__txt("Name"),  function() /*=>*/ { if(sort_name_type) sortPreset_name_a(); else sortPreset_name_d(); sort_name_type = !sort_name_type; }),
		menuItem(__txt("Size"),  function() /*=>*/ { if(sort_size_type) sortPreset_size_a(); else sortPreset_size_d(); sort_size_type = !sort_size_type; }),
	];
#endregion

#region functions
	function refreshPaletteObject() {
		if(palette == 0) return;
		
		paletteObject = array_verify_ext(paletteObject, array_length(palette), function() /*=>*/ {return new __PaletteColor()});
		for( var i = 0, n = array_length(palette); i < n; i++ ) paletteObject[i].color = palette[i];
	}
	
	function refreshPalette() {
		palette = [];
		for( var i = 0, n = array_length(paletteObject); i < n; i++ )
			palette[i] = paletteObject[i].color;
		
		onApply(palette);
	}
	
	function sortPalette(sortFunc) {
		if(index_selecting[1] < 2) { array_sort(paletteObject, sortFunc); refreshPalette(); return; }
			
		var _arr = array_create(index_selecting[1]);
		for(var i = 0; i < index_selecting[1]; i++)
			_arr[i] = paletteObject[index_selecting[0] + i];
		array_sort(_arr, sortFunc);
		
		for(var i = 0; i < index_selecting[1]; i++)
			paletteObject[index_selecting[0] + i] = _arr[i];
			
		refreshPalette();
	}
	
	function setDefault(pal) { setPalette(pal); previous_palette = array_clone(pal); }
	
	function setPalette(pal) {
		palette           = pal;	
		index_selecting   = [ 0, 0 ];
		palette_positions = {};
		
		if(!array_empty(palette)) selector.setColor(palette[0]);
		refreshPaletteObject();
	}
	
	function onResize()   { sp_presets.resize(sp_preset_w, dialog_h - ui(62)); }
	function checkMouse() {}
#endregion