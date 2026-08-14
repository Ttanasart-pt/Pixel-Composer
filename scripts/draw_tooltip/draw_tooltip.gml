#region global
	globalvar TOOLTIP_SURFACE; TOOLTIP_SURFACE = undefined;
	
	function setTOOLTIP(_t) {
		if(_t == "") return;
		
		TOOLTIP_WINDOW = WINWIN_CURRENT;
		TOOLTIP = _t;
	}
	
	function resetTOOLTIP() {
		TOOLTIP_WINDOW = undefined;
		TOOLTIP = undefined;
	}
	
	function checkTOOLTIP() {
		if(_MOUSE_BLOCK)                     return;
		if(TOOLTIP == undefined)             return;
		if(TOOLTIP_WINDOW != WINWIN_CURRENT) return;
		
		if(is_surface(TOOLTIP_SURFACE)) surface_clear(TOOLTIP_SURFACE);
		
		if(is_struct(TOOLTIP)) {
			if(has(TOOLTIP, "drawTooltip"))
				TOOLTIP.drawTooltip();
				
		} else if(is_string(TOOLTIP)) {
			draw_tooltip_text(TOOLTIP);
			
		} else if(is_array(TOOLTIP)) {
			var raw  = TOOLTIP[0];
			var type = TOOLTIP[1];
			var content = raw;
			
			if(is(raw, valueKey)) {
				content = raw.value;
				
			} else if(is_method(raw)) content = raw();
			
			switch(type) {
				case VALUE_TYPE.float    :
				case VALUE_TYPE.integer  : 
				case VALUE_TYPE.text     :
				case VALUE_TYPE.particle : 
				case VALUE_TYPE.path     : draw_tooltip_text(content);                                                          break;
				
				case VALUE_TYPE.boolean  : draw_tooltip_text(printBool(content));                                               break;
				case VALUE_TYPE.curve    : draw_tooltip_curve(content);                                                         break;
				case VALUE_TYPE.color    : draw_tooltip_color(content);                                                         break;
				case VALUE_TYPE.gradient : draw_tooltip_gradient(content);                                                      break;
				case VALUE_TYPE.atlas    : 
				case VALUE_TYPE.surface  : draw_tooltip_surface(content);                                                       break;
				case VALUE_TYPE.buffer   : draw_tooltip_buffer(content);                                                        break;
				case VALUE_TYPE.pathnode : draw_tooltip_path(content);                                                          break;
				
				case VALUE_TYPE.d3object : draw_tooltip_text($"[{__txt("3D Object")}]");                                        break;
				case VALUE_TYPE.object   : draw_tooltip_text($"[{__txt("Object")}]");                                           break;
				case VALUE_TYPE.rigid    : draw_tooltip_text($"[{__txt("Rigidbody Object")} (id: {content})]");                 break;
				case VALUE_TYPE.sdomain  : draw_tooltip_text($"[{__txt("Domain")} (id: {content})]");                           break;
				case VALUE_TYPE.d3vertex : draw_tooltip_text($"[{__txt("3D Vertex")} (groups: {array_length(content)})]");      break;
				
				case VALUE_TYPE.strands :
					var txt = __txt("Strands Object");
					if(is_struct(content))
						txt += $" (strands: {array_length(content.hairs)})";
					draw_tooltip_text($"[{txt}]");
					break;
				
				case VALUE_TYPE.mesh :
					var txt = __txt("Mesh Object");
					if(is(content, MeshedSurface)) txt += $" (triangles: {array_length(content.tris)})";
					draw_tooltip_text($"[{txt}]");
					break;
					
				case VALUE_TYPE.struct   : 
					if(has(content, "drawTooltip")) content.drawTooltip();
					else draw_tooltip_text(content);
					break;
				
				case "sprite"  : draw_tooltip_sprite(content);  break;
				case "project" : draw_tooltip_project(content); break;
				
				default :
					var tt = "";
					if(is_struct(content)) tt = $"[{instanceof(content)}] {content}";
					else                   tt = string(content);
					
					draw_tooltip_text(tt);
			} 
			
		} 
		
		var tw = surface_get_width_safe(TOOLTIP_SURFACE);
		var th = surface_get_height_safe(TOOLTIP_SURFACE);
		
		var mx = 0;
		var my = 0;
			
		if(is_winwin(TOOLTIP_WINDOW)) {
			mx = min(mouse_rx + ui(16) - winwin_get_x(TOOLTIP_WINDOW), winwin_get_width(TOOLTIP_WINDOW)  - tw);
			my = min(mouse_ry + ui(16) - winwin_get_y(TOOLTIP_WINDOW), winwin_get_height(TOOLTIP_WINDOW) - th);
			
		} else {
			mx = min(mouse_mx + ui(16), WIN_W - tw);
			my = min(mouse_my + ui(16), WIN_H - th);
			
		}
		
		draw_surface_safe(TOOLTIP_SURFACE, mx, my);
		resetTOOLTIP();
	}
#endregion

function draw_tooltip_text(txt) {
	txt = array_to_string(txt);
	if(string_length(txt) > 1024)
		txt = string_copy(txt, 1, 1024) + "...";
	
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
	
	var tw = min(max(320, WIN_W * 0.4), string_width(txt));
	var th = string_height_ext(txt, -1, tw);
	var pd = ui(8);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		var _rect = gpu_get_scissor();
		gpu_set_scissor(pd, pd, tw, th);
		draw_text_line(pd, pd, txt, -1, tw);
		gpu_set_scissor(_rect);
	surface_reset_shader();
	
}

function draw_tooltip_color(clr) {
	if(is_array(clr)) { draw_tooltip_palette(clr); return; }
	
	var tw = ui(32);
	var th = ui(32);
	var pd = ui(4);
		
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		draw_sprite_stretched_ext(THEME.box_r2, 0, pd, pd, tw, th, clr, 1);
		draw_sprite_stretched_add(THEME.box_r2, 1, pd, pd, tw, th, c_white, 0.3);
	surface_reset_shader();
}

function draw_tooltip_palette(clr) {
	if(array_empty(clr)) return;
	
	var ph = ui(32);
	if(!is_array(clr[0])) clr = [ clr ];
	
	var pal_len = 0;
	for( var i = 0, n = array_length(clr); i < n; i++ ) 
		pal_len = max(pal_len, array_length(clr[i]));
	
	var tw = min(ui(160), ui(32) * pal_len);
	var th = array_length(clr) * ph;
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var _y = pd;
		for( var i = 0, n = array_length(clr); i < n; i++ ) {
			drawPalette(clr[i], pd, _y, tw, ph);
			_y += ph;
		}
		
		draw_sprite_stretched_add(THEME.box_r2, 1, pd, pd, tw, th, c_white, 0.3);
	surface_reset_shader();
}

function draw_tooltip_gradient(clr) {
	var gh = ui(32);
	if(!is_array(clr)) clr = [ clr ];
	
	var tw = ui(160);
	var th = array_length(clr) * gh;
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var _y = pd;
		for( var i = 0, n = array_length(clr); i < n; i++ ) {
			clr[i].draw(pd, _y, tw, gh);
			_y += gh;
		}
	surface_reset_shader();
}

function draw_tooltip_surface_array(surf) {
	if(!is_array(surf) || array_empty(surf)) return;
	
	if(is(surf[0], SurfaceAtlas)) {
		draw_tooltip_atlas(surf);
		return;
	}
	
	var amo = array_length(surf);
	var col = ceil(sqrt(amo));
	var row = ceil(amo / col);
	
	var nn = min(ui(64), ui(320) / col);
	var sw = nn;
	var sh = nn;
	
	var tw = sw * col;
	var th = sh * row;
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		for( var ind = 0; ind < amo; ind++ ) {
			if(!is_surface(surf[ind])) continue;
			
			var i = floor(ind / col);
			var j = safe_mod(ind, col);
			
			var sw = surface_get_width_safe(surf[ind]);
			var sh = surface_get_height_safe(surf[ind]);
			var ss = nn / max(sw, sh);
			var cx = pd + j * nn + nn / 2;
			var cy = pd + i * nn + nn / 2;
			
			draw_surface_ext_safe(surf[ind], cx - sw * ss / 2, cy - sh * ss / 2, ss, ss, 0, c_white, 1);
			draw_set_color(COLORS._main_icon);
			draw_rectangle(cx - sw * ss / 2, cy - sh * ss / 2, cx + sw * ss / 2 - 1, cy + sh * ss / 2 - 1, true);
		}
	surface_reset_shader();
}

function draw_tooltip_surface(surf) {
	if(is_array(surf))         { draw_tooltip_surface_array(array_spread(surf)); return; }
	if(is(surf, SurfaceAtlas)) { draw_tooltip_atlas(surf);                       return; }
	if(!is_surface(surf)) return;
	
	var sw = surface_get_width_safe(surf);
	var sh = surface_get_height_safe(surf);
	
	var ss = min(ui(128) / sw, ui(128) / sh);
	
	var tw = sw * ss;
	var th = sh * ss;
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		draw_surface_ext_safe(surf, pd, pd, ss, ss);
	surface_reset_shader();
}

function draw_tooltip_sprite(spr) {
	if(!sprite_exists(spr)) return;
	
	var ox = sprite_get_xoffset(spr);
	var oy = sprite_get_yoffset(spr);
	
	var sw = sprite_get_width(spr);
	var sh = sprite_get_height(spr);
	var sn = sprite_get_number(spr);
	
	var ss = min(max(1, min(ui(64) / sw, ui(64) / sh)), ui(320) / sw, ui(320) / sh);
	
	var tw = sw * ss * sn + 2 * (sn - 1);
	var th = sh * ss + ui(16);
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var sx = pd + ox * ss;
		var sy = pd + oy * ss;
		
		for( var i = 0; i < sn; i++ )
			draw_sprite_ext(spr, i, sx + i * (sw * ss + 2), sy, ss, ss, 0, c_white, 1);
		
		draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_text_sub);
		draw_text_add(tww / 2, thh - ui(4), $"{sw} x {sh} px");
	surface_reset_shader();
}

function draw_tooltip_project(pObj) {
	if(!has(pObj, "path") || !has(pObj, "getThumbnail")) return;
	
	var pth = pObj.path;
	var spr = pObj.getThumbnail();
	
	draw_set_font(f_p3);
	var txt = filename_name(pth);
	var tw  = string_width(txt) + ui(16);
	
	var ox = sprite_get_xoffset(spr);
	var oy = sprite_get_yoffset(spr);
	
	var sw = sprite_get_width(spr);
	var sh = sprite_get_height(spr);
	var ss = max(2, tw / sw);
	
	var tw = sw * ss;
	var th = sh * ss + ui(16);
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var sx = pd + ox * ss;
		var sy = pd + oy * ss;
		
		draw_sprite_ext(spr, 0, sx, sy, ss, ss, 0, c_white, 1);
		
		draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_text_sub);
		draw_text_add(tww / 2, thh - ui(4), txt);
	surface_reset_shader();
}

function draw_tooltip_atlas(atlas) {
	if(!is_array(atlas)) atlas = [ atlas ];
	
	var amo = array_length(atlas);
	if(amo && is_array(atlas[0])) return;
	
	var wwd = ui(96);
	var wd  = wwd + ui(8);
	
	var hhg = ui(32);
	var hg  = hhg + ui(8);
	
	var row = min(floor(sqrt(amo) * 1.5), floor((WIN_H - ui(16)) / hg));
	var col = ceil(amo / row);
	
	var tw  = col * wd - ui(8);
	var th  = row * hg - ui(8);
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var sx = pd;
		var sy = pd;
		
		for( var i = 0; i < amo; i++ ) {
			var _c = floor(i / row);
			var _r = i % row;
			
			var _x = sx + _c * wd;
			var _y = sy + _r * hg;
			
			var atl  = atlas[i];
			if(!is(atl, SurfaceAtlas)) continue;
			
			var surf = atl.getSurface();
			if(!is_surface(surf)) continue;
			
			var sw = surface_get_width_safe(surf);
			var sh = surface_get_height_safe(surf);
			
			var ss = min(hhg / sw, hhg / sh);
			draw_surface_ext_safe(surf, _x, _y, ss, ss);
			
			draw_set_color(COLORS._main_icon);
			draw_rectangle(_x, _y, _x + hhg, _y + hhg, 1);
			
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + hhg + ui(4), _y + ui(-4), __txt("Pos"));
			draw_text_add(_x + hhg + ui(4), _y + ui( 8), __txt("Rot"));
			draw_text_add(_x + hhg + ui(4), _y + ui(20), __txt("Sca"));
			
			draw_set_text(f_p4, fa_right, fa_top, COLORS._main_text);
			draw_text_add(_x + wwd, _y + ui(-4), $"{atl.x}, {atl.y}");
			draw_text_add(_x + wwd, _y + ui( 8), atl.rotation);
			draw_text_add(_x + wwd, _y + ui(20), $"{atl.sx}, {atl.sy}");
		}
	surface_reset_shader();	
}

function draw_tooltip_buffer(buff) {
	var txt = buffer_get_string(buff, false, 400);
	var len = string_length(txt);
	
	if(len > 400) txt = string_copy(txt, 1, 400);
	
	draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
	
	var tw = min(string_width(" ") * 40, string_width(txt));
	var th = string_height_ext(txt, -1, tw);
	if(len > 400) th += string_height(" ");
	var pd = ui(8);
		
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		draw_text_line(pd, pd, txt, -1, tw);
		
		if(len > 400) {
			draw_set_text(f_code, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(pd, th + pd, $"...({buffer_get_size(buff)} bytes)");
		}
	surface_reset_shader();
}

function draw_tooltip_curve(curve) {
	var tw = ui(160);
	var th = ui(160);
	var pd = ui(8);
		
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var x0 = pd, x1 = x0 + tw;
		var y0 = pd, y1 = y0 + th;
		var st = 0.1;
			
		draw_set_color(COLORS.widget_curve_line);
		draw_set_alpha(0.15);
		
		for( var i = st; i < 1; i += st ) {
			var _y0 = y0 + th * (1 - i);
			draw_line(x0, _y0, x1, _y0);
			
			var _x0 = x0 + tw * i;
			draw_line(_x0, y0, _x0, y1);
		}
		
		draw_set_alpha(1);
		
		draw_set_color(COLORS._main_accent);
		draw_curve(x0, y0, tw, th, curve);
		
		draw_set_color(COLORS.widget_curve_outline);
		draw_rectangle(x0, y0, x1, y1, true);
	surface_reset_shader();
	
}

function draw_tooltip_path(_path) {
	if(!is_path(_path)) return;
	
	var tw = ui(160);
	var th = ui(160);
	var pd = ui(8);
		
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var x0 = pd, x1 = x0 + tw;
		var y0 = pd, y1 = y0 + th;
		var st = 0.1;
			
		draw_set_color(COLORS.widget_curve_line);
		draw_set_alpha(0.15);
		
		for( var i = st; i < 1; i += st ) {
			var _x0 = x0 + tw * i;
			var _y0 = y0 + th * (1 - i);
			
			draw_line(x0, _y0, x1, _y0);
			draw_line(_x0, y0, _x0, y1);
		}
		
		draw_set_alpha(1);
		
		draw_set_color(COLORS._main_accent);
		var _pamo = _path.getLineCount();
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
		
		draw_set_text(f_p4, fa_left, fa_bottom);
		draw_text_add(x0 + ui(2), y1, $"Lines: {_pamo}");
	surface_reset_shader();
	
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
		var pd = ui(8);
		
		var tww = tw + pd * 2;
		var thh = th + pd * 2;
		
		TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
		surface_set_shader(TOOLTIP_SURFACE);
			draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			draw_text_add(pd, pd, title);
			
			draw_set_font(f_p3);
			
			for( var i = 0, n = array_length(keys); i < n; i++ ) {
				var _hx = ui(12) + string_width(keys[i][0]);
				var _hy = ui(8) + h1 + ui(4) + h2 / 2 + ui(4);
				hotkey_draw(keys[i][0], _hx, _hy);
				
				draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
				draw_text_add(_hx + ui(8), ui(8) + h1 + ui(6), keys[i][1]);
			}
		surface_reset_shader();
	}
}

function tooltip_two_lines(title, content) constructor {
	self.title   = title;
	self.content = content;
	
	static drawTooltip = function() {
		
		draw_set_font(f_p1b);
		var w1 = string_width(title);
		var h1 = string_height(title);
		
		draw_set_font(f_p2);
		var w2 = string_width(content);
		var h2 = string_height(content);
		
		var tw = max(w1, w2);
		var th = h1 + h2;
		var pd = ui(8);
		
		var tww = tw + pd * 2;
		var thh = th + pd * 2;
		
		TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
		surface_set_shader(TOOLTIP_SURFACE);
			draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
			
			draw_set_text(f_p2b, fa_left, fa_top, COLORS._main_text_accent);
			draw_text_add(pd, pd, title);
			
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
			draw_text_add(pd, pd + h1, content);
		surface_reset_shader();
	}
}