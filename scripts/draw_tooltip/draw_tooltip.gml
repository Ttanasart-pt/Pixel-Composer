#region global
	globalvar TOOLTIP_SURFACE; TOOLTIP_SURFACE = undefined;
	globalvar TOOLTIP_BBOX; TOOLTIP_BBOX    = undefined;
	
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
		if(_MOUSE_BLOCK)                     { TOOLTIP_BBOX = undefined; return; }
		if(TOOLTIP == undefined)             { TOOLTIP_BBOX = undefined; return; }
		if(TOOLTIP_WINDOW != WINWIN_CURRENT) { TOOLTIP_BBOX = undefined; return; }
		
		var _xx;
		var _yy;
		
		if(is_winwin(TOOLTIP_WINDOW)) {
			_xx = mouse_rx + ui(16);
			_yy = mouse_ry + ui(16);
			
		} else {
			_xx = mouse_mx + ui(16);
			_yy = mouse_my + ui(16);
			
		}
		
		if(TOOLTIP_BBOX != undefined) {
			var tw = TOOLTIP_BBOX[2] - TOOLTIP_BBOX[0] + ui(8);
			var th = TOOLTIP_BBOX[3] - TOOLTIP_BBOX[1] + ui(8);
			
			if(is_winwin(TOOLTIP_WINDOW)) {
				_xx = min(_xx - winwin_get_x(TOOLTIP_WINDOW), winwin_get_width(TOOLTIP_WINDOW)  - tw);
				_yy = min(_yy - winwin_get_y(TOOLTIP_WINDOW), winwin_get_height(TOOLTIP_WINDOW) - th);
				
			} else {
				_xx = min(_xx, WIN_W - tw);
				_yy = min(_yy, WIN_H - th);
				
			}
		}
		
		if(is_surface(TOOLTIP_SURFACE)) surface_clear(TOOLTIP_SURFACE);
		
		if(is_struct(TOOLTIP)) {
			if(has(TOOLTIP, "drawTooltip")) {
				TOOLTIP.drawTooltip();
				drawTOOLTIP(_xx, _yy, true);
			}
			
		} else if(is_string(TOOLTIP)) {
			draw_tooltip_text(TOOLTIP);
			drawTOOLTIP(_xx, _yy, true);
			
		} else if(is_array(TOOLTIP)) {
			var raw  = TOOLTIP[0];
			var type = TOOLTIP[1];
			
			var content = raw;
			if(is(raw, valueKey)) {
				content = raw.value;
			} else if(is_method(raw)) content = raw();
			
			if(TOOLTIP_BBOX != undefined) {
				var _x0 = TOOLTIP_BBOX[0] - ui(4);
				var _y0 = TOOLTIP_BBOX[1] - ui(4);
				var _x1 = TOOLTIP_BBOX[2] + ui(4);
				var _y1 = TOOLTIP_BBOX[3] + ui(4);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y0, _x1-_x0, _y1-_y0, COLORS.node_base_bg);
			}
			
			TOOLTIP_BBOX = createTOOLTIP_signature(_xx, _yy, type, content);
		}
		
		resetTOOLTIP();
	}
	
	function createTOOLTIP_signature(_x, _y, _type, _content, _axis = 0) {
		if(is_array(_type) && !array_empty(_type)) {
			var pd = ui(4);
			
			var _x0 =  infinity;
			var _y0 =  infinity;
			
			var _x1 = -infinity;
			var _y1 = -infinity;
			
			_x += pd;
			_y += pd;
			
			var ox = _x;
			var oy = _y;
			
			var ww = is_winwin(TOOLTIP_WINDOW)? winwin_get_width(TOOLTIP_WINDOW)  : WIN_W;
			var hh = is_winwin(TOOLTIP_WINDOW)? winwin_get_height(TOOLTIP_WINDOW) : WIN_H;
			
			var dep = __array_get_depth(_type);
			var drw = true;
			
			if(dep == 1) {
				var _types  = _type[0];
				for( var i = 0, n = array_length(_type); i < n; i++ ) {
					if(_type[i] != _types) { _types = undefined; break; }
				}
				
				if(_types != undefined) { 
					var _draws  = is_struct(_content[0]) && _types != VALUE_TYPE.gradient && _types != VALUE_TYPE.pathnode;
					    _draws |= _types == VALUE_TYPE.color;
					
					if(_draws) {
						createTOOLTIP(_type[0], _content);
						var _d = drawTOOLTIP(_x, _y);
						
						_x0 = min(_x0, _d[0]);
						_y0 = min(_y0, _d[1]);
						_x1 = max(_x1, _d[2]);
						_y1 = max(_y1, _d[3]);
						drw = false;
					}
				}
			} 
			
			if(drw) {
				for( var i = 0, n = array_length(_type); i < n; i++ ) {
					var _t = _type[i];
					var _c = array_safe_get(_content, i);
					var _d = createTOOLTIP_signature(_x, _y, _t, _c, !_axis)
					
					_x0 = min(_x0, _d[0]);
					_y0 = min(_y0, _d[1]);
					_x1 = max(_x1, _d[2]);
					_y1 = max(_y1, _d[3]);
					
					if(_axis) _x += _d[2] - _d[0] + pd;
					else      _y += _d[3] - _d[1] + pd;
				}
			}
			
			_x0 -= pd; _y0 -= pd;
			_x1 += pd; _y1 += pd;
			
			draw_sprite_stretched_ext(THEME.box_r5, 1, _x0, _y0, _x1-_x0, _y1-_y0, COLORS._main_icon, .5);
			
			return [_x0,_y0,_x1,_y1];
		}
		
		createTOOLTIP(_type, _content);
		return drawTOOLTIP(_x, _y);
	}
			
	function createTOOLTIP(_type, _content) {
		if(is_surface(TOOLTIP_SURFACE)) surface_clear(TOOLTIP_SURFACE);
		var txt;
		var jun = THEME.node_junctions_single;
		
		switch(_type) {
			case VALUE_TYPE.float    :
			case VALUE_TYPE.integer  : 
			case VALUE_TYPE.text     : 
			case VALUE_TYPE.path     : draw_tooltip_text(_content);            break;
			
			case VALUE_TYPE.boolean  : draw_tooltip_text(printBool(_content)); break;
			case VALUE_TYPE.curve    : draw_tooltip_curve(_content);           break;
			case VALUE_TYPE.color    : draw_tooltip_color(_content);           break;
			case VALUE_TYPE.gradient : draw_tooltip_gradient(_content);        break;
			case VALUE_TYPE.atlas    : 
			case VALUE_TYPE.surface  : draw_tooltip_surface(_content);         break;
			case VALUE_TYPE.buffer   : draw_tooltip_buffer(_content);          break;
			case VALUE_TYPE.pathnode : draw_tooltip_path(_content);            break;
				
			case VALUE_TYPE.struct   : 
				if(has(_content, "drawTooltip")) _content.drawTooltip();
				else draw_tooltip_text(_content);
				break;
			
			case "sprite"  : draw_tooltip_sprite(_content);  break;
			case "project" : draw_tooltip_project(_content); break;
			
			default :
				if(is_int64(_type)) { // enum type is stored as int64
					var txt = string_title(value_type_to_string(_type));
					if(is_array(_content)) txt += $" [{array_length(_content)}]";
					draw_tooltip_text_sprite(txt, jun, _type); 
					break; 
				}
				
				var tt = "";
				if(is_struct(_content)) tt = $"[{instanceof(_content)}] {_content}";
				else                    tt = string(_content);
				draw_tooltip_text(tt);
		} 
	}
	
	function drawTOOLTIP(_x, _y, _clamp = false) {
		var tw = surface_get_width_safe(TOOLTIP_SURFACE);
		var th = surface_get_height_safe(TOOLTIP_SURFACE);
		
		var mx = _x;
		var my = _y;
		
		if(_clamp) {
			if(is_winwin(TOOLTIP_WINDOW)) {
				mx = min(_x - winwin_get_x(TOOLTIP_WINDOW), winwin_get_width(TOOLTIP_WINDOW)  - tw);
				my = min(_y - winwin_get_y(TOOLTIP_WINDOW), winwin_get_height(TOOLTIP_WINDOW) - th);
				
			} else {
				mx = min(_x, WIN_W - tw);
				my = min(_y, WIN_H - th);
				
			}
		}
		
		draw_surface_safe(TOOLTIP_SURFACE, mx, my);
		return [mx, my, mx+tw, my+th];
	}
	
#endregion

function draw_tooltip_text(txt) {
	txt = array_to_string(txt);
	if(string_length(txt) > 1024)
		txt = string_copy(txt, 1, 1024) + "...";
	
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
	
	var tw = min(max(320, WIN_W * 0.4), string_width(txt));
	var th = string_height_ext(txt, -1, tw);
	
	var pdx = ui(8);
	var pdy = ui(4);
	var tww = tw + pdx * 2;
	var thh = th + pdy * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		var _rect = gpu_get_scissor();
		gpu_set_scissor(pdx, pdy, tw, th);
		draw_text_line(pdx, pdy, txt, -1, tw);
		gpu_set_scissor(_rect);
	surface_reset_shader();
	
}

function draw_tooltip_text_sprite(txt, spr, ind = 0, bln = c_white) {
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
	
	var th = string_height(txt);
	var tw = min(max(320, WIN_W * 0.4), string_width(txt)) + ui(8) + th;
	
	var pdx = ui(8);
	var pdy = ui(4);
	var tww = tw + pdx * 2;
	var thh = th + pdy * 2;
	
	var ss  = th / max(sprite_get_width(spr), sprite_get_height(spr));
	var spx = pdx + th / 2;
	var spy = pdy + th / 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		var _rect = gpu_get_scissor();
		gpu_set_scissor(pdx, pdy, tw, th);
		draw_sprite_ext(spr, ind, spx, spy, ss, ss, 0, bln, 1);
		draw_text_line(pdx + ui(8) + th, pdy, txt, -1, tw);
		gpu_set_scissor(_rect);
	surface_reset_shader();
	
}

function draw_tooltip_color(clr) {
	if(is_array(clr)) { draw_tooltip_palette(clr); return; }
	
	var tw = ui(32);
	var th = line_get_height(f_p2);
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
	
	var ph = line_get_height(f_p2);
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
	var gh = line_get_height(f_p2);
	if(!is(clr, gradientObject)) return;
	
	var tw = ui(160);
	var th = gh;
	var pd = ui(4);
	
	var tww = tw + pd * 2;
	var thh = th + pd * 2;
	
	TOOLTIP_SURFACE = surface_verify(TOOLTIP_SURFACE, tww, thh);
	surface_set_shader(TOOLTIP_SURFACE);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		clr.draw(pd, pd, tw, gh);
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
	surface_set_shader(TOOLTIP_SURFACE, sh_sample, true, BLEND.normal);
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
	surface_set_shader(TOOLTIP_SURFACE, sh_sample, true, BLEND.normal);
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
	surface_set_shader(TOOLTIP_SURFACE, sh_sample, true, BLEND.normal);
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
	surface_set_shader(TOOLTIP_SURFACE, noone);
		draw_sprite_stretched(THEME.tooltip, 0, 0, 0, tww, thh);
		
		var x0 = pd, x1 = x0 + tw;
		var y0 = pd, y1 = y0 + th;
		var st = 0.1;
		
		draw_set_color(CDEF.main_dkgrey);
		for( var i = st; i < 1; i += st ) {
			var _x0 = x0 + tw * i;
			var _y0 = y0 + th * (1 - i);
			
			draw_line(x0, _y0, x1, _y0);
			draw_line(_x0, y0, _x0, y1);
		}
		
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