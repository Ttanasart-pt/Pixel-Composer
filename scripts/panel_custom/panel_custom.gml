function Panel_Custom(_data = undefined) : PanelContent() constructor {
	title = "Custom";
	w = ui(640);
	h = ui(480);
	auto_pin = true;
	
	data = undefined;
	
	function setData(_data) {
		if(_data == undefined) return;
		data = _data;
		
		w = min(WIN_W - ui(64), ui(data.prew));
		h = min(WIN_H - ui(64), ui(data.preh));
		
		min_w = ui(data.minw);
		min_h = ui(data.minh);
		
		auto_pin = data.auto_pin;
		
		return self;
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		if(!data) return;
		
		title = data.name;
		data.setSize(w, h);
		data.setFocusHover(pFOCUS, pHOVER);
		data.draw(self, [mx, my]);
	}
	
	if(_data) setData(_data);
}