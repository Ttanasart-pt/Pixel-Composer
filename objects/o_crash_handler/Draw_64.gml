/// @description 
gameframe_update();

draw_clear(#1c1c23);
var w = 640;
var h = 480;

if(win_w != w || win_h != h) {
	display_set_gui_size(w, h);
	win_w = w;
	win_h = h;
}

draw_set_text(_f_p1, fa_left, fa_center, c_white);
draw_text(34, 18, "Pixel Composer crashed");
draw_sprite_ext(s_noti_icon_error, 0, 18, 18, 0.5, 0.5, 0, c_white, 1);

#region display
	var bx0 = w - 32;
	var by0 = 0;
	var bx1 = w;
	var by1 = 32;
	if(point_in_rectangle(mouse_mx, mouse_my, bx0, by0, bx1, by1)) {
		draw_sprite_ext(s_window_exit, 0, bx0 + 16, by0 + 16, 0.5, 0.5, 0, #eb004b, 1);
		if(mouse_check_button(mb_left))
			game_end();
	} else 
		draw_sprite_ext(s_window_exit, 0, bx0 + 16, by0 + 16, 0.5, 0.5, 0, c_white, 1);

	var x0 = 8;
	var y0 = 32;
	var x1 = w - 8;
	var y1 = h - 8 - 32 - 8;
	var tw = max(1, x1 - x0);
	var th = max(1, y1 - y0);
	
	draw_sprite_stretched(s_textbox, 3, x0, y0, tw, th);
	draw_sprite_stretched(s_textbox, 0, x0, y0, tw, th);
	
	log_surface = surface_verify(log_surface, tw - 16, th - 16);
	log_y = lerp_float(log_y, log_y_to, 5);
	
	var log_y_max = 0;
	surface_set_target(log_surface);
		draw_clear_alpha(0, 0);
		BLEND_ALPHA_MULP
		draw_set_text(_f_p1, fa_left, fa_top, c_white);
		log_y_max = draw_text_ext_add(0, log_y, crash_content, -1, tw - 16);
		BLEND_NORMAL
	surface_reset_target();
	
	log_y_max = max(0, log_y_max - th + 64);
	if(mouse_wheel_down())	log_y_to = clamp(log_y_to - 64, -log_y_max, 0);
	if(mouse_wheel_up())	log_y_to = clamp(log_y_to + 64, -log_y_max, 0);
	
	BLEND_ADD
	draw_surface(log_surface, x0 + 8, y0 + 8);
	BLEND_NORMAL
#endregion

#region copy
	draw_set_text(_f_p2, fa_left, fa_center, #8fde5d);
	var bx1 = x1 - 8;
	var bx0 = bx1 - 32 - string_width("Copy ");
	var by0 = y0 + 8;
	var by1 = by0 + 32;

	if(point_in_rectangle(mouse_mx, mouse_my, bx0, by0, bx1, by1)) {
		if(mouse_check_button(mb_left)) {
			draw_sprite_stretched_ext(s_button_hide_fill, 2, bx0, by0, bx1 - bx0, 32, #6d6d81, 1);
			clipboard_set_text(crash_content);
		}
	
		draw_sprite_stretched(s_button_hide_fill, 1, bx0, by0, bx1 - bx0, 32);
	}

	draw_sprite_ext(s_copy, 0, bx0 + 16, by0 + 16, 0.5, 0.5, 0, #8fde5d, 1);
	draw_text(bx0 + 32, by0 + 16, "Copy ");
#endregion

#region close
	draw_set_text(_f_p2, fa_center, fa_center, c_white);
	var bw = 160;
	var bh = 32;
	var bx0 = w / 2 - bw / 2 - 8 - bw;
	var by0 = h - 8 - bh;

	if(point_in_rectangle(mouse_mx, mouse_my, bx0, by0, bx0 + bw, by0 + bh)) {
		if(mouse_check_button_pressed(mb_left)) 
			game_end();
			
		if(mouse_check_button(mb_left))
			draw_sprite_stretched(s_button, 2, bx0, by0, bw, bh);
		else 	
			draw_sprite_stretched(s_button, 1, bx0, by0, bw, bh);
	} else 
		draw_sprite_stretched(s_button, 0, bx0, by0, bw, bh);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Close");
#endregion

#region open log
	draw_set_text(_f_p2, fa_center, fa_center, c_white);
	var bw = 160;
	var bh = 32;
	var bx0 = w / 2 - bw / 2;
	var by0 = h - 8 - bh;

	if(point_in_rectangle(mouse_mx, mouse_my, bx0, by0, bx0 + bw, by0 + bh)) {
		if(mouse_check_button_pressed(mb_left)) 
			shellOpenExplorer(DIRECTORY + "log");
			
		if(mouse_check_button(mb_left))
			draw_sprite_stretched(s_button, 2, bx0, by0, bw, bh);
		else 	
			draw_sprite_stretched(s_button, 1, bx0, by0, bw, bh);
	} else 
		draw_sprite_stretched(s_button, 0, bx0, by0, bw, bh);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Open log folder");
#endregion

#region restart
	draw_set_text(_f_p2, fa_center, fa_center, c_white);
	var bw = 160;
	var bh = 32;
	var bx0 = w / 2 + bw / 2 + 8;
	var by0 = h - 8 - bh;

	if(point_in_rectangle(mouse_mx, mouse_my, bx0, by0, bx0 + bw, by0 + bh)) {
		if(mouse_check_button_pressed(mb_left)) {
			var path = executable_get_pathname();
			execute_shell(path, "--crashed");
		}
		
		if(mouse_check_button(mb_left))
			draw_sprite_stretched(s_button, 2, bx0, by0, bw, bh);
		else 	
			draw_sprite_stretched(s_button, 1, bx0, by0, bw, bh);
	} else 
		draw_sprite_stretched(s_button, 0, bx0, by0, bw, bh);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Restart application");
#endregion

#region discord
	draw_set_text(_f_p2, fa_center, fa_center, c_white);
	var bw = 32;
	var bh = 32;
	var bx0 = w - 8 - bw;
	var by0 = h - 8 - bh;

	if(point_in_rectangle(mouse_mx, mouse_my, bx0, by0, bx0 + bw, by0 + bh)) {
		if(mouse_check_button_pressed(mb_left))
			url_open($"https://discord.com/channels/953634069646835773/1069552823047553076");
		
		if(mouse_check_button(mb_left))
			draw_sprite_stretched(s_button_hide_fill, 2, bx0, by0, bw, bh);
		else 	
			draw_sprite_stretched(s_button_hide_fill, 1, bx0, by0, bw, bh);
	} 
	
	draw_sprite_ext(s_discord, 0, bx0 + 16, by0 + 16, 0.5, 0.5, 0, c_white, 0.5);
#endregion

draw_sprite_stretched_ext(s_window_frame, 0, 0, 0, w, h, #eb004b, 1);