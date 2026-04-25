function Panel_Migration_Error(_project) : PanelContent() constructor {
	title = "Migration Error";
	w = ui(600);
	h = ui(200);
	auto_pin = true;
	padding  = ui(8);
	project  = _project;
	
	selecting = undefined;
	
	sp_content = new scrollPane(0, 0, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww = sp_content.surface_w;
		var hh = ui(8);
		var yy = _y;
		
		var hover = sp_content.hover;
		var focus = sp_content.active;
		
		var hg  = ui(24);
		var del = undefined;
		var btD = __txt("Done");
		
		var _data = project.migrationError;
		for( var i = 0, n = array_length(_data); i < n; i++ ) {
			var _mig = _data[i];
			var _txt = _mig.txt;
			var _ref = _mig.reference;
			var _spr = _mig.spr;
			
			draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, ww, hg, CDEF.main_mdwhite);
			draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, ui(32), hg);
			
			if(sprite_exists(_spr)) {
				var sps = min(ui(32 - 4) / sprite_get_width(_spr), (hg - ui(4)) / sprite_get_height(_spr));
				draw_sprite_ext(_spr, 0, ui(16), yy + hg / 2, sps, sps);
			}
			
			if(selecting == _mig) draw_sprite_stretched_ext(THEME.box_r5, 1, 0, yy, ww, hg, COLORS._main_accent);
			var hov = hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww - ui(32), yy + hg);
			if(hov) {
				draw_sprite_stretched_add(THEME.box_r5_clr, 1, 0, yy, ww, hg, c_white, .5);
				if(mouse_lpress(focus)) {
					selecting = _mig;
					if(is(_ref, NodeValue))
						inspectorFocusProp(_ref);
				}
			}
			
			var bw = ui(28);
			var bh = hg - ui(4);
			var bx = ww - ui(2) - bw;
			var by = yy + ui(2);
			var cc = COLORS._main_value_positive;
			if(buttonInstant(THEME.button_hide_fill, bx, by, bw, bh, _m, hover, focus, btD, THEME.accept_16, 0, cc) == 2)
				del = i;
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(32 + 8), yy + hg / 2, _txt);
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		if(del != undefined) array_delete(_data, del, 1);
		return hh;
	});
	
	function drawContent(panel) {
		if(!project.active || array_empty(project.migrationError)) { close(); return; }
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_content.setFocusHover(pFOCUS, pHOVER);
		sp_content.verify(pw, ph);
		sp_content.drawOffset(px, py, mx, my);
		
	}
}