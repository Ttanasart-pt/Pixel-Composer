/// @description init
#region draw
	var hght = line_height(f_p0, 8);
	
	draw_sprite_stretched(s_textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	for(var i = 0; i < array_length(scrollbox.data_list); i++) {
		var _ly = dialog_y + i * hght;	
					
		if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, _ly + 1, dialog_x + dialog_w, _ly + hght - 1)) {
			draw_sprite_stretched_ext(s_textbox, 3, dialog_x, _ly, dialog_w, hght, c_ui_blue_white, 1);
			
			if(mouse_check_button_pressed(mb_left)) {
				scrollbox.onModify(i);
				instance_destroy();
			}
		}
					
		draw_set_text(f_p0, align, fa_center, c_white);
		if(align == fa_center)
			draw_text(dialog_x + dialog_w / 2, _ly + hght / 2, scrollbox.data_list[i]);
		else if(align == fa_left)
			draw_text(dialog_x + ui(8), _ly + hght / 2, scrollbox.data_list[i]);
	}
#endregion