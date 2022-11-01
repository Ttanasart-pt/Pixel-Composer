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
		
		renderAll();
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
	
	if(UPDATE & RENDER_TYPE.full) {
		renderAll();
		UPDATE = RENDER_TYPE.none;
	} else if(UPDATE & RENDER_TYPE.partial) {
		show_debug_message("Update partial stack size = " + string(ds_stack_size(RENDER_STACK)));
		renderUpdated();
		UPDATE = RENDER_TYPE.none;
	} 
#endregion

#region clicks
	DOUBLE_CLICK = false;
	if(mouse_check_button_pressed(mb_left)) {
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