function Panel_Custom(_data = undefined) : PanelContent() constructor {
	title = "Custom";
	w = ui(640);
	h = ui(480);
	auto_pin = true;
	
	data = undefined;
	
	_hovering_frame = undefined;
	 hovering_frame = undefined;
	
	_hovering_element = undefined;
	 hovering_element = undefined;
	
	function setData(_data) {
		if(_data == undefined) return;
		data = _data;
		
		w = min(WIN_W - ui(64), data.prew);
		h = min(WIN_H - ui(64), data.preh);
		
		min_w = data.minw;
		min_h = data.minh;
		
		auto_pin = data.auto_pin;
		
		return self;
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		if(!data) return;
		
		_hovering_frame    = hovering_frame;
		_hovering_element  = hovering_element;
		
		hovering_frame   = undefined;
		hovering_element = undefined;
		
		title = data.name;
		data.setSize(x, y, w, h);
		data.setFocusHover(pFOCUS, pHOVER);
		data.root.checkMouse(self, [mx, my]);
		data.draw(self, [mx, my]);
	}
	
	if(_data) setData(_data);
}