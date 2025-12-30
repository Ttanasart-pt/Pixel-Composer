function Panel_Custom_Inspector(_title, _inspector) : PanelContent() constructor {
	title       = __txt(_title);
	context_str = instanceof(_inspector);
	
	auto_pin    = true;
	inspector   = _inspector;
	inspector.popupPanel  = self;
	
	sc_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
        var _wdh = inspector.draw(0, _y, sc_content.surface_w, _m, pHOVER, pFOCUS, self);
        
        return _wdh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var pd = ui(8);
		
        inspector.panel     = self;
        inspector.rx        = x + pd;
        inspector.ry        = y + pd;
        inspector.fixHeight = sc_content.surface_h;
        
        sc_content.verify(w - pd * 2, h - pd * 2);
        sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.drawOffset(pd, pd, mx, my);
	}
	
	static onClose = function() {
		inspector.popupPanel = noone;
	}
}