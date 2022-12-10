/// @description init
if !ready exit;

#region destroy
	if(selector.dropper_active) exit;
	
	if(sHOVER && !point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h)) {
		if(destroy_on_click_out && mouse_press(mb_left))
			instance_destroy(self);
	}
	doDrag();
#endregion