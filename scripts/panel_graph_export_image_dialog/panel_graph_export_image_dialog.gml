function Panel_Graph_Export_Image(targetPanel) : PanelContent() constructor {
	title = "Export Graph";
	w = ui(480);
	h = ui(640);
	
	self.targetPanel = targetPanel;
	
	surface  = noone;
	settings = {};
	
	nodeList = noone;
	
	function refresh() {
		if(is_surface(surface))
			surface_free(surface);
		surface = noone;
			
		if(nodeList == noone)
			return;
			
		surface = graph_export_image(nodeList, settings);
	}
	
	function drawContent(panel) {
		
		
		if(is_surface(surface)) {
			
		}
		
		var tx = 0;
		var ty = 0;
	}
}