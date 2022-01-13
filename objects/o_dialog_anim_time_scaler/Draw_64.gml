/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Animation scaler");
#endregion

#region scaler
	var yy = dialog_y + 44;
	
	tb_scale_frame.active = FOCUS == self;
	tb_scale_frame.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Target frame length");
	tb_scale_frame.draw(dialog_x + dialog_w - 24 - 96, yy, 96, 34, scale_to, [mouse_mx, mouse_my]);
	
	yy += 32;
	draw_set_text(f_p1, fa_right, fa_center, c_ui_blue_grey);
	draw_text(dialog_x + dialog_w - 24, yy + 17, "Scaling factor: " + string(scale_to / ANIMATOR.frames_total));
	
	var bx = dialog_x + dialog_w - 24 - 36;
	var by = dialog_y + dialog_h - 24 - 36;
	if(buttonInstant(s_button_lime, bx, by, 36, 36, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, "", s_icon_accept_24, 0, c_ui_blue_black) == 2) {
		var fac = scale_to / ANIMATOR.frames_total;
		var key = ds_map_find_first(NODE_MAP);
		repeat(ds_map_size(NODE_MAP)) {
			var n = NODE_MAP[? key];
			if(n && n.active) {
				for(var i = 0; i < ds_list_size(n.inputs); i++) {
					var in = n.inputs[| i];
					if(in.value.is_anim) {
						for(var j = 0; j < ds_list_size(in.value.values); j++) {
							var t = in.value.values[| j];
							t.time = round(t.time * fac);
						}
					}
				}
			}
			key = ds_map_find_next(NODE_MAP, key);
		}
		ANIMATOR.frames_total = scale_to;
		instance_destroy();
	}
#endregion