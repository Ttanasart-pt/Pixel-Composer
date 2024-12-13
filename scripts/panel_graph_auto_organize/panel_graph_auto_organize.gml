function Panel_Graph_Auto_Organize(_nodes) : PanelContent() constructor {
	title    = __txt("Auto Organize");
	w        = ui(400);
	h        = ui(320);
	auto_pin = true;
	nodes    = _nodes;
	param    = new node_auto_organize_parameter();
	
	wdgw     = ui(180);
	
	bg_y    = -1;
	bg_y_to = -1;
	bg_a    =  0;
	
	selecting_menu = noone;
	
	static node_organize = function() {
	    node_auto_organize(nodes, param);
	} node_organize();
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Horzontal padding"),
			new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { param.padd_w = v; node_organize(); }),
			function() /*=>*/ {return param.padd_w}
		),
		new __Panel_Linear_Setting_Item(
			__txt("Vertical padding"),
			new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { param.padd_h = v; node_organize(); }),
			function() /*=>*/ {return param.padd_h}
		),
	];
	
	static setHeight = function() { h = ui(12 + 36 * array_length(properties)); }
	setHeight();
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var yy = ui(24);
		var th = ui(36);
		var ww = max(wdgw, w * 0.5); 
		var wh = TEXTBOX_HEIGHT;
		
		var _hov = false;
		if(bg_y) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), bg_y, w - ui(8), th, COLORS.panel_prop_bg, 0.5 * bg_a);
		
		for( var i = 0, n = array_length(properties); i < n; i++ ) {
			var _prop = properties[i];
		
			var _text = _prop.name;
			var _data = _prop.data;
			var _widg = _prop.editWidget;
			if(is_callable(_data)) _data = _data();
			
			_widg.setFocusHover(pFOCUS, pHOVER);
			_widg.register();
			
			var _whover = false;
			if(pHOVER && point_in_rectangle(mx, my, 0, yy - th / 2, w, yy + th / 2)) {
				bg_y_to = yy - th / 2;
				_hov    = true;
				_whover = true;
			}
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(16), yy, _text);
		
			var _x1  = w - ui(8);
			var _wdw = ww;
		
			if(_prop.getDefault != noone)
				_wdw -= ui(32 + 8);
			
			var params = new widgetParam(_x1 - ww, yy - wh / 2, _wdw, wh, _data, {}, [ mx, my ], x, y);
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
}