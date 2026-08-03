function Panel_Canvas_Tool_Settings() : PanelContent() constructor {
	context_str = "Canvas";
	title = "Canvas Tool Settings";
	auto_pin = true;
	
	min_w  = ui(40);
	min_h  = ui(32);
	
	canvas = undefined;
	pad    = ui(8);
	
	function drawSetting(_set, sx, sy, halign = fa_left) {
		if(!_set.visible) return 0;
		
		var wdh   = min(h - pad * 2, ui(24));
	
		var _name = _set.name;
		var _edtw = _set.editWidget;
		var _gett = _set.getter;
		var _sett = _set.setter;
		
		var val = _gett();
		var _sx = sx;
		var  ww = 0;
		
		var lType = "string";
		
		if(is_handle(_name) && sprite_exists(_name))
			lType = "sprite";
			
		if(is_string(_name) && _name == "")
			lType = "empty";
		
		if(lType == "sprite" && is(_edtw, checkBox)) {
			if(val) draw_sprite_stretched_ext(THEME.button_hide, 3, sx, sy - wdh / 2, wdh, wdh, COLORS._main_accent);
			else    draw_sprite_stretched_ext(THEME.button_hide, 1, sx, sy - wdh / 2, wdh, wdh);
			
			var hov = pHOVER && point_in_rectangle(mx, my, sx, sy - wdh / 2, sx + wdh, sy + wdh / 2);
			if(hov) {
				if(_set.tooltip != "")
					setTOOLTIP(_set.tooltip);
			
				draw_sprite_stretched_add(THEME.button_hide, 1, sx, sy - wdh / 2, wdh, wdh, c_white, .25);
				if(mouse_lpress(pFOCUS))
					_sett(!val);
			}
			
			var spw = sprite_get_width(_name);
			var sph = sprite_get_height(_name);
			
			var ss  = min((wdh - ui(4)) / spw, (wdh - ui(4)) / sph);
			draw_sprite_ext(_name, 0, sx + wdh / 2, sy, ss * .7, ss * .7);
			
			sx += wdh;
			ww += wdh;
			return ww;
		}
		
		if(lType == "string") {
			if(halign == fa_left) sx += ui(4);
			else                  sx -= ui(4);
			ww += ui(4);
			
			draw_set_text(f_p3, halign, fa_center, COLORS._main_text_sub);
			draw_text_add(sx, sy, _name);
			
			var lx = string_width(_name) + ui(4);
			if(halign == fa_left) sx += lx;
			else                  sx -= lx;
			ww += lx;
			
		} else if(lType == "sprite") {
			var spw = sprite_get_width(_name);
			var sph = sprite_get_height(_name);
			
			var ss  = min(wdh / spw, wdh / sph);
			draw_sprite_ext(_name, 0, sx + sph / 2, sy, ss * .7, ss * .7);
			
			var lx = ss * spw + ui(4);
			if(halign == fa_left) sx += lx;
			else                  sx -= lx;
			ww += lx;
		}
		
		var wdw = ui(32);
		     if(is(_edtw, buttonClass)) wdw = wdh;
		else if(is(_edtw, checkBox))    wdw = wdh;
		else if(is(_edtw, buttonGroup)) {
			_edtw.collapsable = false;
			wdw = wdh * _edtw.size;
			
		} else if(is(_edtw, checkBoxGroup)) {
			_edtw.collapsable = false;
			wdw = wdh * _edtw.size;
			
		} else if(is(_edtw, textBox)) {
			wdw = ui(40);
			wdh = ui(24);
			
		} else if(is(_edtw, vectorBox)) {
			wdw = wdh + ui(40) * _edtw.size;
			wdh = ui(24);
		}
		
		wdw = max(wdw, _edtw.minWidth);
		
		var wdx = sx;
		var wdy = sy  - wdh/2;
		
		switch(halign) {
			case fa_left  : wdx = sx;       break;
			case fa_right : wdx = sx - wdw; break;
		}
		
		_edtw.setFocusHover(pFOCUS, pHOVER);
		_edtw.drawParam(new widgetParam(wdx, wdy, wdw, wdh, val, undefined, [mx,my], x, y).setFont(f_p3));
		
		// draw_set_color(c_red); draw_rectangle(wdx, wdy, wdx + wdw, wdy + wdh, true)
		
		if(halign == fa_left) sx += wdw;
		else                  sx -= wdw;
		ww += wdw;
		
		if(_set.tooltip != "" && point_in_rectangle(mx, my, _sx, 0, sx, h))
			setTOOLTIP(_set.tooltip);
			
		return ww;
	}
	
	function drawSettings(_sets, sx, sy, halign = fa_left) {
		var _spFrm = THEME_VALUE.panel_separation_type == "frame";
		var sgn = halign == fa_left? 1 : -1;
		var sww = 0;
		
		for( var i = 0, n = array_length(_sets); i < n; i++ ) {
			var _set = _sets[i];
			if(is_array(_set)) {
				var sw = drawSettings(_set, sx, sy, halign);
				sx  += sw * sgn;
				sww += sw;	
				continue;
			}
			
			if(_set == -1) {
				draw_set_color(COLORS.panel_separator);
				if(_spFrm) draw_line_width( sx, 0 + ui(4), sx, h - ui(4), 2);
        		else       draw_line(       sx, 0,         sx, h - 1);
        		sx  += ui(4) * sgn;
        		sww += ui(4);
				continue;
			}
			
			var sw = drawSetting(_set, sx, sy, halign) + ui(4);
			sx  += sw * sgn;
			sww += sw;
		}
	
		return sww;
	}
	
	function drawContent(panel) {
		if(!is(canvas, Panel_Canvas)) return;
		
		var _sepFrame  = THEME_VALUE.panel_separation_type == "frame";
		var _draggable = pHOVER && pFOCUS;
		var m = [mx, my];
		
		#region icon
			var bw = ui(48);
			var bh = h;
			
			var hv = pHOVER && point_in_rectangle(mx, my, 0, 0, bw, bh);
			var cc = hv? COLORS._main_accent : COLORS._main_icon;
			var aa = .75 + hv * .25;
			
			draw_sprite_ui(THEME.icon_canvas_24, 0, bw / 2, bh / 2, 1, 1, 0, cc, aa);
			
			var x0 = bw + pad;
		#endregion
		
		#region window control
			var pd = ui(2);
			var bh = h - pd * 2;
        	var bw = min(ui(32), bh);
        	
			var bx = w - pd - bw;
			var by = h / 2 - bh / 2;
			
			var bspr = THEME.button_hide_fill;
			var bp   = THEME.window_exit_icon;
        	var bc   = COLORS._main_accent;
        	
            var b  = buttonInstant(bspr, bx, by, bw, bh, m, pHOVER, true, "", bp, 0, bc);
            if(b) _draggable = false;
            if(b == 2) closeDialog();
            
            bx -= pd;
            
            var x1 = bx;
            draw_set_color(COLORS.panel_separator);
            x1 -= ui(4);
        	if(_sepFrame)
            	 draw_line_width(x1, ui(8), x1, h - ui(8), 2);
            else draw_line_width(x1, 0, x1, h, 1);
            x1 -= ui(4);
		#endregion
		
		var _settings = [];
		var _tool = canvas.tool_current;
		if(is(_tool, canvas_s_tool)) {
			array_append(_settings, _tool.settings);
			
			if(_tool.isDrawer)   { 
				if(!array_empty(_settings)) array_push(_settings, -1);
				_settings = array_append(_settings, canvas.draw_settings);    
			}
			
			if(_tool.isSelector) { 
				if(!array_empty(_settings)) array_push(_settings, -1);
				_settings = array_append(_settings, canvas.selector_settings);
			}
			
		} else {
			_settings = array_append(_settings, canvas.no_tool_settings);
			
		}
		
		var sx = x0;
		var sy = h / 2;
		var sw = drawSettings(_settings, sx, sy, fa_left);
		
		if(mx < sx + sw) _draggable = false;
		
		var _viewSet = canvas.view_settings;
		var sx = x1;
		var sy = h / 2;
		var sw = drawSettings(_viewSet, sx, sy, fa_right);
		
		if(mx > sx - sw) _draggable = false;
		
        #region drag
            if(_draggable && panel.dialog) {
                if(mouse_lpress() && OS == os_windows) 
                	panel.dialog.dragStart();
            }
        #endregion
	}
}