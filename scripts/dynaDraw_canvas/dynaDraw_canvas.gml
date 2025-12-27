function dynaDraw_canvas() : dynaDraw() constructor {
	
	surfaces      = [undefined];
	surfaceBuffer =  undefined;
	
	parameters = [ "dimension" ];
	dimension  = [1,1];
	editors    = [
		[ "Dimension", new vectorBox(2, function(n,i) /*=>*/ { dimension[i] = n; resizeSurface(); updateNode(); }), function() /*=>*/ {return dimension} ],
	];
	
	widgetH       = ui(160);
	current_tool  = undefined;
	current_color = ca_white;
	
	tool_scroll     = 0;
	tool_scroll_to  = 0;
	tool_scroll_max = 0;
	
	////- Data
	
	static resizeSurface = function() {
		surfaces[0] = surface_verify(surfaces[0], dimension[0], dimension[1]);
		updateBuffer();
		return self;
	}
	
	static getSurface = function() {
		if(surface_exists(surfaces[0]))       return surfaces[0];
		if(!buffer_exists(surfaceBuffer)) {
			resizeSurface();
			return surfaces[0]; 
		}
		
		surfaces[0] = surface_verify(surfaces[0], dimension[0], dimension[1]);
		buffer_set_surface(surfaceBuffer, surfaces[0], 0);
		
		return surfaces[0];
	}
	
	static updateBuffer = function() {
		if(!surface_exists(surfaces[0])) return;
		
		var siz = surface_get_byte_size(surfaces[0]);
		surfaceBuffer = buffer_verify(surfaceBuffer, siz, buffer_fixed, 1);
		buffer_get_surface(surfaceBuffer, surfaces[0], 0);
	}
	
	////- Draw
	
	static drawWidget = function(_x, _y, _w, _h, _m, hover, active, _rx, _ry) {
		_h = widgetH;
		
		var _ars = .5;
		var _arw = sprite_get_width(THEME.scroll_box_arrow) * _ars + ui(8);
		var  ww  = _w - _arw;
		var _surf = getSurface();
		
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
		
		#region canvas
			var dim = dimension;
			var _canvas_s = min((ww - ui(16)) / dim[0], (_h - ui(16)) / dim[1]);
			var _canvas_w = dim[0] * _canvas_s;
			var _canvas_h = dim[1] * _canvas_s;
			var _canvas_x = _x + ww / 2 - _canvas_w / 2;
			var _canvas_y = _y + _h / 2 - _canvas_h / 2;
			
			var hv = hover && point_in_rectangle(_m[0], _m[1], _canvas_x, _canvas_y, _canvas_x + _canvas_w, _canvas_y + _canvas_h);
			
			var pixel_x = floor((_m[0] - _canvas_x) / _canvas_s);
			var pixel_y = floor((_m[1] - _canvas_y) / _canvas_s);
			
			surface_set_target(_surf);
				if(hv && mouse_click(mb_left, active))
				switch(current_tool) {
					case -1 : // eraser
						BLEND_SUBTRACT
							draw_point_color(pixel_x, pixel_y, c_white);
						BLEND_NORMAL
						break;
					
					case  1 : // brush
						draw_point_color(pixel_x, pixel_y, current_color);
						break;
						
				}
			surface_reset_target();
			draw_surface_ext(_surf, _canvas_x, _canvas_y, _canvas_s, _canvas_s, 0, c_white, 1);
			
			if(hv && current_tool != undefined) {
				var px = _canvas_x + pixel_x * _canvas_s;
				var py = _canvas_y + pixel_y * _canvas_s;
				draw_sprite_stretched_add(THEME.textbox, 1, px, py, _canvas_s, _canvas_s);
				
				if(mouse_release(mb_left)) {
					updateBuffer();
					updateNode();
				}
			}
			
			if(key_press(vk_escape)) current_tool = undefined;
		#endregion
		
		#region tools
			var bs = THEME.button_hide;
			draw_sprite_stretched_ext(THEME.textbox, 3, _x + ww, _y, _arw, _h, CDEF.main_mdwhite, 1);
			
			var ts = _arw - ui(6);
			var tx = _x + ww + ui(3);
			var ty = _y + ui(3);
			var th = _h - _arw - ui(3);
			
			var cc = current_tool == -1? COLORS._main_accent : COLORS._main_icon;
			if(buttonInstant_Pad(bs, tx, ty, ts, ts, _m, hover, active, "Eraser", THEME.canvas_tools_eraser, 0, cc) == 2)
				current_tool = current_tool == -1? undefined : -1;
			ty += ts + ui(2); th -= ts + ui(2);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, tx, ty, ts, ts, current_color, 1);
			BLEND_SUBTRACT
			draw_sprite_stretched(THEME.ui_panel, 2, tx, ty, ts, ts);
			BLEND_NORMAL
			draw_sprite_stretched_add(THEME.ui_panel, 1, tx, ty, ts, ts, current_tool == 1? COLORS._main_accent : COLORS._main_icon, 1);
			
			if(hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + ts, ty + ts)) {
				draw_sprite_stretched_add(THEME.ui_panel, 1, tx, ty, ts, ts, COLORS._main_icon, .5);
				if(mouse_lpress(active)) {
					colorSelectorCall(current_color, function(c) /*=>*/ {
						current_tool  = 1;
						current_color = c;
					});
				}
			}
			ty += ts + ui(2); th -= ts + ui(2);
			
			var palt = DEF_PALETTE;
			var scis = gpu_get_scissor();
			var phov = hover && point_in_rectangle(_m[0], _m[1], _x + ww, ty, _x + _w, ty + th);
			
			gpu_set_scissor(_x + ww, ty, _arw, th);
				var py = ty - tool_scroll;
				var ph = ui(10);
				
				for( var i = 0, n = array_length(palt); i < n; i++ ) {
					var colr = palt[i];
					var hovv = phov && point_in_rectangle(_m[0], _m[1], tx, py, tx + ts, py + ph);
					
					draw_sprite_stretched_ext(THEME.ui_panel, 0, tx, py, ts, ph, colr, 1);
					draw_sprite_stretched_add(THEME.ui_panel, 1, tx, py, ts, ph, COLORS._main_icon, .25);
					
					if(current_tool == 1 && current_color == colr) {
						BLEND_SUBTRACT
						draw_sprite_stretched(THEME.ui_panel, 2, tx, py, ts, ph);
						BLEND_NORMAL
						draw_sprite_stretched_ext(THEME.ui_panel, 1, tx, py, ts, ph, COLORS._main_accent, 1);
					}
					
					if(hovv) {
						draw_sprite_stretched_add(THEME.ui_panel, 1, tx, py, ts, ph, COLORS._main_icon, .25);
						
						if(mouse_lpress(active)) {
							current_tool  = current_tool == 1 && current_color == colr? undefined : 1;
							current_color = colr;
						}
					}
					
					py += ph + ui(2);
				}
				
				tool_scroll_max = max(0, (ph + ui(2)) * array_length(palt) - th);
			gpu_set_scissor(scis);
			
			tool_scroll = lerp_float(tool_scroll, tool_scroll_to, 2);
			if(phov && key_mod_press(CTRL) && MOUSE_WHEEL != 0)
				tool_scroll_to = clamp(tool_scroll_to - MOUSE_WHEEL * 32, 0, tool_scroll_max);
			
			var _arx = _x + _w - _arw / 2;
			var _ary = _y + _h - _arw / 2;
			draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _arx, _ary, _ars, COLORS._main_icon);
		#endregion
		
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h);
		draw_sprite_stretched_ext(THEME.textbox, 0, _canvas_x, _canvas_y, _canvas_w, _canvas_h);
		if(hv) draw_sprite_stretched(THEME.textbox, 1, _canvas_x, _canvas_y, _canvas_w, _canvas_h);
		
		return _h;
	}
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		var surf = getSurface();
		draw_surface_ext_safe(surf, _x, _y, _sx, _sy, _ang, _col, _alp);
	}
	
	////- Serialize
	
	static doSerialize = function(m) {
		m.dimension = dimension;
		
		updateBuffer();
		if(buffer_exists(surfaceBuffer)) {
			var comp = buffer_compress(surfaceBuffer, 0, buffer_get_size(surfaceBuffer));
			var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
			m.data = enc;
		}
	}
	
	static deserialize = function(m) { 
		dimension = m.dimension;
		if(has(m, "data")) {
			var _data = m.data;
			
			var buff      = buffer_base64_decode(_data);
			surfaceBuffer = buffer_decompress(buff);
			surfaces[0]   = surface_create_from_buffer(dimension[0], dimension[1], surfaceBuffer);
		}
		
		return self; 
	}
}