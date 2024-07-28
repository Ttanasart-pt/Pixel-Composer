/// @description init
event_inherited();

#region 
	dialog_w = 560;
	max_h = 640;
	draggable = false;
	destroy_on_click_out = true;
	selecting = -1;
	
	scrollbox = noone;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hght = line_get_height(f_p0, 8);
		var data = FONT_INTERNAL;
		var _h   = array_length(data) * hght;
		var _dw  = sc_content.surface_w;
		
		sc_content.hover_content = true;
		
		for(var i = 0; i < array_length(data); i++) {
			var _ly = _y + i * hght;	
			var fullpath = data[i];
			
			if(sHOVER && sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
				selecting = i;
			}
			
			if(selecting == i) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(sFOCUS && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
					scrollbox.onModify(i);
					instance_destroy();
				}
			}
					
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text_cut(ui(8), _ly + hght / 2, filename_name_only(data[i]), _dw);
			
			if(ds_map_exists(FONT_SPRITES, fullpath)) {
				var spr = FONT_SPRITES[? fullpath];
				var sw  = sprite_get_width(spr);
				var sh  = sprite_get_height(spr);
				var ss  = (hght - ui(8)) / sh;
				
				sw *= ss;
				sh *= ss;
				
				draw_sprite_ext(spr, 0, _dw - ui(8) - sw, _ly + hght / 2 - sh / 2, ss, ss, 0, c_white, 1);
			}
		}
		
		if(sFOCUS) {
			if(keyboard_check_pressed(vk_up)) {
				selecting--;
				if(selecting < 0) selecting = array_length(data) - 1;
			}
			
			if(keyboard_check_pressed(vk_down))
				selecting = safe_mod(selecting + 1, array_length(data));
			
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		return _h;
	});
#endregion
