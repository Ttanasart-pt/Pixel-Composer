globalvar ZOOM_AREA; ZOOM_AREA         = 0;
globalvar ZOOM_AREA_RANGE; ZOOM_AREA_RANGE   = 64;
globalvar ZOOM_AREA_RANGE_C; ZOOM_AREA_RANGE_C = 64;
globalvar ZOOM_AREA_REGION; ZOOM_AREA_REGION  = [0,0,WIN_W,WIN_H];
globalvar ZOOM_AREA_ZOOM; ZOOM_AREA_ZOOM    = 2;
globalvar ZOOM_AREA_ZOOM_LV; ZOOM_AREA_ZOOM_LV = 2;
globalvar ZOOM_AREA_SURFACE; ZOOM_AREA_SURFACE = undefined;
globalvar ZOOM_PROGRESS; ZOOM_PROGRESS     = 0;

globalvar ZOOM_AREA_MX; ZOOM_AREA_MX = 0;
globalvar ZOOM_AREA_MY; ZOOM_AREA_MY = 0;

function zoom_area_draw() {
	var _zoomMouse = key_press(ord("Z"), MOD_KEY.alt, true) || gamepad_button_check(0, gp_face1);
	
	if(_zoomMouse) {
		ZOOM_AREA = 2;
		ZOOM_AREA_RANGE_C = lerp_float(ZOOM_AREA_RANGE_C, ZOOM_AREA_RANGE, 4);
		ZOOM_AREA_REGION  = [ clamp(mouse_mx - ZOOM_AREA_RANGE_C, 0, WIN_W), clamp(mouse_my - ZOOM_AREA_RANGE_C, 0, WIN_H),
		                      clamp(mouse_mx + ZOOM_AREA_RANGE_C, 0, WIN_W), clamp(mouse_my + ZOOM_AREA_RANGE_C, 0, WIN_H) ];
		                     
		// ZOOM_AREA_ZOOM_LV = clamp(ZOOM_AREA_ZOOM_LV + MOUSE_WHEEL, 2, 16);
		ZOOM_AREA_RANGE   = clamp(ZOOM_AREA_RANGE   + MOUSE_WHEEL * 16, 16, 256);
		
	} else {
		if(ZOOM_AREA == 2) ZOOM_AREA = 0;
	}
	
	var _zoomStart = key_press(ord("Z"), MOD_KEY.shift | MOD_KEY.alt, false) || gamepad_button_check_pressed(0, gp_face2);
	var _zoomHold  = key_press(ord("Z"), MOD_KEY.shift | MOD_KEY.alt, true)  || gamepad_button_check(0, gp_face2);
	
	if(_zoomStart) ZOOM_AREA = 0;
	if(_zoomHold) {
		if(mouse_lpress(true, true)) {
			ZOOM_AREA_MX = mouse_mx;
			ZOOM_AREA_MY = mouse_my;
		}
		
		var _x0 = min(ZOOM_AREA_MX, mouse_mx);
		var _x1 = max(ZOOM_AREA_MX, mouse_mx);
		var _y0 = min(ZOOM_AREA_MY, mouse_my);
		var _y1 = max(ZOOM_AREA_MY, mouse_my);
		
		var _ww = _x1 - _x0;
		var _hh = _y1 - _y0;
		
		if(mouse_lrelease(true, true)) {
			if(_ww > 5 && _hh > 5) {
				ZOOM_AREA         = 1;
				ZOOM_AREA_REGION  = [_x0,_y0,_x1,_y1];
				
			} else {
				ZOOM_AREA = 0;
			}
		}
		
		if(mouse_lclick(true, true)) 
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _x0, _y0, _ww, _hh, COLORS._main_accent);
	}
}

function zoom_area_draw_gui() {
	if(!surface_exists(PRE_APP_SURF)) return;
	if(ZOOM_AREA) {
		ZOOM_PROGRESS  = lerp_float(ZOOM_PROGRESS, 1, 3);
		ZOOM_AREA_ZOOM = lerp_float(ZOOM_AREA_ZOOM, ZOOM_AREA_ZOOM_LV, 3);
		
	} else {
		ZOOM_PROGRESS  = lerp_float(ZOOM_PROGRESS,  0, 3);
		ZOOM_AREA_ZOOM = lerp_float(ZOOM_AREA_ZOOM, 1, 3);
		if(ZOOM_PROGRESS == 0) return;
	}
	
	var _pp = (ZOOM_AREA_ZOOM - 1) / (ZOOM_AREA_ZOOM_LV - 1);
	
	var _px = ZOOM_AREA_REGION[0];
	var _py = ZOOM_AREA_REGION[1];
	var _pw = ZOOM_AREA_REGION[2] - ZOOM_AREA_REGION[0];
	var _ph = ZOOM_AREA_REGION[3] - ZOOM_AREA_REGION[1];
	
	var _cx = (ZOOM_AREA_REGION[0] + ZOOM_AREA_REGION[2]) / 2;
	var _cy = (ZOOM_AREA_REGION[1] + ZOOM_AREA_REGION[3]) / 2;
	
	var _ww = _pw * ZOOM_AREA_ZOOM;
	var _hh = _ph * ZOOM_AREA_ZOOM;
	
	var _x0 = clamp(_cx - _ww / 2, ui(8), WIN_W - ui(8) - _ww);
	var _y0 = clamp(_cy - _hh / 2, ui(8), WIN_H - ui(8) - _hh);
	
	ZOOM_AREA_SURFACE = surface_verify(ZOOM_AREA_SURFACE, _ww, _hh);
	
	draw_set_color_alpha(c_black, ZOOM_PROGRESS * .3);
	draw_rectangle(0, 0, WIN_W, WIN_H, false);
	draw_set_alpha(1);
	
	surface_set_target(PRE_APP_SURF);
		draw_sprite(THEME.cursor_video, 0, mouse_mx, mouse_my);
	surface_reset_target();
	
	surface_set_target(ZOOM_AREA_SURFACE);
		draw_clear(COLORS.bg);
		
		gpu_set_texfilter(true);
		draw_surface_ext(PRE_APP_SURF, -_px * ZOOM_AREA_ZOOM, -_py * ZOOM_AREA_ZOOM, ZOOM_AREA_ZOOM, ZOOM_AREA_ZOOM, 0, c_white, 1);
		gpu_set_texfilter(false);
		
		BLEND_MULTIPLY
			draw_sprite_stretched(THEME.ui_panel, 0, 0, 0, _ww, _hh);
		BLEND_NORMAL
	surface_reset_target();
	
	draw_sprite_stretched_ext(THEME.node_junction_name_bg, 0, _x0 - 16, _y0 - 16, _ww + 32, _hh + 32, c_black, _pp * .3);
	draw_surface(ZOOM_AREA_SURFACE, _x0, _y0);
	draw_sprite_stretched_add(THEME.ui_panel, 1, _x0, _y0, _ww, _hh, COLORS._main_icon, _pp * .5);
}