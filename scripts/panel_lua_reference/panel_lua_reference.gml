function Panel_Lua_Reference() : PanelContent() constructor {
	title = "Lua Reference";
	w = ui(960);
	h = ui(640);
	
	panel_width   = w - padding * 2;
	panel_height  = h - padding * 2;
	
	is_open = array_create(array_length(global.lua_functions), false);
	sp_note = new scrollPane(panel_width, panel_height, function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var f = global.lua_functions;
		var amo = array_length(f);
		var pad = ui(4);
		var yy = _y + pad;
		var _h = 0;
		var ind = 0;
		
		for( var i = 0; i < amo; i++ ) {
			var _f = f[i];
			if(is_string(_f)) {
				draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_accent);
				yy += ui(8);
				var hh = line_get_height() + pad + ui(8);
				
				draw_text_add(ui(24), yy, _f);
				
				ind = 0;
				yy += hh;
				_h += hh;
				continue;
			}
			
			draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
			var _func = array_length(_f) > 2? _f[2] : _f[0];
			var _desp = array_safe_get_fast(_f, 3, "");
			var _args = array_safe_get_fast(_f, 4, []);
			var hh = line_get_height();
			if(is_open[i]) {
				draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
				hh += pad + string_height(_desp) + ui(8);
				if(array_length(_args)) 
					hh += (line_get_height() + ui(4)) * (array_length(_args) + 1) + ui(20);
			}
			hh += pad * 2;
			
			BLEND_OVERRIDE
			if(sp_note.hover && point_in_rectangle(_m[0], _m[1], 0, yy, sp_note.surface_w, yy + hh)) {
				sp_note.hover_content = true;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy, sp_note.surface_w, hh, COLORS.dialog_lua_ref_bg_hover, 1);
				
				if(mouse_press(mb_left, pFOCUS)) 
					is_open[i] = !array_get(is_open, i);
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy, sp_note.surface_w, hh, COLORS.dialog_lua_ref_bg, 1);
			BLEND_NORMAL
			
			draw_sprite_ui(THEME.arrow, is_open[i]? 3 : 0, ui(16), yy + pad + line_get_height() / 2,,,, COLORS._main_icon);
			draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
			draw_code_lua(ui(28), yy + pad, _func);
			
			if(is_open[i]) {
				var ty = yy + pad + line_get_height() + ui(4);
				draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_sub);
				draw_text(ui(32), ty, _desp);
				
				if(array_length(_args)) {
					var ax0 = ui(64 + 16);
					var ax1 = ui(200);
					var ax2 = ui(320);
					ty += line_get_height() + ui(12);
					
					var ah = (line_get_height() + ui(4)) * (array_length(_args) + 1) + ui(8);
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(64), ty, sp_note.surface_w - ui(96), ah, 
						COLORS.dialog_lua_ref_bg_args, 1);
					
					ty += ui(4);
					draw_text(ax0, ty, "Argument");
					draw_text(ax1, ty, "Type");
					draw_text(ax2, ty, "Description");
					
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
					ty += line_get_height() + ui(4);
					for( var j = 0; j < array_length(_args); j++ ) {
						draw_text(ax0, ty, _args[j][0]);
						draw_text(ax1, ty, _args[j][1]);
						draw_text(ax2, ty, _args[j][2]);
						
						ty += line_get_height() + ui(4);
					}
				}
			}
			
			ind++;
			yy += hh + pad;
			_h += hh + pad;
		}
		
		return _h + ui(128);
	})
	
	function drawContent(panel) {
			
		panel_width   = w - padding * 2;
		panel_height  = h - padding * 2;
		
		var px = padding;
		var py = padding;
		var pw = panel_width;
		var ph = panel_height;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_note.verify(panel_width, panel_height);
		sp_note.setFocusHover(pFOCUS, pHOVER);
		sp_note.drawOffset(px, py, mx, my);
		
	}
}