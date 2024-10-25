function Panel_Custom_Inspector(_title, _inspector) : PanelContent() constructor {
	title       = __txt(_title);
	context_str = instanceof(_inspector);
	padding     = 8;
	
	auto_pin    = true;
	inspector   = _inspector;
	inspector.popupPanel  = self;
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var pd = in_dialog? ui(0) : ui(8);
		
        inspector.panel     = self;
        inspector.rx        = x;
        inspector.ry        = y;
        inspector.fixHeight = h - pd * 2;
        
        var _wdh = inspector.draw(pd, pd, w - pd * 2, [ mx, my ], pHOVER, pFOCUS, self);
	}
	
	static onClose = function() {
		inspector.popupPanel = noone;
	}
}