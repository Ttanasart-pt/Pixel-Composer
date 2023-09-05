function Panel_Linear_Setting() : PanelContent() constructor {
	title = __txtx("preview_3d_settings", "3D Preview Settings");
	
	w = ui(380);
	
	bg_y    = -1;
	bg_y_to = -1;
	bg_a    = 0;
	
	properties = []
	static setHeight = function() { h = ui(12 + 36 * array_length(properties)); }
	
	static drawSettings = function(panel) {
		var yy = ui(24);
		var th = ui(36);
		var ww = w - ui(180);
		var wh = TEXTBOX_HEIGHT;
		
		var _hov = false;
		if(bg_y) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), bg_y, w - ui(8), th, COLORS.panel_prop_bg, 0.5 * bg_a);
		
		for( var i = 0, n = array_length(properties); i < n; i++ ) {
			var _prop = properties[i];
		
			var _widg = _prop[0];
			
			if(is_string(_widg)) {
				var _text = _prop[0];
				var _spr  = _prop[1];
				var _ind  = _prop[2];
				var _colr = _prop[3];
				
				draw_sprite_stretched_ext(THEME.group_label, 0, ui(4), yy - th / 2 + ui(2), w - ui(8), th - ui(4), _colr, 1);
				draw_sprite_ui(_spr, _ind, ui(4) + th / 2, yy);
				
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(4) + th, yy, _text);
				
				yy += th;
				continue;
			}
			
			var _text = _prop[1];
			var _data = _prop[2]();
		
			_widg.setFocusHover(pFOCUS, pHOVER);
			_widg.register();
			
			if(pHOVER && point_in_rectangle(mx, my, 0, yy - th / 2, w, yy + th / 2)) {
				bg_y_to = yy - th / 2;
				_hov = true;
			}
				
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(16), yy, _text);
		
			var params = new widgetParam(w - ui(8) - ww, yy - wh / 2, ww, wh, _data,, [ mx, my ], x, y);
			if(is_instanceof(_widg, checkBox)) {
				params.halign = fa_center;
				params.valign = fa_center;
			}
			
			_widg.drawParam(params);
		
			yy += th;
		}
		
		bg_a = lerp_float(bg_a, _hov, 2);
		
		if(bg_y == -1) bg_y = bg_y_to;
		else           bg_y = lerp_float(bg_y, bg_y_to, 2);
	}
	
	function drawContent(panel) { drawSettings(panel); }
}