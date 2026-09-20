function Panel_Dialog_Manager() : PanelContent() constructor {
	title = __txt("Dialog Manager");
	w = ui(320);
	h = ui(480);
	
	content = [];
	
	function refreshContent() {
		content = [ { name: "Main Window", type: "window", object: undefined, panels: PANEL_MAIN.getAllContent() } ];
		var _con = content;
		
		with(_p_dialog) {
			var _self = self;
			
			if(object_index == o_dialog_panel) {
				array_push(_con, { name: title, type: "panel", object: _self, panels: panel.getAllContent() });
				continue;
			}
			
			array_push(_con, { name: title, type: "dialog", object: _self });
		}
	}
	
	refreshContent();
	
	sc_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_content.surface_w;
		var hh = sc_content.surface_h;
		var _h = 0;
		var yy = _y;
		
		var focus = sc_content.active;
		var hover = sc_content.hover;
		
		var hg = ui(24);
		refreshContent();
		
		for( var i = 0, n = array_length(content); i < n; i++ ) {
			var _cont = content[i];
			
			var _name = _cont.name;
			var _type = _cont.type;
			var _objt = _cont.object;
			
			var _hov = hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg);
			
			draw_sprite_stretched(THEME.box_r2_clr, 0, 0, yy, ww, hg);
			if(_hov) draw_sprite_stretched(THEME.box_r2_clr, 1, 0, yy, ww, hg);
			
			var bs = hg;
			var bx = ww - bs;
			var by = yy;
			
			var bspr = THEME.window_exit_icon;
			if(_objt != undefined) {
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hover, focus, "", bspr, 0, CARRAY.button_negative, 1, ui(6)) == 2)
					instance_destroy(_objt);
			} else buttonInstant_Pad(noone, bx, by, bs, bs, _m, false, false, "", bspr, 0, COLORS._main_icon_dark, 1, ui(6))
			bx -= bs + 1;
			
			draw_sprite_ui_uniform(THEME.workshop_project, 0, ui(16), yy + hg / 2, .3, COLORS._main_icon);
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(32), yy + hg / 2, _name);
			
			yy += hg;
			_h += hg;
			
			if(has(_cont, "panels")) {
				for( var j = 0, m = array_length(_cont.panels); j < m; j++ ) {
					var _pan = _cont.panels[j];
					
					draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(ui(32), yy + ui(16) / 2, _pan.title);
					
					yy += ui(16);
					_h += ui(16);
					
				}
			}
			
			yy += ui(8);
			_h += ui(8);
			
		}
		
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