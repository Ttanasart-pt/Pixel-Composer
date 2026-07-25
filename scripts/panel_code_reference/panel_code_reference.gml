function Panel_Code_Reference(_data) : PanelContent() constructor {
	title = "Code Reference";
	data  = _data;
	
	#region dimension
		w = ui(960);
		h = ui(640);
		
		cat_width = ui(160);
	#endregion
	
	#region data
		is_open = array_create(array_length(data), false);
		
		cat_goto   = undefined;
		categories = [];
		cat_view   = {};
		cat_amo    = {};
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _f = data[i];
			
			if(is_string(_f)) {
				array_push(categories, _f);
				cat_amo[$ _f] = 0;
			}
		}
	#endregion
	
	#region search
		tb_search   = textBox_Text(function(str) /*=>*/ {return setSearch(str)}).setFont(f_p3).setAlign(fa_left).setSearch();
		search_text = "";
		
		function setSearch(_txt) {
			search_text = _txt;
		}
	#endregion
	
	sp_cate = new scrollPane(0, 0, function(_y, _m) /*=>*/ {
		draw_clear_alpha(c_white, 0);
		var _h = 0;
		var _w = sp_cate.surface_w;
		
		var _hover = sp_cate.hover;
		var _focus = sp_cate.active;
		
		var hs = line_get_height(f_p3, 4);
		
		for( var i = 0, n = array_length(categories); i < n; i++ ) {
			var cat = categories[i];
			var tit = cat;
			
			var viw = has(cat_view, tit);
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], 0, _y, _w, _y + hs);
			var colr = viw? COLORS._main_text : COLORS._main_text_sub;
			if(_hov) colr = COLORS._main_accent;
			
			draw_set_text(f_p3, fa_left, fa_center, colr);
			draw_text_add(ui(4), _y + hs / 2, tit);
			
			if(_hov && mouse_lpress(_focus))
				cat_goto = tit;
			
			_y += hs;
		}
		
		return _h;
	});
	
	sp_note = new scrollPane(0, 0, function(_y, _m) /*=>*/ {
		draw_clear_alpha(c_white, 0);
		var amo = array_length(data);
		var pad = ui(4);
		var yy  = _y + pad;
		var _h  = 0;
		var ind = 0;
		
		var _hh = sp_cate.surface_h;
		
		var _searching = search_text != "";
		var _sr_text   = string_lower(search_text);
		
		var cat_curr = undefined;
		    cat_view = {};
		
		for( var i = 0; i < amo; i++ ) {
			var _f = data[i];
			
			if(is_string(_f)) {
				cat_curr = _f;
				
				if(cat_amo[$ cat_curr] == 0) continue;
				cat_amo[$ cat_curr] = 0;
				
				draw_set_text(f_p1b, fa_left, fa_top, COLORS._main_text_accent);
				yy += ui(8);
				var hh = line_get_height() + pad + ui(8);
				
				draw_text_add(ui(24), yy, _f);
				
				if(cat_goto == _f) {
					cat_goto = undefined;
					sp_note.setScroll(-_h);
				}
				
				if(yy > -hh && yy < _hh)
					cat_view[$ _f] = 1;
				
				ind = 0;
				yy += hh;
				_h += hh;
				continue;
			}
			
			draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
			var _func = _f.syn;
			var _desp = _f.desp;
			var _args = _f.despArg;
			var _outt = _f.typeOut;
			
			if(_searching) {
				var _filt = bool(string_pos(_sr_text, string_lower(_func))) || 
				            bool(string_pos(_sr_text, string_lower(_desp)));
            	if(!_filt) continue;
			}
			
			var hh = line_get_height();
			if(is_open[i]) {
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
				hh += pad + string_height(_desp) + ui(8);
				if(array_length(_args)) 
					hh += (line_get_height() + ui(4)) * (array_length(_args) + 1) + ui(20);
			}
			hh += pad * 2;
			
			BLEND_OVERRIDE
			if(sp_note.hover && point_in_rectangle(_m[0], _m[1], 0, yy, sp_note.surface_w, yy + hh)) {
				sp_note.hover_content = true;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, 0, yy, sp_note.surface_w, hh, COLORS.dialog_lua_ref_bg_hover, 1);
				
				if(mouse_lpress(pFOCUS)) 
					is_open[i] = !array_get(is_open, i);
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, 0, yy, sp_note.surface_w, hh, COLORS.dialog_lua_ref_bg, 1);
			BLEND_NORMAL
			
			draw_sprite_ui(THEME.arrow, is_open[i]? 3 : 0, ui(16), yy + pad + line_get_height() / 2,,,, COLORS._main_icon);
			draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
			var tx = ui(28);
			draw_code_lua(tx, yy + pad, _func); tx += string_width(_func) + ui(20);
			draw_sprite_ui(THEME.arrow, 0, tx - ui(10), yy + pad + ui(8), .8, .8, 0, COLORS._main_icon);
			draw_set_color(COLORS._main_text_sub);
			draw_text_add(tx, yy + pad, _outt);
			
			if(is_open[i]) {
				var ty = yy + pad + line_get_height() + ui(4);
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
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
					
					draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
					ty += line_get_height() + ui(4);
					for( var j = 0; j < array_length(_args); j++ ) {
						draw_text(ax0, ty, _args[j][0]);
						draw_text(ax1, ty, _args[j][1]);
						draw_text(ax2, ty, _args[j][2]);
						
						ty += line_get_height() + ui(4);
					}
				}
			}
			
			if(cat_curr != undefined)
				cat_amo[$ cat_curr]++;
					
			ind++;
			yy += hh + pad;
			_h += hh + pad;
		}
		
		return _h + ui(128);
	});
	
	function drawContent(panel) {
		var px = padding;
		var py = padding;
		var pw = cat_width - padding - ui(8);
		var ph = h - padding * 2;
		
		var tbh = ui(24);
		
    	tb_search.setFocusHover(pFOCUS, pHOVER);
    	tb_search.labelColor = search_text == ""? COLORS._main_text_sub : COLORS._main_value_positive;
    	tb_search.labelAlpha = search_text == ""? .65 : 1;
    	tb_search.draw(px, py, pw, tbh, search_text, [ mx, my ]);
    	
    	py += tbh + ui(8);
    	ph -= tbh + ui(8);
    	
		sp_cate.verify(pw, ph);
		sp_cate.setFocusHover(pFOCUS, pHOVER);
		sp_cate.drawOffset(px, py, mx, my);
		
		var px = padding + cat_width;
		var py = padding;
		var pw = w - padding * 2 - cat_width;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_note.verify(pw, ph);
		sp_note.setFocusHover(pFOCUS, pHOVER);
		sp_note.drawOffset(px, py, mx, my);
		
	}
}