/// @description init
#region data
	depth = - 99 - instance_number(_p_dialog);
	
	dialog_w = 320;
	dialog_h = 320;
	_dialog_w = 320;
	_dialog_h = 320;
	dialog_x = 0;
	dialog_y = 0;
	
	dialog_resizable = false;
	dialog_resizing = 0;
	dialog_resiz_sw = 0;
	dialog_resiz_sh = 0;
	dialog_resiz_mx = 0;
	dialog_resiz_my = 0;
	dialog_w_min = 320;
	dialog_h_min = 320;
	dialog_w_max = 1000;
	dialog_h_max = 1000;
	onResize = -1;
	
	draggable = true;
	dialog_dragging = false;
	dialog_drag_sx  = 0;
	dialog_drag_sy  = 0;
	dialog_drag_mx  = 0;
	dialog_drag_my  = 0;
	
	function doDrag() {
		if(!draggable) return;
		
		if(dialog_dragging) {
			dialog_x = dialog_drag_sx + mouse_mx - dialog_drag_mx;
			dialog_y = dialog_drag_sy + mouse_my - dialog_drag_my;
		
			if(mouse_check_button_released(mb_left))
				dialog_dragging = false;
		}
	
		if(FOCUS == self) {
			if(destroy_on_escape && keyboard_check_pressed(vk_escape))
				instance_destroy(self);
			if(mouse_check_button_pressed(mb_left)) {
				if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, 
				dialog_x + dialog_w, dialog_y + 32)) {
					dialog_dragging = true;
					dialog_drag_sx  = dialog_x;
					dialog_drag_sy  = dialog_y;
					dialog_drag_mx  = mouse_mx;
					dialog_drag_my  = mouse_my;
				}
			}
		}
	}
	
	alarm[0] = 1;
	ready = false;
	
	destroy_on_escape    = true;
	destroy_on_click_out = false;
	anchor = ANCHOR.none;
#endregion

#region focus
	setFocus(self);
	FOCUS_STR = "Dialog";
	
	function checkFocus() {
		var x0 = dialog_x - dialog_resizable * 6;
		var x1 = dialog_x + dialog_w + dialog_resizable * 6;
		var y0 = dialog_y - dialog_resizable * 6;
		var y1 = dialog_y + dialog_h + dialog_resizable * 6;
	
		if(point_in_rectangle(mouse_mx, mouse_my, x0, y0, x1, y1)) {	
			if(depth < DIALOG_DEPTH_HOVER) {
				DIALOG_DEPTH_HOVER = depth;
				HOVER = self;
			
				if(mouse_check_button_pressed(mb_left) || 
					mouse_check_button_pressed(mb_right) ||
					mouse_check_button_pressed(mb_middle)) {
				
					setFocus(self);
					FOCUS_STR = "Dialog";
				}
			}
		}
	}
	
	function resetPosition() {
		if(anchor == ANCHOR.none) {
			dialog_x = xstart - dialog_w / 2;
			dialog_y = ystart - dialog_h / 2;
		} else {
			if(anchor & ANCHOR.left)   dialog_x = min(xstart, WIN_SW - dialog_w);
			if(anchor & ANCHOR.right)  dialog_x = max(xstart - dialog_w, 0);
			if(anchor & ANCHOR.top)    dialog_y = min(ystart, WIN_SH - dialog_h);
			if(anchor & ANCHOR.bottom) dialog_y = max(ystart - dialog_h, 0);
		}
		dialog_x = round(dialog_x);
		dialog_y = round(dialog_y);
	}
#endregion

