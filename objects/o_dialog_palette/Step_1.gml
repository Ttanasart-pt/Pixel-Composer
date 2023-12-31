/// @description init
if !ready exit;

#region destroy
	selector.interactable = interactable;
	if(!selector.dropper_active) {
		if(sHOVER && !point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h)) {
			if(destroy_on_click_out && mouse_press(mb_left))
				instance_destroy(self);
		}
		doDrag();
	}
	
	if(sFOCUS) {
		if(keyboard_check_pressed(vk_enter)) {
			onApply(palette);
			instance_destroy();
		}
		
		if(keyboard_check_pressed(vk_escape)) {
			onApply(previous_palette);
			instance_destroy();
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