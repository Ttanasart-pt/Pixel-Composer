function Panel_Canvas_Layer() : PanelContent() constructor {
	context_str = "Canvas";
	title = "Canvas Layer";
	auto_pin = true;
	
	w = ui(32);
	h = ui(800);
	
	canvas = undefined;
	
	function drawContent(panel) {
		
	}
}