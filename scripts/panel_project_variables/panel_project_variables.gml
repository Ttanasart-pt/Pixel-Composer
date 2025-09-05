function Panel_Project_Var(_proj = PROJECT) : PanelContent() constructor {
	title   = __txt("Project Variables");
	project = _proj;
	w = ui(480);
	h = ui(640);
	
	keyCol_w = ui(200);
	
	editing_key  = undefined;
	editing_text = "";
	editing_type = 0;
	edit_x = 0;
	edit_y = 0;
	
	tb_edit      = textBox_Text(function(text) /*=>*/ {
		if(editing_key == undefined) return;
		
		var _vars = project.attributes.env_variables;
		editing_text = text;
		
		if(editing_type == 0) {
			if(editing_key != "" && has(_vars, editing_key)) {
				var _val = _vars[$ editing_key];
				struct_remove(_vars, editing_key);
			}
			
			if(text != "")
				_vars[$ text] = _val;
			
		} else if(editing_key != "")
			_vars[$ editing_key] = text;
		
		editing_key = undefined;
		
	}).setFont(f_p1);
	
	sc_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_content.surface_w;
		var hh = sc_content.surface_h;
		var _h = 0;
		var yy = _y;
		
		var focus = sc_content.active;
		var hover = sc_content.hover;
		
		var _vars = project.attributes.env_variables;
		var _vark = struct_get_names(_vars);
		
		var hg = line_get_height(f_p2, 4);
		
		var padx = ui(8);
		var pady = ui(2);
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(padx + ui(8), yy + ui(2), "key");
		
		draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text_sub);
		draw_text_add(ww - padx - ui(8 + 32), yy + ui(2), "value");
		
		yy += hg;
		_h += hg;
		
		draw_set_color(CDEF.main_dkgrey);
		draw_line(padx, yy, ww - padx, yy);
		
		yy += ui(4);
		_h += ui(4);
		
		var delK = "";
		var hg   = line_get_height(f_p1, 4);
		var scis = gpu_get_scissor();
		
		for( var i = 0, n = array_length(_vark); i < n; i++ ) {
			var _key = _vark[i];
			var _val = _vars[$ _key];
			
			if(i % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, padx, yy - pady, ww - padx * 2, hg + pady * 2, COLORS.dialog_preference_prop_bg, .75);
			
			var _hov = hover && point_in_rectangle(_m[0], _m[1], padx + ui(8), yy, ww / 2, yy + hg - 1);
			if(_hov) {
				draw_sprite_stretched(THEME.textbox, 0, padx, yy, ww / 2, hg);
					
				if(mouse_lpress(focus)) {
					editing_key  = _key;
					editing_text = _key;
					editing_type = 0;
					edit_x = padx;
					edit_y = yy;
					
					tb_edit.activate(_key);
				}
			
			}
			
			var _hov = hover && point_in_rectangle(_m[0], _m[1], ww / 2, yy, ww - padx - ui(8 + 32), yy + hg - 1);
			if(_hov) {
				draw_sprite_stretched(THEME.textbox, 0, ww / 2, yy, ww / 2 - padx - ui(32), hg);
				
				if(mouse_lpress(focus)) {
					editing_key  = _key;
					editing_text = _val;
					editing_type = 1;
					edit_x = padx;
					edit_y = yy;
					
					tb_edit.activate(_val);
				}
			
			}
			
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
			gpu_set_scissor(0, yy, ww / 2 - ui(4), hg);
			draw_text_add(padx + ui(8), yy + ui(2), _key);
			
			gpu_set_scissor(ww / 2 + ui(4), yy, ww / 2, hg);
			draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text);
			draw_text_add(ww - padx - ui(8 + 32), yy + ui(2), _val);
			
			if(buttonInstant(THEME.button_hide, ww - padx - ui(32), yy, ui(32), hg, _m, hover, focus, "", THEME.minus_16, 0, COLORS._main_value_negative, .5) == 2) {
				delK = _key;
			}
			
			yy += hg;
			_h += hg;
		}
		
		if(delK != "") struct_remove(_vars, delK);
		
		gpu_set_scissor(scis);
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], padx + ui(8), yy, ww - padx - ui(8), yy + hg - 1);
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_value_positive, _hov * .5 + .5);
		draw_text_add(padx + ui(8), yy + ui(2), "+ Add key");
		draw_set_alpha(1);
		
		if(_hov && mouse_lpress(focus)) {
			editing_key  = "";
			editing_text = "";
			editing_type = 0;
			edit_x = padx;
			edit_y = yy;
			
			tb_edit.activate("");
		}
		
		if(editing_key != undefined) {
			var _param = new widgetParam(edit_x, edit_y, ww - padx * 2, hg, editing_text, {}, _m).setFocusHover(focus, hover);
				
			tb_edit.align = editing_type == 0? fa_left : fa_right;
			tb_edit.drawParam(_param);
		}
		
		yy += hg;
		_h += hg;
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_content.verify(pw, ph);
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.draw(px, py, mx - px, my - py);
		
	}
} 