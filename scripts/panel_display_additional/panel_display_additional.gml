globalvar FOCUSING_PANEL, FOCUSING_AREA;

function panelDisplayInit() {
	FOCUSING_PANEL = noone;
	FOCUSING_AREA  = noone;
	
	focusing_prog  = 0;
	focusing_draw  = [ 0, 0, WIN_W, WIN_H ];
	focusing_targ  = [ 0, 0, WIN_W, WIN_H ];
	focusing_surface = noone;
}

function panelDisplayDraw() {
	if(FOCUSING_PANEL != noone && is(FOCUSING_PANEL, PanelContent)) {
		var _p = FOCUSING_PANEL;
		FOCUSING_AREA = [ _p.x, _p.y, _p.w, _p.h ];
	}
	
	if(FOCUSING_AREA != noone) {
		focusing_prog = lerp_float(focusing_prog, 1, 6);
		focusing_targ = [ FOCUSING_AREA[0], FOCUSING_AREA[1], FOCUSING_AREA[2], FOCUSING_AREA[3] ];
	} else {
		focusing_prog = lerp_float(focusing_prog, 0, 6);
	}
	
	focusing_draw[0] = lerp(0,     focusing_targ[0], focusing_prog);
	focusing_draw[1] = lerp(0,     focusing_targ[1], focusing_prog);
	focusing_draw[2] = lerp(WIN_W, focusing_targ[2], focusing_prog);
	focusing_draw[3] = lerp(WIN_H, focusing_targ[3], focusing_prog);
	
	if(focusing_prog > 0) {
		var x0 = focusing_draw[0]
		var y0 = focusing_draw[1]
		var ww = focusing_draw[2]
		var hh = focusing_draw[3]
		var x1 = x0 + ww;
		var y1 = y0 + hh;
		
		focusing_surface = surface_verify(focusing_surface, WIN_W, WIN_H);
		
		surface_set_target(focusing_surface);
			draw_clear_alpha(c_black, focusing_prog * 0.6);
			BLEND_SUBTRACT
				draw_sprite_stretched(THEME.ui_panel_bg, 1, x0, y0, ww, hh);
			BLEND_NORMAL
		surface_reset_target();
		
		draw_surface_safe(focusing_surface);
		draw_sprite_stretched_ext(THEME.ui_panel, 2, x0, y0, ww, hh, COLORS._main_accent, 1);
	}
	
	FOCUSING_PANEL = noone;
	FOCUSING_AREA  = noone;
}