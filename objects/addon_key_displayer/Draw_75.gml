/// @description 
#region draw 
	var key = "";
	
	for( var i = 0, n = array_length(extra_keys); i < n; i++ ) {
		if(keyboard_check(extra_keys[i][0]))
			key += key == ""? extra_keys[i][1] : (" + " + extra_keys[i][1]);
	}
	
	if(keyboard_check(vk_anykey)) {
		var pres = last_key;
		
		if(pres >= 32 && pres <= 126) {
			pres = string_upper(ansi_char(pres));
			if(pres == " ") pres = "space";
			key += key == ""? pres : " + " + pres;
		}
	}
	
	var pressing = key != "";
	if(key != "") {
		disp_text = key;
		alpha = 2;
	} else
		alpha = lerp_linear(alpha, 0, 0.01);
	
	var win_y = WIN_H;
	
	#region mouse graph
		if(show_graph) {
			win_y -= 128;
			
			draw_set_color(c_black);
			draw_set_alpha(0.5);
			draw_rectangle(0, win_y, WIN_W, WIN_H, false);
			draw_set_alpha(1);
			
			draw_set_color(c_green);
			var mlx = WIN_W - array_length(mouse_left);
			var ox, oy, nx, ny;
			
			for( var i = 0, n = array_length(mouse_left); i < n; i++ ) {
				nx = mlx + i;
				ny = WIN_H - 4 - mouse_left[i] * 24;
				
				if(i) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
			
			draw_set_color(c_red);
			var mlx = WIN_W - array_length(mouse_right);
			var ox, oy, nx, ny;
			
			for( var i = 0, n = array_length(mouse_right); i < n; i++ ) {
				nx = mlx + i;
				ny = WIN_H - 64 - 4 - mouse_right[i] * 24;
				
				if(i) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
			
			// draw_set_color(PEN_USE? c_yellow : c_white);
			// draw_set_alpha(0.75);
			// BLEND_ADD
			// for( var i = 1, n = array_length(mouse_pos); i < n; i++ )
			// 	draw_line(mouse_pos[i - 1][0], mouse_pos[i - 1][1], mouse_pos[i][0], mouse_pos[i][1]);
			// BLEND_NORMAL
			// draw_set_alpha(1);
			
			var mp = 0;
			if(DOUBLE_CLICK)				 mp = 2;
			else if(mouse_lpress(mb_left))	 mp = 1.3;
			else if(mouse_lrelease(mb_left)) mp = 1.3;
			else if(mouse_lclick(mb_left))	 mp = 1;
		
			array_push(mouse_left, mp);
			if(array_length(mouse_left) > WIN_W)
				array_delete(mouse_left, 0, 1);
		
			var mp = 0;
			     if(mouse_rpress(mb_right))	  mp = 1.3;
			else if(mouse_rrelease(mb_right)) mp = 1.3;
			else if(mouse_rclick(mb_right))	  mp = 1;
		
			array_push(mouse_right, mp);
			if(array_length(mouse_right) > WIN_W)
				array_delete(mouse_right, 0, 1);
			
			array_push(mouse_pos, [ mouse_mx, mouse_my ])
			if(array_length(mouse_pos) > 1000)
				array_delete(mouse_pos, 0, 1);
		}
	#endregion
	
	#region mouse
		var mxs = WIN_W - ui(16);
		var mys = win_y - ui(16);
		
		if(show_doubleclick) {
			var dcw  = 72;
			var dch  = 8;
			var dcx  = mxs - 72;
			var dcy  = mys - 96 - 8 - dch;
			var _dcw = dcw * clamp(o_main.dc_check / PREFERENCES.double_click_delay, 0., 1.);
		
			draw_sprite_stretched_ext(THEME.s_box_r2, 0, dcx, dcy,  dcw, dch, COLORS._main_icon_dark,  0.5);
			draw_sprite_stretched_ext(THEME.s_box_r2, 0, dcx, dcy, _dcw, dch, COLORS._main_icon_light, 1.0);
		}
		
		var cc = PEN_USE? COLORS._main_accent : c_white;
		
			 if(DOUBLE_CLICK)       	draw_sprite_ext(s_key_display_mouse, 1, mxs, mys, 1, 1, 0, COLORS._main_value_positive, 1);
		else if(mouse_click(mb_left))	draw_sprite_ext(s_key_display_mouse, 1, mxs, mys, 1, 1, 0, COLORS._main_icon_light, 1);
		
		if(mouse_click(mb_right))		draw_sprite_ext(s_key_display_mouse, 2, mxs, mys, 1, 1, 0, COLORS._main_icon_light, 1);
		if(mouse_click(mb_middle))		draw_sprite_ext(s_key_display_mouse, 3, mxs, mys, 1, 1, 0, COLORS._main_icon_light, 1);
			
		if(mouse_wheel_up())			draw_sprite_ext(s_key_display_mouse, 3, mxs, mys, 1, 1, 0, COLORS._main_accent, 1);
		if(mouse_wheel_down())			draw_sprite_ext(s_key_display_mouse, 3, mxs, mys, 1, 1, 0, COLORS._main_accent, 1);
		
		draw_sprite_ext_add(s_key_display_mouse, 0, mxs, mys, 1, 1, 0, cc, 0.5);
	#endregion
	
	if(alpha > 0) {
		draw_set_text(_f_h5, fa_right, fa_bottom, COLORS._main_icon_dark);
		var pd = ui(4);
		var ww = string_width(disp_text)  + pd * 3;
		var hh = string_height(disp_text) + pd * 2;
		
		var x1 = WIN_W - ui(32 + sprite_get_width(s_key_display_mouse));
		var y1 = win_y - ui(8);
		var x0 = x1 - ww;
		var y0 = y1 - hh;
		
		draw_sprite_stretched_ext(THEME.key_display, 0, x0, y0, ww, hh, pressing? COLORS._main_accent : COLORS._main_icon, alpha);
		draw_set_alpha(alpha);
		draw_text(x1 - pd * 1.5, y1 - pd, disp_text);
		draw_set_alpha(1);
	}
#endregion