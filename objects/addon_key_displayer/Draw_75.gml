/// @description 
#region key detection
	var key = "";
	
	if(keyboard_check(vk_control)) key += key == ""? "Ctrl"  : " + " + "Ctrl";
	if(keyboard_check(vk_shift))   key += key == ""? "Shift" : " + " + "Shift";
	if(keyboard_check(vk_alt))     key += key == ""? "Alt"   : " + " + "Alt";
	
	for( var i = 0, n = array_length(KEY_STRING_KEY); i < n; i++ ) {
		var _k = KEY_STRING_KEY[i];
		var _s = KEY_STRING_MAP[$ _k];
		
		if(keyboard_check(_k)) key += key == ""? _s : " + " + _s;
	}
	
	var pressing = key != "";
	if(key != "") {
		if(keyboard_check_pressed(vk_anykey) && key != "") array_push(disp_keys, key);
		disp_key = key;
		alpha = 2;
		
	} else
		alpha = lerp_linear(alpha, 0, 0.01);
#endregion

#region draw 
	var win_x = WIN_W;
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
			else if(mouse_lrelease()) mp = 1.3;
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
		var mxs = win_x - ui(16);
		var mys = win_y - ui(16);
		
		if(show_doubleclick) {
			var dcw  = 72;
			var dch  = 8;
			var dcx  = mxs - 72;
			var dcy  = mys - 96 - 8 - dch;
			var _dcw = dcw * clamp(o_main.dc_check / PREFERENCES.double_click_delay, 0., 1.);
		
			draw_sprite_stretched_ext(THEME.box_r2, 0, dcx, dcy,  dcw, dch, COLORS._main_icon_dark,  0.5);
			draw_sprite_stretched_ext(THEME.box_r2, 0, dcx, dcy, _dcw, dch, COLORS._main_icon_light, 1.0);
		}
		
		var cc = PEN_USE? COLORS._main_accent : c_white;
		
			 if(DOUBLE_CLICK)       	draw_sprite_ext(s_key_display_mouse, 1, mxs, mys, 1, 1, 0, COLORS._main_value_positive, 1);
		else if(mouse_click(mb_left))	draw_sprite_ext(s_key_display_mouse, 1, mxs, mys, 1, 1, 0, COLORS._main_icon_light, 1);
		
		if(mouse_click(mb_right))		draw_sprite_ext(s_key_display_mouse, 2, mxs, mys, 1, 1, 0, COLORS._main_icon_light, 1);
		if(mouse_click(mb_middle))		draw_sprite_ext(s_key_display_mouse, 3, mxs, mys, 1, 1, 0, COLORS._main_icon_light, 1);
			
		if(MOUSE_WHEEL > 0)             draw_sprite_ext(s_key_display_mouse, 3, mxs, mys, 1, 1, 0, COLORS._main_accent, 1);
		if(MOUSE_WHEEL < 0)             draw_sprite_ext(s_key_display_mouse, 3, mxs, mys, 1, 1, 0, COLORS._main_accent, 1);
		
		draw_sprite_ext_add(s_key_display_mouse, 0, mxs, mys, 1, 1, 0, cc, 0.5);
	#endregion
	
	draw_set_text(_f_sdf, fa_right, fa_bottom, COLORS._main_icon_dark);
	var ts = .75;
	var pd = ui(4);
	var ww = ts * string_width(disp_key)  + pd * 3;
	var hh = ts * string_height(disp_key) + pd * 2;
	
	var x1 = win_x - ui(32) - sprite_get_width(s_key_display_mouse);
	var y1 = win_y - ui(8);
	var x0 = x1 - ww;
	var y0 = y1 - hh;
	
	if(alpha > 0) {
		draw_sprite_stretched_ext(THEME.key_display, 0, x0, y0, ww, hh, pressing? COLORS._main_accent : COLORS._main_icon, alpha);
		draw_set_alpha(alpha);
		draw_text_transformed(x1 - pd * 1.5, y1 - pd, disp_key, ts, ts, 0);
		draw_set_alpha(1);
	}
		
	draw_set_text(_f_sdf_medium, fa_right, fa_bottom, COLORS._main_text_sub);
	var tx = x1;
	var ty = y1 - pd - hh;
	var ts = .9;
	var a  = 0;
	
	for( var i = array_length(disp_keys) - 1; i >= 0; i-- ) {
		if(a++ >= 5) break;
		
		draw_set_alpha(lerp(.3, 1, (5-a)/5));
		draw_text_transformed(tx, ty, disp_keys[i], ts, ts, 0);
		ty -= line_get_height() * ts;
	}
	
	draw_set_alpha(1);
#endregion