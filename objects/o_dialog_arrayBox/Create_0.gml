/// @description init
event_inherited();

#region 
	max_h = 640;
	align = fa_left;
	draggable = false;
	destroy_on_click_out = true;
	selecting = -1;
	
	arrayBox = noone;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hght = line_height(f_p0, 8);
		var _h   = array_length(arrayBox.data) * hght;
		var _dw  = sc_content.surface_w;
		var array = arrayBox.arraySet;
		
		for(var i = 0; i < array_length(arrayBox.data); i++) {
			var _ly = _y + i * hght;	
			var yc  = _ly + hght / 2;
			var exists = false;
			
			for( var j = 0; j < array_length(array); j++ ) {
				if(arrayBox.data[i] == array[j])
					exists = true;
			}
			
			var ind = exists? 2 : 0;
			
			if(sHOVER && sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1))
				selecting = i;
			
			if(selecting == i) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				ind++;
				
				if(sFOCUS && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
					if(exists)	array_remove(array, arrayBox.data[i]);
					else		array_push(array, arrayBox.data[i]);
				}
			}
			
			var bs = ui(22);
			draw_sprite_stretched(THEME.checkbox, ind, ui(20) - bs / 2, yc - bs / 2, bs, bs);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text_cut(ui(40), yc, arrayBox.data[i], _dw);
		}
		
		if(sFOCUS) {
			if(keyboard_check_pressed(vk_up)) {
				selecting--;
				if(selecting < 0) selecting = array_length(arrayBox.data) - 1;
			}
			
			if(keyboard_check_pressed(vk_down))
				selecting = safe_mod(selecting + 1, array_length(arrayBox.data));
				
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		return _h;
	});
#endregion
