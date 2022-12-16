/// @description init
event_inherited();

#region 
	max_h = 640;
	align = fa_center;
	draggable = false;
	destroy_on_click_out = true;
	
	scrollbox = noone;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_height(f_p0, 8);
		var data = scrollbox.data;
		var _h   = array_length(data) * hght;
		var _dw  = sc_content.surface_w;
		
		for(var i = 0; i < array_length(data); i++) {
			var _ly = _y + i * hght;	
			
			if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(mouse_press(mb_left, sFOCUS)) {
					scrollbox.onModify(i);
					instance_destroy();
				}
			}
					
			draw_set_text(f_p0, align, fa_center, COLORS._main_text);
			if(align == fa_center)
				draw_text_cut(_dw / 2, _ly + hght / 2, data[i], _dw);
			else if(align == fa_left)
				draw_text_cut(ui(8), _ly + hght / 2, data[i], _dw);
		}
		
		return _h;
	});
#endregion
