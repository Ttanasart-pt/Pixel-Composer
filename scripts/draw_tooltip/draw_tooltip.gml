function draw_tooltip_text(txt) {
	txt = array_to_string(txt);
	
	if(string_length(txt) > 1024)
		txt = string_copy(txt, 1, 1024) + "...";
	
	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	
	var tw = min(max(320, WIN_W * 0.4), string_width(txt));
	var th = string_height_ext(txt, -1, tw);
		
	var pd = ui(8);
	var mx = min(mouse_mxs + ui(16), WIN_W - (tw + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (th + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + pd * 2, th + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + pd * 2, th + pd * 2);
	draw_text_line(mx + pd, my + pd, txt, -1, tw);
}

function draw_tooltip_color(clr) {
	if(is_array(clr)) {
		draw_tooltip_palette(clr);
		return;
	}
	
	var ww = ui(32);
	var hh = ui(32);
		
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	draw_sprite_stretched_ext(THEME.box_r2, 0, mx + pd, my + pd, ww, hh, clr, 1);
	draw_sprite_stretched_add(THEME.box_r2, 1, mx + pd, my + pd, ww, hh, c_white, 0.3);
}

function draw_tooltip_palette(clr) {
	if(array_empty(clr)) return;
	
	var ph = ui(32);
	if(!is_array(clr[0])) clr = [ clr ];
	
	var pal_len = 0;
	for( var i = 0, n = array_length(clr); i < n; i++ ) 
		pal_len = max(pal_len, array_length(clr[i]));
	
	var ww = min(ui(160), ui(32) * pal_len);
	var hh = array_length(clr) * ph;
	
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	var _y = my + pd;
	for( var i = 0, n = array_length(clr); i < n; i++ ) {
		drawPalette(clr[i], mx + pd, _y, ww, ph);
		_y += ph;
	}
	
	draw_sprite_stretched_add(THEME.box_r2, 1, mx + pd, my + pd, ww, hh, c_white, 0.3);
}

function draw_tooltip_gradient(clr) {
	var gh = ui(32);
	if(!is_array(clr)) clr = [ clr ];
	
	var ww = ui(160);
	var hh = array_length(clr) * gh;
		
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	var _y = my + pd;
	for( var i = 0, n = array_length(clr); i < n; i++ ) {
		clr[i].draw(mx + pd, _y, ui(ww), gh);
		_y += gh;
	}
}

function draw_tooltip_surface_array(surf) {
	if(!is_array(surf) || array_empty(surf)) return;
	
	if(is_instanceof(surf[0], SurfaceAtlas)) {
		draw_tooltip_atlas(surf);
		return;
	}
	
	var amo = array_length(surf);
	var col = ceil(sqrt(amo));
	var row = ceil(amo / col);
	
	var nn = min(ui(64), ui(320) / col);
	var sw = nn;
	var sh = nn;
	
	var ww = sw * col;
	var hh = sh * row;
	
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
	
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	for( var ind = 0; ind < amo; ind++ ) {
		if(!is_surface(surf[ind])) continue;
		
		var i = floor(ind / col);
		var j = safe_mod(ind, col);
		
		var sw = surface_get_width_safe(surf[ind]);
		var sh = surface_get_height_safe(surf[ind]);
		var ss = nn / max(sw, sh);
		var cx = mx + pd + j * nn + nn / 2;
		var cy = my + pd + i * nn + nn / 2;
		
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
	
	if(is(surf, SurfaceAtlas)) {
		draw_tooltip_atlas(surf);
		return;
	}
	
	if(!is_surface(surf)) return;
	
	var sw = surface_get_width_safe(surf);
	var sh = surface_get_height_safe(surf);
	
	var ss = min(ui(128) / sw, ui(128) / sh);
	
	var ww = sw * ss;
	var hh = sh * ss;
	
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	draw_surface_ext_safe(surf, mx + pd, my + pd, ss, ss);
}

function draw_tooltip_sprite(spr) {
	if(!sprite_exists(spr)) return;
	
	var ox = sprite_get_xoffset(spr);
	var oy = sprite_get_yoffset(spr);
	
	var sw = sprite_get_width(spr);
	var sh = sprite_get_height(spr);
	var sn = sprite_get_number(spr);
	
	var ss = min(max(1, min(ui(64) / sw, ui(64) / sh)), ui(320) / sw, ui(320) / sh);
	
	var ww = sw * ss * sn + 2 * (sn - 1);
	var hh = sh * ss + ui(16);
	
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	var sx = mx + pd + ox * ss;
	var sy = my + pd + oy * ss;
	
	for( var i = 0; i < sn; i++ )
		draw_sprite_ext(spr, i, sx + i * (sw * ss + 2), sy, ss, ss, 0, c_white, 1);
	
	draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_text_sub);
	draw_text(mx + (ww + pd * 2) / 2, my + hh + pd * 2 - ui(4), $"{sw} x {sh} px");
}

function draw_tooltip_atlas(atlas) {
	if(!is_array(atlas)) atlas = [ atlas ];
	
	var amo = array_length(atlas);
	var ww  = ui(160);
	var hh  = amo * ui(48 + 8) - ui(8);
	
	if(amo && is_array(atlas[0])) return;
	
	var pd = ui(4);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	var sx = mx + pd;
	var sy = my + pd;
	
	for( var i = 0; i < amo; i++ ) {
		var _y = sy + i * ui(48 + 8);
		
		var atl  = atlas[i];
		if(!is_instanceof(atl, SurfaceAtlas)) continue;
		
		var surf = atl.getSurface();
		if(!is_surface(surf)) continue;
		
		var sw = surface_get_width_safe(surf);
		var sh = surface_get_height_safe(surf);
		
		var ss = min(ui(48) / sw, ui(48) / sh);
		draw_surface_ext_safe(surf, sx, _y, ss, ss);
		
		draw_set_color(COLORS._main_icon);
		draw_rectangle(sx, _y, sx + ui(48), _y + ui(48), 1);
		
		draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(sx + ui( 56), _y + ui( 0), __txt("Position"));
		draw_text_add(sx + ui( 56), _y + ui(16), __txt("Rotation"));
		draw_text_add(sx + ui( 56), _y + ui(32), __txt("Scale"));
		
		draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text);
		draw_text_add(sx + ui(160), _y + ui( 0), $"{atl.x}, {atl.y}");
		draw_text_add(sx + ui(160), _y + ui(16), atl.rotation);
		draw_text_add(sx + ui(160), _y + ui(32), $"{atl.sx}, {atl.sy}");
	}
}

function draw_tooltip_buffer(buff) {
	var txt = buffer_get_string(buff, false, 400);
	var len = string_length(txt);
	
	if(len > 400) txt = string_copy(txt, 1, 400);
	
	draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
	
	var tw = min(string_width(" ") * 40, string_width(txt));
	var th = string_height_ext(txt, -1, tw);
	if(len > 400)
		th += string_height(" ");
		
	var pd = ui(8);
	var mx = min(mouse_mxs + ui(16), WIN_W - (tw + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (th + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + pd * 2, th + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + pd * 2, th + pd * 2);
	draw_text_line(mx + pd, my + pd, txt, -1, tw);
	
	if(len > 400) {
		draw_set_text(f_code, fa_left, fa_bottom, COLORS._main_text_sub);
		draw_text(mx + pd, my + th + pd, $"...({buffer_get_size(buff)} bytes)");
	}
}

function draw_tooltip_curve(curve) {
	
	var ww = ui(160);
	var hh = ui(160);
		
	var pd = ui(8);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	var x0 = mx + pd;
	var x1 = x0 + ww;
	var y0 = my + pd;
	var y1 = y0 + hh;
	var st = 0.1;
		
	draw_set_color(COLORS.widget_curve_line);
	draw_set_alpha(0.15);
	
	for( var i = st; i < 1; i += st ) {
		var _y0 = y0 + hh * (1 - i);
		draw_line(x0, _y0, x1, _y0);
		
		var _x0 = x0 + ww * i;
		draw_line(_x0, y0, _x0, y1);
	}
	
	draw_set_alpha(1);
	
	draw_set_color(COLORS._main_accent);
	draw_curve(x0, y0, ww, hh, curve);
	
	draw_set_color(COLORS.widget_curve_outline);
	draw_rectangle(x0, y0, x1, y1, true);
	
}

function draw_tooltip_path(_path) {
	if(!is_struct(_path)) return;
	
	var ww = ui(160);
	var hh = ui(160);
		
	var pd = ui(8);
	var mx = min(mouse_mxs + ui(16), WIN_W - (ww + pd * 2));
	var my = min(mouse_mys + ui(16), WIN_H - (hh + pd * 2));
		
	draw_sprite_stretched(THEME.textbox, 3, mx, my, ww + pd * 2, hh + pd * 2);
	draw_sprite_stretched(THEME.textbox, 0, mx, my, ww + pd * 2, hh + pd * 2);
	
	var x0 = mx + pd, x1 = x0 + ww;
	var y0 = my + pd, y1 = y0 + hh;
	var st = 0.1;
		
	draw_set_color(COLORS.widget_curve_line);
	draw_set_alpha(0.15);
	
	for( var i = st; i < 1; i += st ) {
		var _y0 = y0 + hh * (1 - i);
		var _x0 = x0 + ww * i;
		
		draw_line(x0, _y0, x1, _y0);
		draw_line(_x0, y0, _x0, y1);
	}
	
	draw_set_alpha(1);
	
	draw_set_color(COLORS._main_accent);
	var _bbox = _path.getBoundary();
	if(!is_struct(_bbox)) return;
	
	var _x0 = _bbox.minx, _x1 = _bbox.maxx, _cx = (_x0 + _x1) / 2;
	var _y0 = _bbox.miny, _y1 = _bbox.maxy, _cy = (_y0 + _y1) / 2;
	var _ss = max(_bbox.width, _bbox.height);
	_x0 = _cx - _ss / 2; _x1 = _cx + _ss / 2;
	_y0 = _cy - _ss / 2; _y1 = _cy + _ss / 2;
	
	var _step = 32;
	var ox, oy, nx, ny;
	var p = new __vec2();
	
	for( var i = 0; i < _step; i++ ) {
		p = _path.getPointRatio(i / _step);
		nx = lerp(x0, x1, (p.x - _x0) / _ss);
		ny = lerp(y0, y1, (p.y - _y0) / _ss);
		
		if(i) draw_line(ox, oy, nx, ny);
		
		ox = nx;
		oy = ny;
	}
	
	draw_set_color(COLORS.widget_curve_outline);
	draw_rectangle(x0, y0, x1, y1, true);
	
	draw_set_text(f_p4, fa_left, fa_top);
	draw_text_add(x0 + ui(2), y0, $"({_x0}, {_y0})");
	
	draw_set_text(f_p4, fa_right, fa_bottom);
	draw_text_add(x1 - ui(2), y1, $"({_x1}, {_y1})");
	
}

function tooltip_modifiers(title, keys) constructor {
	self.title = title;
	self.keys  = keys;
	
	static drawTooltip = function() {
		
		draw_set_font(f_p1);
		var w1 = string_width(title);
		var h1 = string_height(title);
		
		draw_set_font(f_p2);
		var w2 = 0;
		var h2 = 0;
		
		for( var i = 0, n = array_length(keys); i < n; i++ ) {
			w2  = max(w2, string_width(keys[i][0]) + string_width(keys[i][1]) + ui(16));
			h2 += line_get_height();
		}
		
		var tw = max(w1, w2);
		var th = h1 + ui(8) + h2;
		
		var mx = min(mouse_mxs + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_mys + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		draw_text(mx + ui(8), my + ui(8), title);
		
		draw_set_font(f_p2);
		
		for( var i = 0, n = array_length(keys); i < n; i++ ) {
			var _hx = mx + ui(12) + string_width(keys[i][0]);
			var _hy = my + ui(8) + h1 + ui(4) + h2 / 2 + ui(4);
			hotkey_draw(keys[i][0], _hx, _hy);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			draw_text(_hx + ui(8), my + ui(8) + h1 + ui(6), keys[i][1]);
		}
	}
}