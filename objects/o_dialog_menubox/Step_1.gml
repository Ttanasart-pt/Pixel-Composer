/// @description 
if !ready exit;

#region destroy
	var hovering = false;
	
	for( var i = 0; i < ds_list_size(children); i++ ) {
		var ch = children[| i];
		if(!instance_exists(ch)) continue;
		var x0 = ch.dialog_x;
		var x1 = ch.dialog_x + ch.dialog_w;
		var y0 = ch.dialog_y;
		var y1 = ch.dialog_y + ch.dialog_h;
		hovering |= point_in_rectangle(mouse_mx, mouse_my, x0, y0, x1, y1);
	}
	
	if(!hovering && mouse_check_button_pressed(mb_left))
		instance_destroy(self);
#endregion