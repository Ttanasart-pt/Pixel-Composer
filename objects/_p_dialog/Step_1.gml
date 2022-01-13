/// @description init
if !ready exit;

#region destroy
	var x0 = dialog_x - dialog_resizable * 6;
	var x1 = dialog_x + dialog_w + dialog_resizable * 6;
	var y0 = dialog_y - dialog_resizable * 6;
	var y1 = dialog_y + dialog_h + dialog_resizable * 6;
	
	if(!point_in_rectangle(mouse_mx, mouse_my, x0, y0, x1, y1)) {
		if(destroy_on_click_out && mouse_check_button_pressed(mb_left))
			instance_destroy(self);
	}
	
	doDrag();
#endregion

#region resize
	if(dialog_resizable) {
		if(dialog_resizing & 1 << 0 != 0) {
			var ww = dialog_resiz_sw + (mouse_mx - dialog_resiz_mx);
			ww = clamp(ww, dialog_w_min, dialog_w_max);
			dialog_w = ww;
		} 
		
		if(dialog_resizing & 1 << 1 != 0) {
			var hh = dialog_resiz_sh + (mouse_my - dialog_resiz_my);
			hh = clamp(hh, dialog_h_min, dialog_h_max);
			dialog_h = hh;
		}
		
		if(mouse_check_button_released(mb_left)) dialog_resizing = 0;
		
		if(distance_to_line(mouse_mx, mouse_my, dialog_x + dialog_w, dialog_y, 
			dialog_x + dialog_w, dialog_y + dialog_h) < 12) {
				
			CURSOR = cr_size_we;
			if(FOCUS == self && mouse_check_button_pressed(mb_left)) {
				dialog_resizing |= 1 << 0;
				dialog_resiz_sw = dialog_w;
				dialog_resiz_mx = mouse_mx;
				dialog_resiz_my = mouse_my;
			}
		} 
			
		if(distance_to_line(mouse_mx, mouse_my, dialog_x, dialog_y + dialog_h, 
			dialog_x + dialog_w, dialog_y + dialog_h) < 12) {
				
			if(CURSOR == cr_size_we)
				CURSOR = cr_size_nwse;
			else
				CURSOR = cr_size_ns;
			
			if(FOCUS == self && mouse_check_button_pressed(mb_left)) {
				dialog_resizing |= 1 << 1;
				dialog_resiz_sh = dialog_h;
				dialog_resiz_mx = mouse_mx;
				dialog_resiz_my = mouse_my;
			}
		}
	}
#endregion

#region resize
	if(_dialog_h != dialog_h || _dialog_w != dialog_w) {
		_dialog_h = dialog_h;
		_dialog_w = dialog_w;
		
		if(onResize != -1) onResize();
	}
#endregion