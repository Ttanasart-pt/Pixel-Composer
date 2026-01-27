#region global
	globalvar VIDEO_PEN_SURFACE; VIDEO_PEN_SURFACE = undefined;
	globalvar VIDEO_PEN_SCALE; VIDEO_PEN_SCALE   = 2;
	
	globalvar VIDEO_PEN; VIDEO_PEN   = false;
	globalvar VIDEO_PEN_X; VIDEO_PEN_X = undefined;
	globalvar VIDEO_PEN_Y; VIDEO_PEN_Y = undefined;
	globalvar VIDEO_RIGHT_CLICK; VIDEO_RIGHT_CLICK = false;
#endregion

function video_pen_overlay() {
	var pw = WIN_W / VIDEO_PEN_SCALE;
	var ph = WIN_H / VIDEO_PEN_SCALE;
	VIDEO_PEN_SURFACE = surface_verify(VIDEO_PEN_SURFACE, pw, ph);
	
	if(VIDEO_PEN) {
		var px = PEN_X / VIDEO_PEN_SCALE;
		var py = PEN_Y / VIDEO_PEN_SCALE;
		var pp = PEN_PRESSURE / 1024;
		var penSize = 1;
		
		draw_set_circle_precision(32);
		surface_set_target(VIDEO_PEN_SURFACE);
			draw_set_color(COLORS._main_accent);
			
			if(VIDEO_PEN_X != undefined)
				draw_line_width(VIDEO_PEN_X, VIDEO_PEN_Y, px, py, penSize * 2);
			draw_circle(px, py, penSize, false);
		surface_reset_target();
		
		VIDEO_PEN_X = px;
		VIDEO_PEN_Y = py;
		
	} else {
		VIDEO_PEN_X = undefined;
		VIDEO_PEN_Y = undefined;
	}
	
	if(VIDEO_RIGHT_CLICK) {
		surface_set_target(VIDEO_PEN_SURFACE);
			DRAW_CLEAR
		surface_reset_target();
	}
	
	draw_surface_ext(VIDEO_PEN_SURFACE, 0, 0, VIDEO_PEN_SCALE, VIDEO_PEN_SCALE, 0, c_white, 1);
}