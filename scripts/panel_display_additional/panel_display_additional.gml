globalvar FOCUSING_PANEL; FOCUSING_PANEL   = noone;
globalvar FOCUSING_AREA; FOCUSING_AREA    = noone;

globalvar FOCUSING_PROG; FOCUSING_PROG    = noone;
globalvar FOCUSING_SURFACE; FOCUSING_SURFACE = noone;

globalvar FOCUSING_DRAW; FOCUSING_DRAW    = undefined;
globalvar FOCUSING_TARG; FOCUSING_TARG    = undefined;

function PANEL_DRAW_EXTRA() {
	if(FOCUSING_DRAW == undefined) FOCUSING_DRAW = [ 0, 0, WIN_W, WIN_H ];
	if(FOCUSING_TARG == undefined) FOCUSING_TARG = [ 0, 0, WIN_W, WIN_H ];

	if(FOCUSING_PANEL != noone && is(FOCUSING_PANEL, PanelContent)) {
		var _p = FOCUSING_PANEL;
		FOCUSING_AREA = [ _p.x, _p.y, _p.w, _p.h ];
	}
	
	if(FOCUSING_AREA != noone) {
		FOCUSING_TARG = [ FOCUSING_AREA[0], FOCUSING_AREA[1], FOCUSING_AREA[2], FOCUSING_AREA[3] ];
		FOCUSING_PROG = lerp_linear(FOCUSING_PROG, 1, DELTA_TIME * 3);
    		
	} else {
		FOCUSING_PROG = lerp_linear(FOCUSING_PROG, 0, DELTA_TIME * 3);
	}
	
	var pr = animation_curve_eval(ac_smoothstep, FOCUSING_PROG);
	FOCUSING_DRAW[0] = lerp(0,     FOCUSING_TARG[0], pr);
	FOCUSING_DRAW[1] = lerp(0,     FOCUSING_TARG[1], pr);
	FOCUSING_DRAW[2] = lerp(WIN_W, FOCUSING_TARG[2], pr);
	FOCUSING_DRAW[3] = lerp(WIN_H, FOCUSING_TARG[3], pr);
	
	if(pr > 0) {
		var x0 = FOCUSING_DRAW[0]
		var y0 = FOCUSING_DRAW[1]
		var ww = FOCUSING_DRAW[2]
		var hh = FOCUSING_DRAW[3]
		var x1 = x0 + ww;
		var y1 = y0 + hh;
		
		FOCUSING_SURFACE = surface_verify(FOCUSING_SURFACE, WIN_W, WIN_H);
		
		surface_set_target(FOCUSING_SURFACE);
			draw_clear_alpha(c_black, pr * .6);
			BLEND_SUBTRACT
				draw_sprite_stretched(THEME.ui_panel_bg, 1, x0, y0, ww, hh);
			BLEND_NORMAL
		surface_reset_target();
		
		draw_surface_safe(FOCUSING_SURFACE);
		draw_sprite_stretched_ext(THEME.ui_panel, 2, x0, y0, ww, hh, COLORS._main_accent, 1);
	}
	
	FOCUSING_PANEL = noone;
	FOCUSING_AREA  = noone;
}