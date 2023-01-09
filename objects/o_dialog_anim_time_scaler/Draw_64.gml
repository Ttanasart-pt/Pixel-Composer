/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Animation scaler");
#endregion

#region scaler
	var yy = dialog_y + ui(44);
	
	tb_scale_frame.active = sFOCUS;
	tb_scale_frame.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy + ui(17), "Target frame length");
	var tb_x = dialog_x + ui(200);
	tb_scale_frame.draw(tb_x, yy, ui(96), TEXTBOX_HEIGHT, scale_to, mouse_ui);
	
	var sx1 = tb_x + ui(96);
	draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text_sub);
	draw_text(sx1, yy + ui(38), "Scaling factor: " + string(scale_to / ANIMATOR.frames_total));
	
	var bx = sx1 + ui(16);
	var by = yy;
	if(buttonInstant(THEME.button_lime, bx, by, ui(34), ui(34), mouse_ui, sFOCUS, sHOVER, "", THEME.accept, 0, COLORS._main_icon_dark) == 2) {
		var fac = scale_to / ANIMATOR.frames_total;
		var key = ds_map_find_first(NODE_MAP);
		repeat(ds_map_size(NODE_MAP)) {
			var n = NODE_MAP[? key];
			key = ds_map_find_next(NODE_MAP, key);
			if(!n || !n.active) continue;
			
			for(var i = 0; i < ds_list_size(n.inputs); i++) {
				var in = n.inputs[| i];
				if(!in.animator.is_anim) continue;
				for(var j = 0; j < ds_list_size(in.animator.values); j++) {
					var t = in.animator.values[| j];
					t.time = t.ratio * scale_to;
				}
			}
		}
		ANIMATOR.frames_total = scale_to;
		instance_destroy();
	}
#endregion