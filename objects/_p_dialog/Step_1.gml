/// @description init
if(init_pressing && mouse_lrelease())
	init_pressing = false;

if !ready  exit;
if !active exit;

#region window control
	if(sFOCUS && keyboard_check_pressed(vk_escape)) {
		if(PREFERENCES.panel_force_on_escape || (destroy_on_escape && checkClosable()))
			instance_destroy();
	}
	
	if(is_winwin(window)) {
		winwin_set_caption(window, title);
		winwin_set_rectangle(window, window_get_x() + dialog_x, window_get_y() + dialog_y, dialog_w, dialog_h);
	}
#endregion

#region resize
	if(_dialog_h != dialog_h || _dialog_w != dialog_w) {
		_dialog_h = dialog_h;
		_dialog_w = dialog_w;
		
		if(onResize != undefined) onResize();
	}
	
#endregion