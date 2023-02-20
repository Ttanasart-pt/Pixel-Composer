/// @description init
event_inherited();

#region 
	max_h = 640;
	align = fa_center;
	draggable = false;
	destroy_on_click_out = true;
	selecting = -1;
	
	scrollbox = noone;
	initVal   = 0;
	update_hover = true;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_height(f_p0, 8);
		var data = scrollbox.data;
		var _dw  = sc_content.surface_w;
		var _h   = 0;
		var _ly  = _y;
		
		var hovering = -1;
		
		for(var i = 0; i < array_length(data); i++) {
			if(data[i] == -1) {
				draw_sprite_stretched(THEME.menu_separator, 0, ui(8), _ly, _dw - ui(16), ui(6));
				_ly += ui(8);
				_h  += ui(8);
				
				continue;
			}
			
			if(sHOVER && sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
				selecting = i;
				hovering  = i;
			}
			
			if(selecting == i) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(sFOCUS && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
					initVal = i;
					instance_destroy();
				}
			}
					
			draw_set_text(f_p0, align, fa_center, COLORS._main_text);
			if(align == fa_center)
				draw_text_cut(_dw / 2, _ly + hght / 2, data[i], _dw);
			else if(align == fa_left)
				draw_text_cut(ui(8), _ly + hght / 2, data[i], _dw);
			
			_ly += hght;
			_h  += hght;
		}
		
		if(update_hover) {
			UNDO_HOLDING = true;
			if(hovering > -1) scrollbox.onModify(hovering);
			else			  scrollbox.onModify(initVal);
			UNDO_HOLDING = false;
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
