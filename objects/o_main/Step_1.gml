/// @description init
#region window
	//if(keyboard_check_pressed(vk_f12)) DEBUG = !DEBUG;
	
	if(_cursor != CURSOR) {
		window_set_cursor(CURSOR);
		_cursor = CURSOR;
	}
	CURSOR = cr_default;
	
	if((win_wp != WIN_W || win_hp != WIN_H) && (WIN_W > 1 && WIN_H > 1)) {
		display_refresh();
		Render();
	}
#endregion

#region focus
	HOVER = noone;
	
	if(PANEL_MAIN != 0)
		PANEL_MAIN.stepBegin();
	DIALOG_DEPTH_HOVER = 0;
	
	with(_p_dialog) {
		checkFocus();	
	}
#endregion

#region nodes
	for(var i = 0; i < ds_list_size(NODES); i++) {
		NODES[| i].stepBegin();
	}
	
	if(UPDATE & RENDER_TYPE.full)
		Render();
	if(UPDATE & RENDER_TYPE.partial)
		Render(true);
	UPDATE = RENDER_TYPE.none;
#endregion

#region clicks
	DOUBLE_CLICK = false;
	if(mouse_press(mb_left)) {
		if(dc_check > 0) {
			DOUBLE_CLICK = true;
			dc_check = 0;
		} else {
			dc_check = PREF_MAP[? "double_click_delay"];	
		}
	}
	
	dc_check--;
#endregion

#region step
	if(array_length(action_last_frame) > 0) {
		ds_stack_push(UNDO_STACK, action_last_frame);
		ds_stack_clear(REDO_STACK);
	}
	action_last_frame = [];
#endregion

#region dialog
	if(!ds_list_empty(DIALOGS))
		DIALOGS[| ds_list_size(DIALOGS) - 1].checkMouse();
	
	if(mouse_release(mb_left))
		DIALOG_CLICK = true;
#endregion