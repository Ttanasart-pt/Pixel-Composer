/// @description init
event_inherited();

#region data
	dialog_w = ui(812);
	dialog_h = ui(396);
	destroy_on_click_out = true;
	
	name = "Color selector";
	
	selector = new colorSelector();
	
	b_apply = button(function() {
		onApply(selector.current_color);
		DIALOG_CLICK = false;
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
#endregion

#region presets
	presets		= ds_list_create();
	preset_name = ds_list_create();
	preset_selecting = -1;
	
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
		
		for(var i = 0; i < ds_list_size(presets); i++) {
			pre_amo = array_length(presets[| i]);
			var col = floor(ww / _gs);
			var row = ceil(pre_amo / col);
			
			if(preset_selecting == i)
				_height = ui(28) + row * _gs + ui(12);
			else
				_height = ui(56);
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(4), yy, sp_preset_w - ui(16), _height);
			if(isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_preset_w - ui(16), _height, COLORS._main_accent, 1);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(16), yy + ui(8), preset_name[| i]);
			if(preset_selecting == i)
				drawPaletteGrid(presets[| i], ui(16), yy + ui(28), ww, _gs, selector.current_color);
			else
				drawPalette(presets[| i], ui(16), yy + ui(28), ww, ui(20));
			
			if(!click_block && mouse_click(mb_left, sFOCUS)) {
				if(preset_selecting == i && _hover && point_in_rectangle(_m[0], _m[1], ui(16), yy + ui(28), ui(16) + ww, yy + ui(28) + _height)) {
					var m_ax = _m[0] - ui(16);
					var m_ay = _m[1] - (yy + ui(28));
					
					var m_gx = floor(m_ax / _gs);
					var m_gy = floor(m_ay / _gs);
						
					var _index = m_gy * col + m_gx;
					if(_index < pre_amo && _index >= 0) {
						selector.setColor(presets[| i][_index]);
						selector.setHSV();
					}
				} else if(isHover) {
					preset_selecting = i;
					click_block = true;
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