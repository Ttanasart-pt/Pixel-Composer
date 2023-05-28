function draw_tooltip_text(txt) {
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	
	var tw = min(WIN_W - ui(32), string_width(txt));
	var th = string_height_ext(txt, -1, tw);
		
	var mx = min(mouse_mx + ui(16), WIN_W - (tw + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (th + ui(16)));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
	draw_text_ext(mx + ui(8), my + ui(8), txt, -1, tw);
}

function draw_tooltip_color(clr) {
	if(is_array(clr)) {
		draw_tooltip_palette(clr);
		return;
	}
	
	var ww = ui(32);
	var hh = ui(32);
		
	var mx = min(mouse_mx + ui(16), WIN_W - (ww + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (hh + ui(16)));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + ui(16), hh + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + ui(16), hh + ui(16));
	
	draw_set_color(clr);
	draw_rectangle(mx + ui(8), my + ui(8), mx + ui(ww + 8), my + ui(hh + 8), false);
}

function draw_tooltip_palette(clr) {
	var ww = min(ui(160), ui(32) * array_length(clr));
	var hh = ui(32);
		
	var mx = min(mouse_mx + ui(16), WIN_W - (ww + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (hh + ui(16)));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + ui(16), hh + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + ui(16), hh + ui(16));
	
	drawPalette(clr, mx + ui(8), my + ui(8), ui(ww), ui(hh));
}

function draw_tooltip_gradient(clr) {
	var ww = ui(160);
	var hh = ui(32);
		
	var mx = min(mouse_mx + ui(16), WIN_W - (ww + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (hh + ui(16)));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + ui(16), hh + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + ui(16), hh + ui(16));
	
	clr.draw(mx + ui(8), my + ui(8), ui(ww), ui(hh));
}

function draw_tooltip_surface_array(surf) {
	var amo = array_length(surf);
	var col = ceil(sqrt(amo));
	var row = ceil(amo / col);
	
	var nn = min(ui(64), ui(320) / col);
	var sw = nn;
	var sh = nn;
	
	var ww = sw * col;
	var hh = sh * row;
	
	var mx = min(mouse_mx + ui(16), WIN_W - (ww + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (hh + ui(16)));
	
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + ui(16), hh + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + ui(16), hh + ui(16));
	
	for( var ind = 0; ind < amo; ind++ ) {
		if(!is_surface(surf[ind])) continue;
		
		var i = floor(ind / col);
		var j = safe_mod(ind, col);
		
		var sw = surface_get_width(surf[ind]);
		var sh = surface_get_height(surf[ind]);
		var ss = nn / max(sw, sh);
		var cx = mx + ui(8) + j * nn + nn / 2;
		var cy = my + ui(8) + i * nn + nn / 2;
		
		draw_surface_ext_safe(surf[ind], cx - sw * ss / 2, cy - sh * ss / 2, ss, ss, 0, c_white, 1);
		draw_set_color(COLORS._main_icon);
		draw_rectangle(cx - sw * ss / 2, cy - sh * ss / 2, cx + sw * ss / 2 - 1, cy + sh * ss / 2 - 1, true);
	}
}

function draw_tooltip_surface(surf) {
	if(is_array(surf)) {
		draw_tooltip_surface_array(array_spread(surf))
		return;
	}
	if(!is_surface(surf)) return;
	
	var sw = surface_get_width(surf);
	var sh = surface_get_height(surf);
	
	var ss = min(ui(128) / sw, ui(128) / sh);
	
	var ww = sw * ss;
	var hh = sh * ss;
	
	var mx = min(mouse_mx + ui(16), WIN_W - (ww + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (hh + ui(16)));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + ui(16), hh + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + ui(16), hh + ui(16));
	
	draw_surface_ext_safe(surf, mx + ui(8), my + ui(8), ss, ss);
}

function draw_tooltip_atlas(atlas) {
	if(!is_array(atlas)) atlas = [ atlas ];
	
	var amo = array_length(atlas);
	var ww  = ui(160);
	var hh  = amo * ui(48 + 8) - ui(8);
	
	var mx = min(mouse_mx + ui(16), WIN_W - (ww + ui(16)));
	var my = min(mouse_my + ui(16), WIN_H - (hh + ui(16)));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + ui(16), hh + ui(16));
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + ui(16), hh + ui(16));
	
	var sx = mx + ui(8);
	var sy = my + ui(8);
	
	for( var i = 0; i < amo; i++ ) {
		var _y = sy + i * ui(48 + 8);
		
		var atl = atlas[i];
		var surf = atl.surface.get();
		
		if(!is_surface(surf)) continue;
		
		var sw = surface_get_width(surf);
		var sh = surface_get_height(surf);
	
		var ss = min(ui(48) / sw, ui(48) / sh);
		draw_surface_ext_safe(surf, sx, _y, ss, ss);
		
		draw_set_color(COLORS._main_icon);
		draw_rectangle(sx, _y, sx + ui(48), _y + ui(48), 1);
		
		draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(sx + ui( 56), _y + ui( 0), "Position");
		draw_text_add(sx + ui( 56), _y + ui(16), "Rotation");
		draw_text_add(sx + ui( 56), _y + ui(32), "Scale");
		
		draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text);
		draw_text_add(sx + ui(160), _y + ui( 0), atl.position);
		draw_text_add(sx + ui(160), _y + ui(16), atl.rotation);
		draw_text_add(sx + ui(160), _y + ui(32), atl.scale);
	}
}